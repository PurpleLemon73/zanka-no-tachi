import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_engine.dart';

void main() {
  test('spike selects only the default Android runtime flavor', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('media_kit_libs_android_video: ^1.3.8'));
    expect(pubspec, isNot(contains('encoders-gpl')));
    expect(pubspec, isNot(contains('media_kit_libs_android_video_full')));
  });

  test('production engine remains video_player unless explicitly injected', () {
    expect(
      selectedPlaybackEngine(experimentalOverride: false),
      PlaybackEngineKind.videoPlayer,
    );
    expect(
      selectedPlaybackEngine(experimentalOverride: true),
      PlaybackEngineKind.mediaKitExperimental,
    );
  });

  test('track mapping exposes only truthful manifest tracks', () {
    final manifest = PlaybackManifest(
      sourceName: 'fixture',
      binding: EpisodeSourceBinding(
        providerId: const ProviderId('fixture'),
        externalId: 'episode-1',
        canonicalId: const CanonicalEpisodeId('episode-1'),
      ),
      uri: Uri.parse('file:///fixture.mp4'),
      audioTracks: const [
        PlaybackTrack(id: 'it', label: 'Italiano', language: 'it'),
        PlaybackTrack(id: 'en', label: 'English', language: 'en'),
      ],
      subtitleTracks: const [
        PlaybackTrack(id: 'sub-it', label: 'Italiano', language: 'it'),
      ],
    );

    final tracks = PlaybackEngineTracks(
      audio: manifestAudioTracks(manifest),
      subtitles: manifestSubtitleTracks(manifest),
    );
    expect(tracks.hasAudioChoices, isTrue);
    expect(tracks.hasSubtitleChoices, isTrue);
    expect(tracks.audio.map((track) => track.language), ['it', 'en']);
  });

  test('no fake track controls are exposed for an empty manifest', () {
    final manifest = PlaybackManifest(
      sourceName: 'fixture',
      binding: EpisodeSourceBinding(
        providerId: const ProviderId('fixture'),
        externalId: 'episode-1',
        canonicalId: const CanonicalEpisodeId('episode-1'),
      ),
      uri: Uri.parse('file:///fixture.mp4'),
    );
    final tracks = PlaybackEngineTracks(
      audio: manifestAudioTracks(manifest),
      subtitles: manifestSubtitleTracks(manifest),
    );
    expect(tracks.hasAudioChoices, isFalse);
    expect(tracks.hasSubtitleChoices, isFalse);
  });

  test('resume clamping is engine-neutral', () {
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
      boundedPlaybackStart(
        const Duration(seconds: -1),
        const Duration(seconds: 12),
      ),
      Duration.zero,
    );
  });
}
