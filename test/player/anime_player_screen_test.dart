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

const _mediaId = CanonicalMediaId('player-ui-anime');
const _providerId = ProviderId('local-player-ui');
const _episodeOne = CanonicalEpisodeId('player-ui-episode-1');
const _episodeTwo = CanonicalEpisodeId('player-ui-episode-2');
const _episodeThree = CanonicalEpisodeId('player-ui-episode-3');

void main() {
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
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AnimePlayerScreen(
        repository: fixture.repository,
        isTv: isTv,
        engineRegistry: PlaybackEngineRegistry(
          productionBuilder: engines.create,
        ),
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
  for (var index = 0; index < 20 && engines.created.length < count; index++) {
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
    this.capabilities = const PlaybackCapabilities(
      canSeek: true,
      canSetPlaybackRate: true,
    ),
    this.audioTracks = const [],
    this.subtitleTracks = const [],
  });

  final PlaybackCapabilities capabilities;
  final List<PlaybackEngineTrack> audioTracks;
  final List<PlaybackEngineTrack> subtitleTracks;
  final List<_FakePlaybackEngine> created = [];

  PlaybackEngine create() {
    final engine = _FakePlaybackEngine(
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
    required this.capabilities,
    required this.audioTracks,
    required this.subtitleTracks,
  });

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
  PlaybackEngineKind get kind => PlaybackEngineKind.videoPlayer;
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
