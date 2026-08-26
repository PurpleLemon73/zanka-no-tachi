import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../canonical/domain/bindings.dart';
import '../playback_domain.dart';
import '../playback_repository.dart';

class AnimePlayerScreen extends StatefulWidget {
  const AnimePlayerScreen({
    super.key,
    required this.repository,
    required this.request,
  });
  final PlaybackRepository repository;
  final PlaybackSessionRequest request;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_open());
  }

  Future<void> _open() async {
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
    try {
      final opened = await widget.repository.open(widget.request);
      final video = opened.manifest.isLocalFile
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
      if (opened.preferences.autoplay) await video.play();
      if (!mounted) {
        await video.dispose();
        return;
      }
      setState(() {
        session = opened;
        controller = video;
      });
      _scheduleHide();
    } on Object catch (value) {
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
      hideTimer = Timer(const Duration(seconds: 3), () {
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
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    hideTimer?.cancel();
    saveTimer?.cancel();
    controller?.removeListener(_videoChanged);
    unawaited(_flush());
    unawaited(controller?.dispose());
    if (fullscreen) unawaited(_restoreSystemUi());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !fullscreen,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && fullscreen) unawaited(_toggleFullscreen());
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
      body: error != null
          ? _ErrorState(error: error!, retry: _open)
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
                      ),
                    ),
                  ),
                ],
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
                enabled: values.playableBindings.contains(binding),
                leading: Icon(
                  binding.providerId == session!.manifest.binding.providerId
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(binding.providerId.value),
                subtitle: Text(
                  values.playableBindings.contains(binding)
                      ? 'Playback capable'
                      : 'Metadata only',
                ),
                onTap: values.playableBindings.contains(binding)
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
              enabled: value.playableBindings.isNotEmpty,
              title: Text(value.episode.label.rawLabel),
              subtitle: Text(
                value.playableBindings.isEmpty
                    ? 'No playable source'
                    : '${value.playableBindings.length} source(s)',
              ),
              onTap: value.playableBindings.isEmpty
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
    if (value == null || value.playableBindings.isEmpty || !mounted) return;
    await _flush();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AnimePlayerScreen(
          repository: widget.repository,
          request: PlaybackSessionRequest(
            mediaId: session!.mediaId,
            episodeId: value.episode.id,
          ),
        ),
      ),
    );
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
                  onPressed: value.isPlaying
                      ? controller.pause
                      : controller.play,
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
  const _ErrorState({required this.error, required this.retry});
  final Object error;
  final Future<void> Function() retry;
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
            error is PlaybackException
                ? (error as PlaybackException).message
                : 'The player could not open this episode. Check the local file or choose another source.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: retry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

String _clock(Duration value) {
  final hours = value.inHours;
  final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '${value.inMinutes}:$seconds';
}
