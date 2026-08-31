import 'playback_domain.dart';

enum PlaybackEngineKind { videoPlayer, mediaKitExperimental }

const experimentalPlaybackEngineEnabled = bool.fromEnvironment(
  'ZANKA_EXPERIMENTAL_MEDIA_KIT',
);

PlaybackEngineKind selectedPlaybackEngine({bool? experimentalOverride}) =>
    (experimentalOverride ?? experimentalPlaybackEngineEnabled)
    ? PlaybackEngineKind.mediaKitExperimental
    : PlaybackEngineKind.videoPlayer;

class PlaybackEngineTrack {
  const PlaybackEngineTrack({
    required this.id,
    required this.label,
    this.language,
    this.isExternal = false,
  });

  final String id;
  final String label;
  final String? language;
  final bool isExternal;
}

class PlaybackEngineTracks {
  const PlaybackEngineTracks({
    this.audio = const [],
    this.subtitles = const [],
  });

  final List<PlaybackEngineTrack> audio;
  final List<PlaybackEngineTrack> subtitles;

  bool get hasAudioChoices => audio.length > 1;
  bool get hasSubtitleChoices => subtitles.isNotEmpty;
}

abstract interface class PlaybackEngine {
  PlaybackEngineKind get kind;
  Stream<Duration> get position;
  Stream<Duration> get duration;
  Stream<bool> get playing;
  Stream<PlaybackEngineTracks> get tracks;

  Future<void> open(PlaybackManifest manifest, {Duration startPosition});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> selectAudio(String id);
  Future<void> selectSubtitle(String? id);
  Future<void> addExternalSubtitle(Uri uri, {String? label, String? language});
  Future<void> dispose();
}

List<PlaybackEngineTrack> manifestAudioTracks(PlaybackManifest manifest) =>
    manifest.audioTracks.map(playbackEngineTrackFromManifest).toList();

List<PlaybackEngineTrack> manifestSubtitleTracks(PlaybackManifest manifest) =>
    manifest.subtitleTracks.map(playbackEngineTrackFromManifest).toList();

PlaybackEngineTrack playbackEngineTrackFromManifest(PlaybackTrack track) =>
    PlaybackEngineTrack(
      id: track.id,
      label: track.label,
      language: track.language,
    );

Duration boundedPlaybackStart(Duration requested, Duration duration) {
  if (requested <= Duration.zero || duration <= Duration.zero) {
    return Duration.zero;
  }
  return requested >= duration ? Duration.zero : requested;
}
