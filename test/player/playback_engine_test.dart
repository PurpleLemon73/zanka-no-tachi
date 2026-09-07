import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_engine.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/player/video_display_mode.dart';

void main() {
  test(
    'production package excludes rejected experimental runtime and fixtures',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, isNot(contains('media_kit')));
      expect(Directory('assets/m16_playback_probe').existsSync(), isFalse);
    },
  );

  test('automatic, explicit, and unavailable engine selection is truthful', () {
    var productionCreations = 0;
    var betterCreations = 0;
    final registry = PlaybackEngineRegistry(
      productionBuilder: () {
        productionCreations++;
        return _FakeEngine();
      },
      betterPlayerExperimentalBuilder: () {
        betterCreations++;
        return _FakeEngine(kind: PlaybackEngineKind.betterPlayerExperimental);
      },
    );
    final automatic = registry.create();
    final production = registry.create(PlaybackEnginePreference.videoPlayer);
    final experimental = registry.create(
      PlaybackEnginePreference.betterPlayerExperimental,
    );
    final unavailable = PlaybackEngineRegistry(
      productionBuilder: _FakeEngine.new,
    ).create(PlaybackEnginePreference.betterPlayerExperimental);

    expect(automatic.engine.kind, PlaybackEngineKind.videoPlayer);
    expect(automatic.fallbackReason, isNull);
    expect(production.engine.kind, PlaybackEngineKind.videoPlayer);
    expect(production.fallbackReason, isNull);
    expect(
      experimental.engine.kind,
      PlaybackEngineKind.betterPlayerExperimental,
    );
    expect(experimental.fallbackReason, isNull);
    expect(unavailable.engine.kind, PlaybackEngineKind.videoPlayer);
    expect(unavailable.fallbackReason, contains('unavailable'));
    expect(productionCreations, 2);
    expect(betterCreations, 1);
  });

  test('engine preference parsing is tolerant and defaults to Automatic', () {
    expect(
      PlaybackEnginePreference.parse(null),
      PlaybackEnginePreference.automatic,
    );
    expect(
      PlaybackEnginePreference.parse('unknown-or-retired-engine'),
      PlaybackEnginePreference.automatic,
    );
    expect(
      PlaybackEnginePreference.parse('mediaKit'),
      PlaybackEnginePreference.automatic,
    );
    expect(
      PlaybackEnginePreference.parse('betterPlayerExperimental'),
      PlaybackEnginePreference.betterPlayerExperimental,
    );
  });

  test(
    'engine preference is device-local and excluded from portable settings',
    () {
      const preferences = PlaybackPreferences(
        enginePreference: PlaybackEnginePreference.betterPlayerExperimental,
      );
      expect(
        PlaybackPreferences.fromJson(preferences.toJson()).enginePreference,
        PlaybackEnginePreference.betterPlayerExperimental,
      );
      expect(preferences.toBackupJson(), isNot(contains('enginePreference')));
    },
  );

  test(
    'saved engine change affects the next preference snapshot only',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'zanka-engine-preference-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = PlaybackPreferencesStore(
        file: File('${directory.path}/player-preferences.json'),
      );
      final currentSessionPreferences = await store.load();
      await store.save(
        currentSessionPreferences.copyWith(
          enginePreference: PlaybackEnginePreference.betterPlayerExperimental,
        ),
      );

      expect(
        currentSessionPreferences.enginePreference,
        PlaybackEnginePreference.automatic,
      );
      expect(
        (await store.load()).enginePreference,
        PlaybackEnginePreference.betterPlayerExperimental,
      );
    },
  );

  test('capabilities independently gate advanced controls', () {
    const capabilities = PlaybackCapabilities(
      canSeek: true,
      canSetPlaybackRate: true,
      supportsHls: true,
    );
    expect(capabilities.canSeek, isTrue);
    expect(capabilities.canSelectAudioTrack, isFalse);
    expect(capabilities.canSelectSubtitleTrack, isFalse);
    expect(capabilities.supportsDash, isFalse);
    const tracks = PlaybackEngineState(
      audioTracks: [
        PlaybackEngineTrack(id: 'a', label: 'A'),
        PlaybackEngineTrack(id: 'b', label: 'B'),
      ],
      subtitleTracks: [PlaybackEngineTrack(id: 's', label: 'S')],
    );
    expect(shouldShowAudioControl(capabilities, tracks), isFalse);
    expect(shouldShowSubtitleControl(capabilities, tracks), isFalse);
  });

  test('truthful capabilities reveal selectors only with real choices', () {
    const capabilities = PlaybackCapabilities(
      canSeek: true,
      canSetPlaybackRate: true,
      canSelectAudioTrack: true,
      canSelectSubtitleTrack: true,
    );
    const tracks = PlaybackEngineState(
      audioTracks: [
        PlaybackEngineTrack(id: 'it', label: 'Italiano'),
        PlaybackEngineTrack(id: 'en', label: 'English'),
      ],
      subtitleTracks: [PlaybackEngineTrack(id: 'sub', label: 'English')],
    );
    expect(shouldShowAudioControl(capabilities, tracks), isTrue);
    expect(shouldShowSubtitleControl(capabilities, tracks), isTrue);
  });

  test('resume and seek clamping are engine-neutral', () {
    expect(
      boundedPlaybackStart(
        const Duration(seconds: 7),
        const Duration(seconds: 12),
      ),
      const Duration(seconds: 7),
    );
    expect(
      boundedPlaybackStart(
        const Duration(seconds: 12),
        const Duration(seconds: 12),
      ),
      Duration.zero,
    );
    expect(
      boundedSeek(const Duration(seconds: 20), const Duration(seconds: 12)),
      const Duration(seconds: 12),
    );
  });

  test('playback preferences default to safe automatic display geometry', () {
    final legacy = PlaybackPreferences.fromJson({
      'seekStepSeconds': 10,
      'autoplay': true,
      'speed': 1.0,
    });
    expect(legacy.videoDisplayMode, isA<VideoDisplayMode>());
    expect(legacy.videoDisplayMode.isAutomatic, isTrue);
    final selected = legacy.copyWith(
      videoDisplayMode: const VideoDisplayMode(
        fit: VideoDisplayFit.fitHeight,
        aspectPreset: VideoAspectPreset.fourThree,
      ),
    );
    expect(
      PlaybackPreferences.fromJson(
        selected.toJson(),
      ).videoDisplayMode.aspectPreset,
      VideoAspectPreset.fourThree,
    );
  });
}

class _FakeEngine implements PlaybackEngine {
  _FakeEngine({this.kind = PlaybackEngineKind.videoPlayer});

  final ValueNotifier<PlaybackEngineState> notifier = ValueNotifier(
    const PlaybackEngineState(),
  );
  @override
  PlaybackCapabilities get capabilities =>
      const PlaybackCapabilities(canSeek: true, canSetPlaybackRate: true);
  @override
  String get diagnosticName => 'fake-video-player';
  @override
  final PlaybackEngineKind kind;
  @override
  ValueListenable<PlaybackEngineState> get state => notifier;
  @override
  Widget buildSurface() => const SizedBox.shrink();
  @override
  Future<void> dispose() async => notifier.dispose();
  @override
  Future<void> open(
    PlaybackManifest manifest, {
    Duration startPosition = Duration.zero,
  }) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> selectAudioTrack(String id) async {}
  @override
  Future<void> selectSubtitleTrack(String? id) async {}
  @override
  Future<void> setPlaybackRate(double rate) async {}
}
