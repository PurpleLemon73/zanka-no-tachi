import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/user_state.dart';

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
  });
  final int seekStepSeconds;
  final bool autoplay;
  final bool autoplayNext;
  final double speed;
  final String? preferredAudioLanguage;
  final String? preferredSubtitleLanguage;

  PlaybackPreferences copyWith({
    int? seekStepSeconds,
    bool? autoplay,
    bool? autoplayNext,
    double? speed,
    String? preferredAudioLanguage,
    String? preferredSubtitleLanguage,
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
  );

  Map<String, Object?> toJson() => {
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
      );
}

class PlaybackSessionRequest {
  const PlaybackSessionRequest({
    required this.mediaId,
    required this.episodeId,
    this.binding,
  });
  final CanonicalMediaId mediaId;
  final CanonicalEpisodeId episodeId;
  final EpisodeSourceBinding? binding;
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
