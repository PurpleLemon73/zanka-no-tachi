import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/user_state.dart';
import 'playback_engine_preference.dart';
import 'video_display_mode.dart';

enum PlaybackSourceCapability {
  metadataOnly,
  playbackCapable,
  temporarilyUnavailable,
  unsupported,
}

enum PlaybackErrorKind {
  sourceUnavailable,
  manifestInvalid,
  unsupportedFormat,
  localFileMissing,
  decoderFailure,
}

class PlaybackException implements Exception {
  const PlaybackException(this.kind, this.message, [this.cause]);
  final PlaybackErrorKind kind;
  final String message;
  final Object? cause;
  @override
  String toString() => message;
}

class PlaybackTrack {
  const PlaybackTrack({required this.id, required this.label, this.language});
  final String id;
  final String label;
  final String? language;
}

class PlaybackPreferences {
  const PlaybackPreferences({
    this.seekStepSeconds = 10,
    this.autoplay = true,
    this.autoplayNext = false,
    this.speed = 1,
    this.preferredAudioLanguage,
    this.preferredSubtitleLanguage,
    this.videoDisplayMode = VideoDisplayMode.automatic,
    this.enginePreference = PlaybackEnginePreference.automatic,
  });
  final int seekStepSeconds;
  final bool autoplay;
  final bool autoplayNext;
  final double speed;
  final String? preferredAudioLanguage;
  final String? preferredSubtitleLanguage;
  final VideoDisplayMode videoDisplayMode;
  final PlaybackEnginePreference enginePreference;

  PlaybackPreferences copyWith({
    int? seekStepSeconds,
    bool? autoplay,
    bool? autoplayNext,
    double? speed,
    String? preferredAudioLanguage,
    String? preferredSubtitleLanguage,
    VideoDisplayMode? videoDisplayMode,
    PlaybackEnginePreference? enginePreference,
    bool clearSubtitleLanguage = false,
  }) => PlaybackPreferences(
    seekStepSeconds: seekStepSeconds ?? this.seekStepSeconds,
    autoplay: autoplay ?? this.autoplay,
    autoplayNext: autoplayNext ?? this.autoplayNext,
    speed: speed ?? this.speed,
    preferredAudioLanguage:
        preferredAudioLanguage ?? this.preferredAudioLanguage,
    preferredSubtitleLanguage: clearSubtitleLanguage
        ? null
        : preferredSubtitleLanguage ?? this.preferredSubtitleLanguage,
    videoDisplayMode: videoDisplayMode ?? this.videoDisplayMode,
    enginePreference: enginePreference ?? this.enginePreference,
  );

  Map<String, Object?> toJson() => {
    'seekStepSeconds': seekStepSeconds,
    'autoplay': autoplay,
    'autoplayNext': autoplayNext,
    'speed': speed,
    'preferredAudioLanguage': preferredAudioLanguage,
    'preferredSubtitleLanguage': preferredSubtitleLanguage,
    'videoDisplayMode': videoDisplayMode.toJson(),
    'enginePreference': enginePreference.name,
  };

  /// Portable playback behavior only. Display geometry and engine selection
  /// stay device-local because devices can have different screens and engine
  /// availability.
  Map<String, Object?> toBackupJson() => {
    'seekStepSeconds': seekStepSeconds,
    'autoplay': autoplay,
    'autoplayNext': autoplayNext,
    'speed': speed,
    'preferredAudioLanguage': preferredAudioLanguage,
    'preferredSubtitleLanguage': preferredSubtitleLanguage,
  };

  factory PlaybackPreferences.fromJson(Map<String, dynamic> json) =>
      PlaybackPreferences(
        seekStepSeconds: json['seekStepSeconds'] as int,
        autoplay: json['autoplay'] as bool,
        autoplayNext: json['autoplayNext'] as bool? ?? false,
        speed: (json['speed'] as num).toDouble(),
        preferredAudioLanguage: json['preferredAudioLanguage'] as String?,
        preferredSubtitleLanguage: json['preferredSubtitleLanguage'] as String?,
        videoDisplayMode: VideoDisplayMode.fromJson(
          json['videoDisplayMode'] is Map
              ? Map<String, dynamic>.from(json['videoDisplayMode'] as Map)
              : null,
        ),
        enginePreference: PlaybackEnginePreference.parse(
          json['enginePreference'],
        ),
      );
}

class PlaybackSessionRequest {
  const PlaybackSessionRequest({
    required this.mediaId,
    required this.episodeId,
    this.binding,
    this.startAtBeginning = false,
  });
  final CanonicalMediaId mediaId;
  final CanonicalEpisodeId episodeId;
  final EpisodeSourceBinding? binding;
  final bool startAtBeginning;
}

class PlaybackManifest {
  const PlaybackManifest({
    required this.sourceName,
    required this.binding,
    required this.uri,
    this.isLocalFile = true,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.httpHeaders = const {},
  });
  final String sourceName;
  final EpisodeSourceBinding binding;
  final Uri uri;
  final bool isLocalFile;
  final List<PlaybackTrack> audioTracks;
  final List<PlaybackTrack> subtitleTracks;
  final Map<String, String> httpHeaders;
}

class PlaybackSession {
  const PlaybackSession({
    required this.mediaId,
    required this.episode,
    required this.manifest,
    required this.startPosition,
    required this.preferences,
    this.resume,
  });
  final CanonicalMediaId mediaId;
  final CanonicalEpisode episode;
  final PlaybackManifest manifest;
  final Duration startPosition;
  final PlaybackPreferences preferences;
  final AnimeSourcePlaybackResume? resume;
}
