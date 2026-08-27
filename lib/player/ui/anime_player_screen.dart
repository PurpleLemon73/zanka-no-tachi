import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../canonical/domain/bindings.dart';
import '../playback_domain.dart';
import '../playback_repository.dart';
import '../playback_source.dart';
import '../android_media_bridge.dart';

enum TvPlayerCommand { toggle, play, pause, seekBackward, seekForward, reveal }

TvPlayerCommand? tvPlayerCommandFor(LogicalKeyboardKey key) {
  if (key == LogicalKeyboardKey.select ||
      key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.mediaPlayPause) {
    return TvPlayerCommand.toggle;
  }
  if (key == LogicalKeyboardKey.mediaPlay) return TvPlayerCommand.play;
  if (key == LogicalKeyboardKey.mediaPause) return TvPlayerCommand.pause;
  if (key == LogicalKeyboardKey.arrowLeft ||
      key == LogicalKeyboardKey.mediaRewind) {
    return TvPlayerCommand.seekBackward;
  }
  if (key == LogicalKeyboardKey.arrowRight ||
      key == LogicalKeyboardKey.mediaFastForward) {
    return TvPlayerCommand.seekForward;
  }
  if (key == LogicalKeyboardKey.arrowUp ||
      key == LogicalKeyboardKey.arrowDown) {
    return TvPlayerCommand.reveal;
  }
  return null;
}

class AnimePlayerScreen extends StatefulWidget {
  const AnimePlayerScreen({
    super.key,
    required this.repository,
    required this.request,
    this.isTv = false,
    this.mediaBridge,
  });
  final PlaybackRepository repository;
  final PlaybackSessionRequest request;
  final bool isTv;
  final AndroidMediaBridge? mediaBridge;

  @override
  State<AnimePlayerScreen> createState() => _AnimePlayerScreenState();
}

class _AnimePlayerScreenState extends State<AnimePlayerScreen>
    with WidgetsBindingObserver {
  PlaybackSession? session;
  VideoPlayerController? controller;
  Object? error;
  bool controlsVisible = true;
  bool fullscreen = false;
  Timer? hideTimer;
  Timer? saveTimer;
  bool handledNaturalEnd = false;
  late final AndroidMediaBridge mediaBridge =
      widget.mediaBridge ?? AndroidMediaBridge();
  final FocusNode remoteFocus = FocusNode(debugLabel: 'TV player remote');
  int lastNativeUpdateSecond = -1;
  bool? lastNativePlaying;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mediaBridge.onCommand = _handleMediaCommand;
    unawaited(_open());
  }

  Future<void> _open({
    bool allowMediaRetry = true,
    bool showRecovered = false,
  }) async {
    final previous = controller;
    controller = null;
    if (previous != null) {
      previous.removeListener(_videoChanged);
      await previous.dispose();
    }
    setState(() {
      error = null;
      session = null;
    });
    PlaybackSession? opened;
    VideoPlayerController? video;
    try {
      opened = await widget.repository.open(widget.request);
      video = opened.manifest.isLocalFile
          ? VideoPlayerController.file(File.fromUri(opened.manifest.uri))
          : VideoPlayerController.networkUrl(
              opened.manifest.uri,
              httpHeaders: opened.manifest.httpHeaders,
            );
      await video.initialize();
      final start = opened.startPosition >= video.value.duration
          ? Duration.zero
          : opened.startPosition;
      if (start > Duration.zero) await video.seekTo(start);
      await video.setPlaybackSpeed(opened.preferences.speed);
      video.addListener(_videoChanged);
      await mediaBridge.activate(
        title: opened.episode.label.rawLabel,
        episode: opened.manifest.sourceName,
      );
      await mediaBridge.update(
        playing: video.value.isPlaying,
        position: video.value.position,
        duration: video.value.duration,
      );
      if (opened.preferences.autoplay) await _play(video);
      if (!mounted) {
        await video.dispose();
        return;
      }
      setState(() {
        session = opened;
        controller = video;
      });
      if (showRecovered) {
        final observer = widget.repository.sources.resolver(
          opened.manifest.binding.providerId,
        );
        if (observer is FreshPlaybackRetryObserver) {
          (observer as FreshPlaybackRetryObserver)
              .recordMediaInitializationRecovery(opened.manifest.binding);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The source refreshed successfully.')),
        );
      }
      _scheduleHide();
    } on Object catch (value) {
      await video?.dispose();
      if (allowMediaRetry && opened != null && !opened.manifest.isLocalFile) {
        final observer = widget.repository.sources.resolver(
          opened.manifest.binding.providerId,
        );
        if (observer is FreshPlaybackRetryObserver) {
          (observer as FreshPlaybackRetryObserver)
              .recordMediaInitializationFailure(opened.manifest.binding);
        }
        await _open(allowMediaRetry: false, showRecovered: true);
        return;
      }
      if (mounted) setState(() => error = value);
    }
  }

  void _videoChanged() {
    if (!mounted) return;
    if (controller?.value.hasError ?? false) {
      setState(() {
        error = PlaybackException(
          PlaybackErrorKind.decoderFailure,
          controller!.value.errorDescription ?? 'Video decoding failed.',
        );
      });
      return;
    }
    setState(() {});
    saveTimer ??= Timer(const Duration(seconds: 5), () {
      saveTimer = null;
      unawaited(_flush());
    });
    final value = controller?.value;
    if (value != null &&
        (value.position.inSeconds != lastNativeUpdateSecond ||
            value.isPlaying != lastNativePlaying)) {
      lastNativeUpdateSecond = value.position.inSeconds;
      lastNativePlaying = value.isPlaying;
      unawaited(
        mediaBridge.update(
          playing: value.isPlaying,
          position: value.position,
          duration: value.duration,
        ),
      );
    }
    if (!handledNaturalEnd &&
        value != null &&
        value.duration > Duration.zero &&
        value.position >= value.duration) {
      handledNaturalEnd = true;
      unawaited(_naturalEnd());
    }
  }

  Future<void> _naturalEnd() async {
    await _flush();
    final current = session;
    if (current == null) return;
    final next = await widget.repository.autoplayNext(current);
    if (next == null || !mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AnimePlayerScreen(
          repository: widget.repository,
          isTv: widget.isTv,
          request: PlaybackSessionRequest(
            mediaId: current.mediaId,
            episodeId: next.episode.id,
          ),
        ),
      ),
    );
  }

  void _scheduleHide() {
    hideTimer?.cancel();
    if (controller?.value.isPlaying ?? false) {
      hideTimer = Timer(Duration(seconds: widget.isTv ? 5 : 3), () {
        if (mounted) setState(() => controlsVisible = false);
      });
    }
  }

  Future<void> _flush() async {
    final current = session;
    final video = controller;
    if (current == null || video == null || !video.value.isInitialized) return;
    await widget.repository.savePosition(
      current,
      video.value.position,
      video.value.duration,
    );
  }

  Future<void> _seek(Duration delta) async {
    final video = controller!;
    final target = video.value.position + delta;
    await video.seekTo(
      target < Duration.zero
          ? Duration.zero
          : target > video.value.duration
          ? video.value.duration
          : target,
    );
    _scheduleHide();
  }

  Future<void> _play([VideoPlayerController? target]) async {
    final video = target ?? controller;
    if (video == null) return;
    if (await mediaBridge.requestAudioFocus()) await video.play();
    _scheduleHide();
  }

  Future<void> _pause() async {
    await controller?.pause();
    if (mounted && widget.isTv) setState(() => controlsVisible = true);
  }

  Future<void> _togglePlayback() async {
    if (controller?.value.isPlaying ?? false) {
      await _pause();
    } else {
      await _play();
    }
  }

  void _handleMediaCommand(AndroidMediaCommand command) {
    switch (command) {
      case AndroidMediaCommand.play:
        unawaited(_play());
        break;
      case AndroidMediaCommand.pause:
        unawaited(_pause());
        break;
      case AndroidMediaCommand.toggle:
        unawaited(_togglePlayback());
        break;
      case AndroidMediaCommand.seekBackward:
        if (controller != null && session != null) {
          unawaited(
            _seek(Duration(seconds: -session!.preferences.seekStepSeconds)),
          );
        }
        break;
      case AndroidMediaCommand.seekForward:
        if (controller != null && session != null) {
          unawaited(
            _seek(Duration(seconds: session!.preferences.seekStepSeconds)),
          );
        }
        break;
    }
  }

  KeyEventResult _handleRemoteKey(FocusNode _, KeyEvent event) {
    if (!widget.isTv || event is! KeyDownEvent) return KeyEventResult.ignored;
    final command = tvPlayerCommandFor(event.logicalKey);
    if (command == null) return KeyEventResult.ignored;
    setState(() => controlsVisible = true);
    switch (command) {
      case TvPlayerCommand.toggle:
        unawaited(_togglePlayback());
        break;
      case TvPlayerCommand.play:
        unawaited(_play());
        break;
      case TvPlayerCommand.pause:
        unawaited(_pause());
        break;
      case TvPlayerCommand.seekBackward:
        if (controller != null && session != null) {
          unawaited(
            _seek(Duration(seconds: -session!.preferences.seekStepSeconds)),
          );
        }
        break;
      case TvPlayerCommand.seekForward:
        if (controller != null && session != null) {
          unawaited(
            _seek(Duration(seconds: session!.preferences.seekStepSeconds)),
          );
        }
        break;
      case TvPlayerCommand.reveal:
        _scheduleHide();
        break;
    }
    return KeyEventResult.handled;
  }

  Future<void> _toggleFullscreen() async {
    fullscreen = !fullscreen;
    if (fullscreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await _restoreSystemUi();
    }
    if (mounted) setState(() {});
  }

  Future<void> _restoreSystemUi() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(controller?.pause());
      unawaited(_flush());
      unawaited(mediaBridge.deactivate());
    } else if (state == AppLifecycleState.resumed && session != null) {
      unawaited(_restoreMediaSession());
    }
  }

  Future<void> _restoreMediaSession() async {
    final current = session;
    final video = controller;
    if (current == null || video == null) return;
    await mediaBridge.activate(
      title: current.episode.label.rawLabel,
      episode: current.manifest.sourceName,
    );
    await mediaBridge.update(
      playing: video.value.isPlaying,
      position: video.value.position,
      duration: video.value.duration,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    hideTimer?.cancel();
    saveTimer?.cancel();
    controller?.removeListener(_videoChanged);
    remoteFocus.dispose();
    unawaited(_flush());
    unawaited(controller?.dispose());
    unawaited(mediaBridge.deactivate());
    if (fullscreen) unawaited(_restoreSystemUi());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !fullscreen && (!widget.isTv || !controlsVisible),
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && fullscreen) unawaited(_toggleFullscreen());
      if (!didPop && !fullscreen && widget.isTv && controlsVisible) {
        setState(() => controlsVisible = false);
      }
    },
    child: Scaffold(
      backgroundColor: Colors.black,
      appBar: fullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(session?.episode.label.rawLabel ?? 'Player'),
            ),
      body: Focus(
        focusNode: remoteFocus,
        autofocus: widget.isTv,
        onKeyEvent: _handleRemoteKey,
        child: error != null
            ? _ErrorState(
                error: error!,
                retry: () => _open(),
                alternate: _openAlternate,
              )
            : controller == null || session == null
            ? const Center(child: CircularProgressIndicator())
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() => controlsVisible = !controlsVisible);
                  if (controlsVisible) _scheduleHide();
                },
                onDoubleTapDown: (details) {
                  final width = MediaQuery.sizeOf(context).width;
                  final seconds = session!.preferences.seekStepSeconds;
                  unawaited(
                    _seek(
                      Duration(
                        seconds: details.localPosition.dx < width / 2
                            ? -seconds
                            : seconds,
                      ),
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: VideoPlayer(controller!),
                      ),
                    ),
                    if (controller!.value.isBuffering)
                      const Center(child: CircularProgressIndicator()),
                    AnimatedOpacity(
                      opacity: controlsVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: IgnorePointer(
                        ignoring: !controlsVisible,
                        child: _Controls(
                          session: session!,
                          controller: controller!,
                          fullscreen: fullscreen,
                          onToggleFullscreen: _toggleFullscreen,
                          onSeek: _seek,
                          onSources: _showSources,
                          onEpisodes: _showEpisodes,
                          onAdjacent: _openAdjacent,
                          onPreferences: _showPreferences,
                          onTogglePlayback: _togglePlayback,
                          isTv: widget.isTv,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    ),
  );

  Future<void> _replace(EpisodeSourceBinding binding) async {
    await _flush();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        settings: RouteSettings(
          name:
              '/player/${session!.mediaId.value}/${session!.episode.id.value}',
        ),
        builder: (_) => AnimePlayerScreen(
          repository: widget.repository,
          isTv: widget.isTv,
          request: PlaybackSessionRequest(
            mediaId: session!.mediaId,
            episodeId: session!.episode.id,
            binding: binding,
          ),
        ),
      ),
    );
  }

  Future<void> _showSources() async {
    final values = (await widget.repository.episodes(
      session!.mediaId,
    )).where((item) => item.episode.id == session!.episode.id).first;
    if (!mounted) return;
    final chosen = await showModalBottomSheet<EpisodeSourceBinding>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Switch source'),
              subtitle: Text(
                'Different encodes do not share exact timestamps. A new source starts at its own saved position or 0:00.',
              ),
            ),
            for (final binding in values.bindings)
              ListTile(
                enabled: values.openableBindings.contains(binding),
                leading: Icon(
                  binding.providerId == session!.manifest.binding.providerId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(binding.providerId.value),
                subtitle: Text(
                  values.playableBindings.contains(binding)
                      ? 'Ready to play'
                      : values.retryableBindings.contains(binding)
                      ? 'Available to retry'
                      : 'Metadata only',
                ),
                onTap: values.openableBindings.contains(binding)
                    ? () => Navigator.pop(context, binding)
                    : null,
              ),
          ],
        ),
      ),
    );
    if (chosen != null &&
        chosen.providerId != session!.manifest.binding.providerId) {
      await _replace(chosen);
    }
  }

  Future<void> _showEpisodes() async {
    final episodes = await widget.repository.episodes(session!.mediaId);
    if (!mounted) return;
    final chosen = await showModalBottomSheet<PlaybackEpisodeAvailability>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        children: [
          const ListTile(title: Text('Episodes')),
          for (final value in episodes)
            ListTile(
              selected: value.episode.id == session!.episode.id,
              enabled: value.openableBindings.isNotEmpty,
              title: Text(value.episode.label.rawLabel),
              subtitle: Text(
                value.openableBindings.isEmpty
                    ? 'No playable source'
                    : '${value.playableBindings.length} source(s)',
              ),
              onTap: value.openableBindings.isEmpty
                  ? null
                  : () => Navigator.pop(context, value),
            ),
        ],
      ),
    );
    if (chosen != null && chosen.episode.id != session!.episode.id && mounted) {
      await _flush();
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AnimePlayerScreen(
            repository: widget.repository,
            isTv: widget.isTv,
            request: PlaybackSessionRequest(
              mediaId: session!.mediaId,
              episodeId: chosen.episode.id,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openAdjacent(int direction) async {
    final value = await widget.repository.adjacent(session!, direction);
    if (value == null || value.openableBindings.isEmpty || !mounted) return;
    await _flush();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AnimePlayerScreen(
          repository: widget.repository,
          isTv: widget.isTv,
          request: PlaybackSessionRequest(
            mediaId: session!.mediaId,
            episodeId: value.episode.id,
          ),
        ),
      ),
    );
  }

  Future<void> _openAlternate() async {
    final values = (await widget.repository.episodes(
      widget.request.mediaId,
    )).where((item) => item.episode.id == widget.request.episodeId).firstOrNull;
    final current = widget.request.binding;
    final alternate = values?.openableBindings
        .where(
          (value) =>
              current == null ||
              value.providerId != current.providerId ||
              value.externalId != current.externalId,
        )
        .firstOrNull;
    if (alternate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No alternate source is available.')),
        );
      }
      return;
    }
    await _replace(alternate);
  }

  Future<void> _showPreferences() async {
    final values = const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    var preferences = session!.preferences;
    final speed = await showModalBottomSheet<double>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text('Playback settings'),
              subtitle: Text(
                'This player uses the file’s default audio track. Track selection is shown only when the platform can control it reliably.',
              ),
            ),
            SwitchListTile(
              title: const Text('Play next episode automatically'),
              subtitle: const Text('Only after this episode ends naturally'),
              value: preferences.autoplayNext,
              onChanged: (value) async {
                preferences = preferences.copyWith(autoplayNext: value);
                await widget.repository.savePreferences(preferences);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            for (final value in values)
              ListTile(
                title: Text('$value× speed'),
                trailing: controller!.value.playbackSpeed == value
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
    if (speed != null) {
      await controller!.setPlaybackSpeed(speed);
      final preferences = session!.preferences.copyWith(speed: speed);
      await widget.repository.savePreferences(preferences);
    }
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.session,
    required this.controller,
    required this.fullscreen,
    required this.onToggleFullscreen,
    required this.onSeek,
    required this.onSources,
    required this.onEpisodes,
    required this.onAdjacent,
    required this.onPreferences,
    required this.onTogglePlayback,
    required this.isTv,
  });
  final PlaybackSession session;
  final VideoPlayerController controller;
  final bool fullscreen;
  final Future<void> Function() onToggleFullscreen;
  final Future<void> Function(Duration) onSeek;
  final Future<void> Function() onSources;
  final Future<void> Function() onEpisodes;
  final Future<void> Function(int) onAdjacent;
  final Future<void> Function() onPreferences;
  final Future<void> Function() onTogglePlayback;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final step = session.preferences.seekStepSeconds;
    return ColoredBox(
      color: Colors.black45,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${session.episode.label.rawLabel} · ${session.manifest.sourceName}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  tooltip: 'Episodes',
                  onPressed: onEpisodes,
                  icon: const Icon(Icons.playlist_play, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Source',
                  onPressed: onSources,
                  icon: const Icon(Icons.source, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: onPreferences,
                  icon: const Icon(Icons.settings, color: Colors.white),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Previous episode',
                  onPressed: () => onAdjacent(-1),
                  icon: const Icon(Icons.skip_previous, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Back $step seconds',
                  onPressed: () => onSeek(Duration(seconds: -step)),
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                ),
                IconButton.filled(
                  tooltip: value.isPlaying ? 'Pause' : 'Play',
                  onPressed: onTogglePlayback,
                  iconSize: isTv ? 42 : 24,
                  icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  tooltip: 'Forward $step seconds',
                  onPressed: () => onSeek(Duration(seconds: step)),
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Next episode',
                  onPressed: () => onAdjacent(1),
                  icon: const Icon(Icons.skip_next, color: Colors.white),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  _clock(value.position),
                  style: const TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.all(12),
                    colors: const VideoProgressColors(
                      playedColor: Color(0xffff6d3a),
                      bufferedColor: Colors.white38,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
                Text(
                  _clock(value.duration),
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  tooltip: fullscreen ? 'Exit fullscreen' : 'Fullscreen',
                  onPressed: onToggleFullscreen,
                  icon: Icon(
                    fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.retry,
    required this.alternate,
  });
  final Object error;
  final Future<void> Function() retry;
  final Future<void> Function() alternate;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Text(
            _playbackErrorMessage(error),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: retry, child: const Text('Retry')),
          TextButton.icon(
            onPressed: alternate,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Try another source'),
          ),
        ],
      ),
    ),
  );
}

String _playbackErrorMessage(Object error) => switch (error) {
  PlaybackException(kind: PlaybackErrorKind.sourceUnavailable) =>
    'This source is temporarily unreachable. Retry, or choose another source.',
  PlaybackException(kind: PlaybackErrorKind.manifestInvalid) =>
    'This episode page has changed and cannot be played right now. Retry later or choose another source.',
  PlaybackException(kind: PlaybackErrorKind.unsupportedFormat) =>
    'This episode uses a media format Zanka cannot play on this device.',
  PlaybackException(kind: PlaybackErrorKind.localFileMissing) =>
    'The local video is missing. Repair it from Media Details.',
  PlaybackException(kind: PlaybackErrorKind.decoderFailure) =>
    'This video could not start on this device. Retry for a fresh source or choose another source.',
  _ =>
    'The player could not open this episode. Retry or choose another source.',
};

String _clock(Duration value) {
  final hours = value.inHours;
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '${value.inMinutes}:$seconds';
}
