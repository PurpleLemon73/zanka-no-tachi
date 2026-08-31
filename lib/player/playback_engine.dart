import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'playback_domain.dart';

enum PlaybackEngineKind { videoPlayer, mediaKitExperimental }

enum PlaybackEnginePreference { automatic, videoPlayer, mediaKit }

enum PlaybackEnginePhase { idle, loading, ready, completed, failed, disposed }

enum PlaybackEngineErrorSeverity { recoverable, fatal }

class PlaybackEngineFailure {
  const PlaybackEngineFailure({
    required this.message,
    required this.severity,
    this.cause,
  });
  final String message;
  final PlaybackEngineErrorSeverity severity;
  final Object? cause;
  @override
  String toString() => message;
}

class PlaybackCapabilities {
  const PlaybackCapabilities({
    required this.canSeek,
    required this.canSetPlaybackRate,
    this.canSelectAudioTrack = false,
    this.canSelectSubtitleTrack = false,
    this.canLoadExternalSubtitle = false,
    this.supportsHls = false,
    this.supportsDash = false,
  });

  final bool canSeek;
  final bool canSetPlaybackRate;
  final bool canSelectAudioTrack;
  final bool canSelectSubtitleTrack;
  final bool canLoadExternalSubtitle;
  final bool supportsHls;
  final bool supportsDash;
}

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

class PlaybackEngineState {
  const PlaybackEngineState({
    this.phase = PlaybackEnginePhase.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.playbackRate = 1,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
    this.selectedAudioTrackId,
    this.selectedSubtitleTrackId,
    this.intrinsicAspectRatio,
    this.error,
  });

  final PlaybackEnginePhase phase;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final double playbackRate;
  final List<PlaybackEngineTrack> audioTracks;
  final List<PlaybackEngineTrack> subtitleTracks;
  final String? selectedAudioTrackId;
  final String? selectedSubtitleTrackId;

  /// Decoder-reported video width divided by height. Presentation must not
  /// infer this value from the screen dimensions.
  final double? intrinsicAspectRatio;
  final PlaybackEngineFailure? error;

  PlaybackEngineState copyWith({
    PlaybackEnginePhase? phase,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isBuffering,
    double? playbackRate,
    List<PlaybackEngineTrack>? audioTracks,
    List<PlaybackEngineTrack>? subtitleTracks,
    String? selectedAudioTrackId,
    String? selectedSubtitleTrackId,
    double? intrinsicAspectRatio,
    PlaybackEngineFailure? error,
    bool clearError = false,
    bool clearSelectedAudioTrack = false,
    bool clearSelectedSubtitleTrack = false,
    bool clearIntrinsicAspectRatio = false,
  }) => PlaybackEngineState(
    phase: phase ?? this.phase,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    isPlaying: isPlaying ?? this.isPlaying,
    isBuffering: isBuffering ?? this.isBuffering,
    playbackRate: playbackRate ?? this.playbackRate,
    audioTracks: audioTracks ?? this.audioTracks,
    subtitleTracks: subtitleTracks ?? this.subtitleTracks,
    selectedAudioTrackId: clearSelectedAudioTrack
        ? null
        : selectedAudioTrackId ?? this.selectedAudioTrackId,
    selectedSubtitleTrackId: clearSelectedSubtitleTrack
        ? null
        : selectedSubtitleTrackId ?? this.selectedSubtitleTrackId,
    intrinsicAspectRatio: clearIntrinsicAspectRatio
        ? null
        : intrinsicAspectRatio ?? this.intrinsicAspectRatio,
    error: clearError ? null : error ?? this.error,
  );
}

abstract interface class PlaybackEngine {
  PlaybackEngineKind get kind;
  String get diagnosticName;
  PlaybackCapabilities get capabilities;
  ValueListenable<PlaybackEngineState> get state;
  Widget buildSurface();
  Future<void> open(PlaybackManifest manifest, {Duration startPosition});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setPlaybackRate(double rate);
  Future<void> selectAudioTrack(String id);
  Future<void> selectSubtitleTrack(String? id);
  Future<void> dispose();
}

typedef PlaybackEngineBuilder = PlaybackEngine Function();

class PlaybackEngineSelection {
  const PlaybackEngineSelection({required this.engine, this.fallbackReason});
  final PlaybackEngine engine;
  final String? fallbackReason;
}

class PlaybackEngineRegistry {
  const PlaybackEngineRegistry({required this.productionBuilder});
  final PlaybackEngineBuilder productionBuilder;

  PlaybackEngineSelection create([
    PlaybackEnginePreference preference = PlaybackEnginePreference.automatic,
  ]) {
    if (preference == PlaybackEnginePreference.mediaKit) {
      return PlaybackEngineSelection(
        engine: productionBuilder(),
        fallbackReason:
            'media_kit is not production-approved in this build; using video_player.',
      );
    }
    return PlaybackEngineSelection(engine: productionBuilder());
  }
}

bool shouldShowAudioControl(
  PlaybackCapabilities capabilities,
  PlaybackEngineState state,
) => capabilities.canSelectAudioTrack && state.audioTracks.length > 1;

bool shouldShowSubtitleControl(
  PlaybackCapabilities capabilities,
  PlaybackEngineState state,
) => capabilities.canSelectSubtitleTrack && state.subtitleTracks.isNotEmpty;

Duration boundedPlaybackStart(Duration requested, Duration duration) {
  if (requested <= Duration.zero || duration <= Duration.zero) {
    return Duration.zero;
  }
  return requested >= duration ? Duration.zero : requested;
}

Duration boundedSeek(Duration requested, Duration duration) {
  if (requested <= Duration.zero) return Duration.zero;
  if (duration > Duration.zero && requested > duration) return duration;
  return requested;
}
