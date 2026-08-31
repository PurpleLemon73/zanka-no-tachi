import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'playback_domain.dart';
import 'playback_engine.dart';

class VideoPlayerPlaybackEngine implements PlaybackEngine {
  final ValueNotifier<PlaybackEngineState> _state = ValueNotifier(
    const PlaybackEngineState(),
  );
  VideoPlayerController? _controller;
  bool _disposed = false;

  @override
  PlaybackEngineKind get kind => PlaybackEngineKind.videoPlayer;
  @override
  String get diagnosticName => 'video_player';
  @override
  PlaybackCapabilities get capabilities => const PlaybackCapabilities(
    canSeek: true,
    canSetPlaybackRate: true,
    supportsHls: true,
  );
  @override
  ValueListenable<PlaybackEngineState> get state => _state;

  @override
  Future<void> open(
    PlaybackManifest manifest, {
    Duration startPosition = Duration.zero,
  }) async {
    _state.value = const PlaybackEngineState(
      phase: PlaybackEnginePhase.loading,
      isBuffering: true,
    );
    final options = VideoPlayerOptions(mixWithOthers: true);
    final controller = manifest.isLocalFile
        ? VideoPlayerController.file(
            File.fromUri(manifest.uri),
            videoPlayerOptions: options,
          )
        : VideoPlayerController.networkUrl(
            manifest.uri,
            httpHeaders: manifest.httpHeaders,
            videoPlayerOptions: options,
          );
    _controller = controller;
    try {
      await controller.initialize();
      final start = boundedPlaybackStart(
        startPosition,
        controller.value.duration,
      );
      if (start > Duration.zero) await controller.seekTo(start);
      controller.addListener(_changed);
      _changed();
    } catch (error) {
      _state.value = PlaybackEngineState(
        phase: PlaybackEnginePhase.failed,
        error: PlaybackEngineFailure(
          message: 'The video engine could not open this media.',
          severity: PlaybackEngineErrorSeverity.fatal,
          cause: error,
        ),
      );
      rethrow;
    }
  }

  void _changed() {
    if (_disposed) return;
    final value = _controller?.value;
    if (value == null) return;
    final complete =
        value.duration > Duration.zero && value.position >= value.duration;
    _state.value = PlaybackEngineState(
      phase: value.hasError
          ? PlaybackEnginePhase.failed
          : complete
          ? PlaybackEnginePhase.completed
          : PlaybackEnginePhase.ready,
      position: value.position,
      duration: value.duration,
      isPlaying: value.isPlaying,
      isBuffering: value.isBuffering,
      playbackRate: value.playbackSpeed,
      error: value.hasError
          ? PlaybackEngineFailure(
              message: value.errorDescription ?? 'Video decoding failed.',
              severity: PlaybackEngineErrorSeverity.fatal,
            )
          : null,
    );
  }

  @override
  Widget buildSurface() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }

  @override
  Future<void> play() async => _controller?.play();
  @override
  Future<void> pause() async => _controller?.pause();
  @override
  Future<void> seek(Duration position) async =>
      _controller?.seekTo(boundedSeek(position, _state.value.duration));
  @override
  Future<void> setPlaybackRate(double rate) async =>
      _controller?.setPlaybackSpeed(rate);
  @override
  Future<void> selectAudioTrack(String id) =>
      Future.error(UnsupportedError('Audio track selection is unavailable.'));
  @override
  Future<void> selectSubtitleTrack(String? id) => Future.error(
    UnsupportedError('Subtitle track selection is unavailable.'),
  );

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      controller.removeListener(_changed);
      await controller.dispose();
    }
    _state.value = const PlaybackEngineState(
      phase: PlaybackEnginePhase.disposed,
    );
    _state.dispose();
  }
}
