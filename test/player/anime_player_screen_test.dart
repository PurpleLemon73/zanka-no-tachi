import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_engine.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/player/playback_repository.dart';
import 'package:zanka_no_tachi/player/playback_source.dart';
import 'package:zanka_no_tachi/player/ui/anime_player_screen.dart';
import 'package:zanka_no_tachi/player/video_display_mode.dart';

const _mediaId = CanonicalMediaId('player-ui-anime');
const _providerId = ProviderId('local-player-ui');
const _episodeOne = CanonicalEpisodeId('player-ui-episode-1');
const _episodeTwo = CanonicalEpisodeId('player-ui-episode-2');
const _episodeThree = CanonicalEpisodeId('player-ui-episode-3');

void main() {
  for (final isTv in [false, true]) {
    testWidgets(
      'fullscreen episode navigation preserves presentation and resume (${isTv ? 'TV' : 'mobile'})',
      (tester) async {
        final fixture = (await tester.runAsync(
          () => _PlayerFixture.create(episodeCount: 3),
        ))!;
        _disposeFixtureAfterScreen(tester, fixture);
        final systemCalls = _recordSystemUiCalls(tester);
        const displayMode = VideoDisplayMode(
          fit: VideoDisplayFit.fitWidth,
          aspectPreset: VideoAspectPreset.twentyOneNine,
        );
        await tester.runAsync(() async {
          await fixture.repository.savePreferences(
            PlaybackPreferences(
              autoplay: false,
              videoDisplayMode: displayMode,
              enginePreference: isTv
                  ? PlaybackEnginePreference.betterPlayerExperimental
                  : PlaybackEnginePreference.automatic,
            ),
          );
          for (final episode in [_episodeOne, _episodeTwo]) {
            final session = await fixture.repository.open(
              PlaybackSessionRequest(mediaId: _mediaId, episodeId: episode),
            );
            await fixture.repository.savePosition(
              session,
              Duration(seconds: episode == _episodeOne ? 27 : 43),
              const Duration(seconds: 100),
            );
          }
        });
        final production = _EngineFactory();
        final better = _EngineFactory(
          kind: PlaybackEngineKind.betterPlayerExperimental,
        );
        final engines = isTv ? better : production;
        await _pumpPlayer(
          tester,
          fixture,
          engines,
          _episodeOne,
          isTv: isTv,
          engineRegistry: PlaybackEngineRegistry(
            productionBuilder: production.create,
            betterPlayerExperimentalBuilder: better.create,
          ),
        );
        expect(find.byType(AppBar), findsOneWidget);
        expect(engines.created.single.openPositions, [
          const Duration(seconds: 27),
        ]);
        _invokeIconButton(tester, 'Fullscreen');
        await tester.pumpAndSettle();
        expect(systemCalls.map((call) => call.arguments), [
          'SystemUiMode.immersiveSticky',
          [
            'DeviceOrientation.landscapeLeft',
            'DeviceOrientation.landscapeRight',
          ],
        ]);
        systemCalls.clear();

        if (isTv) {
          expect(_focusedTooltip(tester), 'Play');
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pump();
          expect(_focusedTooltip(tester), 'Next episode');
          await tester.sendKeyEvent(LogicalKeyboardKey.select);
        } else {
          await tester.tap(find.byTooltip('Next episode'));
        }
        await _pumpUntilReady(tester, engines, 2);
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(AppBar), findsNothing);
        expect(find.byTooltip('Exit fullscreen'), findsOneWidget);
        expect(
          systemCalls,
          isEmpty,
          reason: 'Outgoing disposal must not reset system UI',
        );
        expect(
          engines.created.first.state.value.phase,
          PlaybackEnginePhase.disposed,
        );
        expect(engines.created.last.openedExternalIds, ['episode-2']);
        expect(engines.created.last.openPositions, [Duration.zero]);
        expect(
          tester
              .widget<VideoDisplaySurface>(find.byType(VideoDisplaySurface))
              .mode
              .toJson(),
          displayMode.toJson(),
        );
        expect(
          (await fixture.database.animeSourcePlaybackResume(
            _providerId,
            'episode-2',
          ))!.position,
          const Duration(seconds: 43),
          reason: 'Starting Next must not copy the previous episode resume',
        );
        if (isTv) expect(_focusedTooltip(tester), 'Play');

        _invokeIconButton(tester, 'Previous episode');
        await _pumpUntilReady(tester, engines, 3);
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(AppBar), findsNothing);
        expect(systemCalls, isEmpty);
        expect(engines.created.last.openedExternalIds, ['episode-1']);
        expect(engines.created.last.openPositions, [
          const Duration(seconds: 27),
        ]);
        expect(isTv ? production.created : better.created, isEmpty);

        // The completion CTA uses the same Next path and must inherit presentation.
        engines.created.last.complete();
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('Next Episode'));
        await _pumpUntilReady(tester, engines, 4);
        await tester.pump(const Duration(seconds: 1));
        expect(find.byTooltip('Exit fullscreen'), findsOneWidget);
        expect(systemCalls, isEmpty);

        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(AnimePlayerScreen), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(systemCalls.map((call) => call.arguments), [
          'SystemUiMode.edgeToEdge',
          DeviceOrientation.values.map((value) => value.toString()).toList(),
        ]);
        systemCalls.clear();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        expect(
          systemCalls,
          isEmpty,
          reason: 'Explicit fullscreen exit restores only once',
        );
      },
    );
  }

  testWidgets(
    'Back during fullscreen episode replacement restores presentation once',
    (tester) async {
      final fixture = (await tester.runAsync(
        () => _PlayerFixture.create(episodeCount: 3),
      ))!;
      _disposeFixtureAfterScreen(tester, fixture);
      await tester.runAsync(
        () => fixture.repository.savePreferences(
          const PlaybackPreferences(autoplay: false),
        ),
      );
      final enterFullscreen = Completer<void>();
      addTearDown(() {
        if (!enterFullscreen.isCompleted) enterFullscreen.complete();
      });
      final systemCalls = _recordSystemUiCalls(
        tester,
        waitForImmersive: enterFullscreen.future,
      );
      final engines = _EngineFactory();
      await _pumpPlayer(tester, fixture, engines, _episodeOne);
      _invokeIconButton(tester, 'Fullscreen');
      await tester.pump();
      expect(systemCalls.single.arguments, 'SystemUiMode.immersiveSticky');

      // Repeated key/touch callbacks must not transfer ownership twice.
      _invokeIconButton(tester, 'Next episode');
      _invokeIconButton(tester, 'Next episode');
      await _pumpUntilReady(tester, engines, 2);
      expect(
        find.byType(AnimePlayerScreen, skipOffstage: false),
        findsNWidgets(2),
        reason: 'Exercise Back before the outgoing route is disposed',
      );
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(systemCalls, hasLength(1));

      // Release the old route's pending enter only after the new route exits.
      enterFullscreen.complete();
      await tester.pumpAndSettle();
      expect(find.byType(AnimePlayerScreen), findsOneWidget);
      expect(find.byTooltip('Fullscreen'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(systemCalls.map((call) => call.arguments), [
        'SystemUiMode.immersiveSticky',
        ['DeviceOrientation.landscapeLeft', 'DeviceOrientation.landscapeRight'],
        'SystemUiMode.edgeToEdge',
        DeviceOrientation.values.map((value) => value.toString()).toList(),
      ]);
      systemCalls.clear();

      // Windowed navigation and a later fresh player do not inherit fullscreen.
      _invokeIconButton(tester, 'Next episode');
      await _pumpUntilReady(tester, engines, 3);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byTooltip('Fullscreen'), findsOneWidget);
      expect(systemCalls, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      final freshEngines = _EngineFactory();
      await _pumpPlayer(tester, fixture, freshEngines, _episodeOne);
      expect(find.byTooltip('Fullscreen'), findsOneWidget);
      expect(systemCalls, isEmpty);

      _invokeIconButton(tester, 'Fullscreen');
      await tester.pumpAndSettle();
      systemCalls.clear();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(systemCalls.map((call) => call.arguments), [
        'SystemUiMode.edgeToEdge',
        DeviceOrientation.values.map((value) => value.toString()).toList(),
      ]);
    },
  );

  testWidgets(
    'player UI keeps canonical episode navigation, completion and replay deliberate',
    (tester) async {
      final fixture = (await tester.runAsync(
        () => _PlayerFixture.create(episodeCount: 3),
      ))!;
      _disposeFixtureAfterScreen(tester, fixture);
      final engines = _EngineFactory();

      await _pumpPlayer(tester, fixture, engines, _episodeOne);

      final previous = tester.widget<IconButton>(
        _iconButtonForTooltip('Previous episode'),
      );
      final next = tester.widget<IconButton>(
        _iconButtonForTooltip('Next episode'),
      );
      expect(previous.onPressed, isNull);
      expect(next.onPressed, isNotNull);
      expect(find.text('0:00'), findsOneWidget);
      expect(find.text('1:40'), findsOneWidget);
      expect(find.byTooltip('Audio'), findsNothing);
      expect(find.byTooltip('Subtitles'), findsNothing);

      _invokeIconButton(tester, 'Episodes');
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Episodes'), findsOneWidget);
      expect(find.text('Episode 2'), findsOneWidget);
      _invokeListTile(tester, 'Episode 2');
      await tester.pump(const Duration(milliseconds: 400));
      await _pumpUntilReady(tester, engines, 2);
      expect(engines.created.last.openedExternalIds, ['episode-2']);

      final middlePrevious = tester.widget<IconButton>(
        _iconButtonForTooltip('Previous episode'),
      );
      final middleNext = tester.widget<IconButton>(
        _iconButtonForTooltip('Next episode'),
      );
      expect(middlePrevious.onPressed, isNotNull);
      expect(middleNext.onPressed, isNotNull);

      _invokeIconButton(tester, 'Previous episode');
      await tester.pump(const Duration(milliseconds: 400));
      await _pumpUntilReady(tester, engines, 3);
      expect(engines.created.last.openedExternalIds, ['episode-1']);

      // Autoplay-next is disabled by default. Manual next remains available and
      // deliberately starts the different canonical episode at zero.
      _invokeIconButton(tester, 'Next episode');
      await tester.pump(const Duration(milliseconds: 400));
      await _pumpUntilReady(tester, engines, 4);
      expect(engines.created.last.openPositions, [Duration.zero]);
      expect(engines.created.last.openedExternalIds, ['episode-2']);

      engines.created.last.complete();
      await tester.pump();
      await tester.pump();
      expect(find.text('Episode complete'), findsOneWidget);
      expect(find.text('Replay'), findsOneWidget);
      expect(find.text('Next Episode'), findsOneWidget);

      await tester.tap(find.text('Next Episode'));
      await tester.pump(const Duration(milliseconds: 400));
      await _pumpUntilReady(tester, engines, 5);
      expect(engines.created.last.openPositions, [Duration.zero]);
      expect(engines.created.last.openedExternalIds, ['episode-3']);

      engines.created.last.complete();
      await tester.pump();
      await tester.pump();
      expect(find.text('End of available episodes'), findsOneWidget);
      expect(
        tester
            .widget<IconButton>(_iconButtonForTooltip('Next episode'))
            .onPressed,
        isNull,
      );

      final last = engines.created.last;
      tester
          .widget<OutlinedButton>(find.byType(OutlinedButton).last)
          .onPressed!
          .call();
      await tester.pump();
      expect(last.seekPositions, contains(Duration.zero));
      expect(last.playCalls, greaterThan(0));
      expect(last.state.value.phase, PlaybackEnginePhase.ready);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('audio and subtitle controls appear only for reported tracks', (
    tester,
  ) async {
    final fixture = (await tester.runAsync(
      () => _PlayerFixture.create(episodeCount: 1),
    ))!;
    _disposeFixtureAfterScreen(tester, fixture);
    final engines = _EngineFactory(
      capabilities: const PlaybackCapabilities(
        canSeek: true,
        canSetPlaybackRate: true,
        canSelectAudioTrack: true,
        canSelectSubtitleTrack: true,
      ),
      audioTracks: const [
        PlaybackEngineTrack(id: 'ja', label: 'Japanese', language: 'ja'),
        PlaybackEngineTrack(id: 'en', label: 'English', language: 'en'),
      ],
      subtitleTracks: const [
        PlaybackEngineTrack(id: 'it', label: 'Italiano', language: 'it'),
      ],
    );

    await _pumpPlayer(tester, fixture, engines, _episodeOne);
    expect(find.byTooltip('Audio'), findsOneWidget);
    expect(find.byTooltip('Subtitles'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'display geometry changes live without reopening seeking or mutating resume',
    (tester) async {
      final fixture = (await tester.runAsync(
        () => _PlayerFixture.create(episodeCount: 1),
      ))!;
      _disposeFixtureAfterScreen(tester, fixture);
      final engines = _EngineFactory();

      await _pumpPlayer(tester, fixture, engines, _episodeOne);
      final player = engines.created.single;
      final initialPosition = player.state.value.position;
      final originalFrame = tester.getSize(
        find.byKey(const Key('video-content-frame')),
      );
      expect(originalFrame.aspectRatio, closeTo(4 / 3, 0.01));

      _invokeIconButton(tester, 'Display mode');
      await tester.pumpAndSettle();
      expect(find.text('Video display mode'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('video-fit-fillCrop')),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('video-aspect-twentyOneNine')),
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(
        find.byKey(const ValueKey('video-aspect-twentyOneNine')),
      );
      await tester.pump();

      expect(engines.created, hasLength(1));
      expect(player.openPositions, hasLength(1));
      expect(player.seekPositions, isEmpty);
      expect(player.state.value.position, initialPosition);
      expect(await fixture.database.animeProgress(_mediaId), isNull);

      await tester.scrollUntilVisible(
        find.byKey(const Key('custom-video-aspect-input')),
        240,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byKey(const Key('custom-video-aspect-input')),
                matching: find.byType(TextField),
              ),
            )
            .keyboardType,
        TextInputType.text,
      );
      await tester.enterText(
        find.byKey(const Key('custom-video-aspect-input')),
        '0:1',
      );
      tester
          .widget<FilledButton>(
            find.byKey(const Key('apply-custom-video-aspect')),
          )
          .onPressed!();
      await tester.pump();
      expect(find.textContaining('Enter two positive values'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('custom-video-aspect-input')),
        '2.39:1',
      );
      tester
          .widget<FilledButton>(
            find.byKey(const Key('apply-custom-video-aspect')),
          )
          .onPressed!();
      await tester.pump();
      expect(player.seekPositions, isEmpty);
      expect(player.state.value.position, initialPosition);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Video display mode'), findsNothing);
      expect(find.byTooltip('Display mode'), findsOneWidget);

      _invokeIconButton(tester, 'Display mode');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('reset-video-display-mode')));
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      final resetFrame = tester.getSize(
        find.byKey(const Key('video-content-frame')),
      );
      expect(resetFrame.aspectRatio, closeTo(4 / 3, 0.01));
      final saved = (await tester.runAsync(
        fixture.repository.preferencesStore.load,
      ))!;
      expect(saved.videoDisplayMode.isAutomatic, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('TV D-pad reaches display mode and Back closes its menu first', (
    tester,
  ) async {
    final fixture = (await tester.runAsync(
      () => _PlayerFixture.create(episodeCount: 1),
    ))!;
    _disposeFixtureAfterScreen(tester, fixture);
    final engines = _EngineFactory();

    await _pumpPlayer(tester, fixture, engines, _episodeOne, isTv: true);
    expect(_focusedTooltip(tester), isIn(['Play', 'Pause']));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(_focusedTooltip(tester), 'Episodes');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_focusedTooltip(tester), 'Source');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(_focusedTooltip(tester), 'Display mode');
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.text('Video display mode'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Video display mode'), findsNothing);
    expect(find.byTooltip('Display mode'), findsOneWidget);
    expect(engines.created, hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'experimental preference selects Better for this session and changes next session only',
    (tester) async {
      final fixture = (await tester.runAsync(
        () => _PlayerFixture.create(episodeCount: 1),
      ))!;
      _disposeFixtureAfterScreen(tester, fixture);
      await tester.runAsync(
        () => fixture.repository.savePreferences(
          const PlaybackPreferences(
            enginePreference: PlaybackEnginePreference.betterPlayerExperimental,
          ),
        ),
      );
      expect(
        (await tester.runAsync(
          fixture.repository.preferencesStore.load,
        ))!.enginePreference,
        PlaybackEnginePreference.betterPlayerExperimental,
      );
      final production = _EngineFactory();
      final better = _EngineFactory(
        kind: PlaybackEngineKind.betterPlayerExperimental,
      );
      final registry = PlaybackEngineRegistry(
        productionBuilder: production.create,
        betterPlayerExperimentalBuilder: better.create,
      );

      await _pumpPlayer(
        tester,
        fixture,
        better,
        _episodeOne,
        engineRegistry: registry,
      );
      expect(production.created, isEmpty);
      expect(better.created, hasLength(1));
      expect(
        find.text('Using Better Player (Experimental) for this session.'),
        findsOneWidget,
      );
      expect(find.byTooltip('Audio'), findsNothing);
      expect(find.byTooltip('Subtitles'), findsNothing);

      await tester.runAsync(
        () => fixture.repository.savePreferences(
          const PlaybackPreferences(
            enginePreference: PlaybackEnginePreference.videoPlayer,
          ),
        ),
      );
      await tester.pump();
      expect(better.created, hasLength(1));
      expect(production.created, isEmpty);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      expect(
        (await tester.runAsync(
          fixture.repository.preferencesStore.load,
        ))!.enginePreference,
        PlaybackEnginePreference.videoPlayer,
      );
      await _pumpPlayer(
        tester,
        fixture,
        production,
        _episodeOne,
        engineRegistry: registry,
      );
      expect(production.created, hasLength(1));
      expect(better.created, hasLength(1));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );
}

String? _focusedTooltip(WidgetTester tester) {
  final context = tester.binding.focusManager.primaryFocus?.context;
  String? tooltip;
  context?.visitAncestorElements((element) {
    final widget = element.widget;
    if (widget is Tooltip) {
      tooltip = widget.message;
      return false;
    }
    return true;
  });
  return tooltip;
}

List<MethodCall> _recordSystemUiCalls(
  WidgetTester tester, {
  Future<void>? waitForImmersive,
}) {
  final calls = <MethodCall>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'SystemChrome.setEnabledSystemUIMode' ||
          call.method == 'SystemChrome.setPreferredOrientations') {
        calls.add(call);
      }
      if (call.arguments == 'SystemUiMode.immersiveSticky') {
        await waitForImmersive;
      }
      return null;
    },
  );
  addTearDown(() {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });
  return calls;
}

Finder _iconButtonForTooltip(String tooltip) => find
    .ancestor(of: find.byTooltip(tooltip), matching: find.byType(IconButton))
    .last;

void _invokeIconButton(WidgetTester tester, String tooltip) =>
    tester.widget<IconButton>(_iconButtonForTooltip(tooltip)).onPressed!.call();

void _invokeListTile(WidgetTester tester, String title) => tester
    .widget<ListTile>(
      find.ancestor(of: find.text(title), matching: find.byType(ListTile)),
    )
    .onTap!
    .call();

void _disposeFixtureAfterScreen(WidgetTester tester, _PlayerFixture fixture) {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.runAsync(fixture.dispose);
  });
}

Future<void> _pumpPlayer(
  WidgetTester tester,
  _PlayerFixture fixture,
  _EngineFactory engines,
  CanonicalEpisodeId episodeId, {
  bool isTv = false,
  PlaybackEngineRegistry? engineRegistry,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AnimePlayerScreen(
        repository: fixture.repository,
        isTv: isTv,
        engineRegistry:
            engineRegistry ??
            PlaybackEngineRegistry(productionBuilder: engines.create),
        request: PlaybackSessionRequest(
          mediaId: _mediaId,
          episodeId: episodeId,
        ),
      ),
    ),
  );
  await _pumpUntilReady(tester, engines, 1);
  for (
    var index = 0;
    index < 20 && find.byTooltip('Episodes').evaluate().isEmpty;
    index++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(find.byTooltip('Episodes'), findsOneWidget);
}

Future<void> _pumpUntilReady(
  WidgetTester tester,
  _EngineFactory engines,
  int count,
) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
  for (var index = 0; index < 40 && engines.created.length < count; index++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(engines.created, hasLength(count));
  for (var index = 0; index < 5; index++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
}

class _PlayerFixture {
  _PlayerFixture._({
    required this.database,
    required this.directory,
    required this.repository,
  });

  final CanonicalDatabase database;
  final Directory directory;
  final PlaybackRepository repository;

  static Future<_PlayerFixture> create({required int episodeCount}) async {
    final directory = await Directory.systemTemp.createTemp('zanka-player-ui-');
    final database = CanonicalDatabase(NativeDatabase.memory());
    final repository = PlaybackRepository(
      database: database,
      sources: PlaybackSourceRegistry([const _Resolver()]),
      preferencesStore: PlaybackPreferencesStore(
        file: File('${directory.path}/player-preferences.json'),
      ),
    );
    const provenance = FieldProvenance(providerId: _providerId);
    await database.saveMedia(
      const CanonicalAnime(
        id: _mediaId,
        title: SourcedValue(value: 'Player UI anime', provenance: provenance),
        status: CanonicalMediaStatus.ongoing,
        format: AnimeFormat.tv,
      ),
    );
    for (var number = 1; number <= episodeCount; number++) {
      final id = switch (number) {
        1 => _episodeOne,
        2 => _episodeTwo,
        _ => _episodeThree,
      };
      await database.saveEpisode(
        CanonicalEpisode(
          id: id,
          mediaId: _mediaId,
          label: EpisodeLabel(
            rawLabel: 'Episode $number',
            number: number.toDouble(),
          ),
        ),
      );
      await database.saveEpisodeBinding(
        EpisodeSourceBinding(
          canonicalId: id,
          providerId: _providerId,
          externalId: 'episode-$number',
          relativeLocator: '/episode-$number.mp4',
        ),
      );
    }
    return _PlayerFixture._(
      database: database,
      directory: directory,
      repository: repository,
    );
  }

  Future<void> dispose() async {
    await database.close();
    await directory.delete(recursive: true);
  }
}

class _Resolver implements PlaybackSourceResolver {
  const _Resolver();
  @override
  ProviderId get providerId => _providerId;
  @override
  PlaybackSourceCapability capability(EpisodeSourceBinding binding) =>
      PlaybackSourceCapability.playbackCapable;
  @override
  Future<PlaybackManifest> resolve(PlaybackSessionRequest request) async =>
      PlaybackManifest(
        sourceName: 'Local player test',
        binding: request.binding!,
        uri: Uri.file(request.binding!.relativeLocator!),
      );
}

class _EngineFactory {
  _EngineFactory({
    this.kind = PlaybackEngineKind.videoPlayer,
    this.capabilities = const PlaybackCapabilities(
      canSeek: true,
      canSetPlaybackRate: true,
    ),
    this.audioTracks = const [],
    this.subtitleTracks = const [],
  });

  final PlaybackEngineKind kind;
  final PlaybackCapabilities capabilities;
  final List<PlaybackEngineTrack> audioTracks;
  final List<PlaybackEngineTrack> subtitleTracks;
  final List<_FakePlaybackEngine> created = [];

  PlaybackEngine create() {
    final engine = _FakePlaybackEngine(
      kind: kind,
      capabilities: capabilities,
      audioTracks: audioTracks,
      subtitleTracks: subtitleTracks,
    );
    created.add(engine);
    return engine;
  }
}

class _FakePlaybackEngine implements PlaybackEngine {
  _FakePlaybackEngine({
    required this.kind,
    required this.capabilities,
    required this.audioTracks,
    required this.subtitleTracks,
  });

  @override
  final PlaybackEngineKind kind;
  @override
  final PlaybackCapabilities capabilities;
  final List<PlaybackEngineTrack> audioTracks;
  final List<PlaybackEngineTrack> subtitleTracks;
  final ValueNotifier<PlaybackEngineState> _state = ValueNotifier(
    const PlaybackEngineState(),
  );
  final List<Duration> openPositions = [];
  final List<String> openedExternalIds = [];
  final List<Duration> seekPositions = [];
  int playCalls = 0;
  String? selectedAudio;
  String? selectedSubtitle;

  @override
  String get diagnosticName => 'test engine';
  @override
  ValueListenable<PlaybackEngineState> get state => _state;

  @override
  Widget buildSurface() => const ColoredBox(color: Colors.black);

  @override
  Future<void> open(
    PlaybackManifest manifest, {
    Duration startPosition = Duration.zero,
  }) async {
    openPositions.add(startPosition);
    openedExternalIds.add(manifest.binding.externalId);
    _state.value = PlaybackEngineState(
      phase: PlaybackEnginePhase.ready,
      position: startPosition,
      duration: const Duration(seconds: 100),
      intrinsicAspectRatio: 4 / 3,
      audioTracks: audioTracks,
      subtitleTracks: subtitleTracks,
    );
  }

  @override
  Future<void> play() async {
    playCalls++;
    _state.value = _state.value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    _state.value = _state.value.copyWith(isPlaying: false);
  }

  @override
  Future<void> seek(Duration position) async {
    final bounded = boundedSeek(position, _state.value.duration);
    seekPositions.add(bounded);
    _state.value = _state.value.copyWith(
      phase: PlaybackEnginePhase.ready,
      position: bounded,
    );
  }

  @override
  Future<void> setPlaybackRate(double rate) async {
    _state.value = _state.value.copyWith(playbackRate: rate);
  }

  @override
  Future<void> selectAudioTrack(String id) async {
    selectedAudio = id;
    _state.value = _state.value.copyWith(selectedAudioTrackId: id);
  }

  @override
  Future<void> selectSubtitleTrack(String? id) async {
    selectedSubtitle = id;
    _state.value = _state.value.copyWith(selectedSubtitleTrackId: id);
  }

  void complete() {
    _state.value = _state.value.copyWith(
      phase: PlaybackEnginePhase.completed,
      position: _state.value.duration,
      isPlaying: false,
    );
  }

  @override
  Future<void> dispose() async {
    _state.value = const PlaybackEngineState(
      phase: PlaybackEnginePhase.disposed,
    );
  }
}
