import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_engine.dart';

void main() {
  test(
    'production package excludes rejected experimental runtime and fixtures',
    () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, isNot(contains('media_kit')));
      expect(Directory('assets/m16_playback_probe').existsSync(), isFalse);
    },
  );

  test(
    'automatic and unavailable explicit preferences safely use production',
    () {
      final registry = PlaybackEngineRegistry(
        productionBuilder: _FakeEngine.new,
      );
      final automatic = registry.create();
      final unavailable = registry.create(PlaybackEnginePreference.mediaKit);
      expect(automatic.engine.kind, PlaybackEngineKind.videoPlayer);
      expect(automatic.fallbackReason, isNull);
      expect(unavailable.engine.kind, PlaybackEngineKind.videoPlayer);
      expect(unavailable.fallbackReason, contains('not production-approved'));
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
}

class _FakeEngine implements PlaybackEngine {
  final ValueNotifier<PlaybackEngineState> notifier = ValueNotifier(
    const PlaybackEngineState(),
  );
  @override
  PlaybackCapabilities get capabilities =>
      const PlaybackCapabilities(canSeek: true, canSetPlaybackRate: true);
  @override
  String get diagnosticName => 'fake-video-player';
  @override
  PlaybackEngineKind get kind => PlaybackEngineKind.videoPlayer;
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
