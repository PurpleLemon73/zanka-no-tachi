import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../canonical/domain/bindings.dart';
import '../playback_domain.dart';
import '../playback_engine.dart';
import '../playback_repository.dart';
import '../playback_source.dart';
import '../video_player_playback_engine.dart';
import '../android_media_bridge.dart';
import '../video_display_mode.dart';

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
    this.engineRegistry,
  });
  final PlaybackRepository repository;
  final PlaybackSessionRequest request;
  final bool isTv;
  final AndroidMediaBridge? mediaBridge;
  final PlaybackEngineRegistry? engineRegistry;

  @override
  State<AnimePlayerScreen> createState() => _AnimePlayerScreenState();
}

class _AnimePlayerScreenState extends State<AnimePlayerScreen>
    with WidgetsBindingObserver {
  PlaybackSession? session;
  PlaybackEngine? engine;
  Object? error;
  bool controlsVisible = true;
  bool fullscreen = false;
  Timer? hideTimer;
  Timer? saveTimer;
  bool handledNaturalEnd = false;
  bool completionVisible = false;
  PlaybackEpisodeAvailability? previousEpisode;
  PlaybackEpisodeAvailability? nextEpisode;
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
    final previous = engine;
    engine = null;
    if (previous != null) {
      await previous.dispose();
    }
    setState(() {
      error = null;
      session = null;
      completionVisible = false;
      previousEpisode = null;
      nextEpisode = null;
      handledNaturalEnd = false;
    });
    PlaybackSession? opened;
    PlaybackEngine? player;
    try {
      opened = await widget.repository.open(widget.request);
      final registry =
          widget.engineRegistry ??
          PlaybackEngineRegistry(
            productionBuilder: VideoPlayerPlaybackEngine.new,
          );
      player = registry.create().engine;
      await player.open(opened.manifest, startPosition: opened.startPosition);
      await player.setPlaybackRate(opened.preferences.speed);
      player.state.addListener(_engineChanged);
      previousEpisode = await widget.repository.adjacent(opened, -1);
      nextEpisode = await widget.repository.adjacent(opened, 1);
      await mediaBridge.activate(
        title: opened.episode.label.rawLabel,
        episode: opened.manifest.sourceName,
      );
      await mediaBridge.update(
        playing: player.state.value.isPlaying,
        position: player.state.value.position,
        duration: player.state.value.duration,
      );
      if (opened.preferences.autoplay) await _play(player);
      if (!mounted) {
        await player.dispose();
        return;
      }
      setState(() {
        session = opened;
        engine = player;
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
      await player?.dispose();
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

  void _engineChanged() {
    if (!mounted) return;
    final value = engine?.state.value;
    if (value?.phase == PlaybackEnginePhase.failed) {
      setState(() {
        error = PlaybackException(
          PlaybackErrorKind.decoderFailure,
          value?.error?.toString() ?? 'Video decoding failed.',
        );
      });
      return;
    }
    setState(() {});
    saveTimer ??= Timer(const Duration(seconds: 5), () {
      saveTimer = null;
      unawaited(_flush());
    });
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
    if (!handledNaturalEnd && value?.phase == PlaybackEnginePhase.completed) {
      handledNaturalEnd = true;
      unawaited(_naturalEnd());
    }
  }

  Future<void> _naturalEnd() async {
    await _flush();
    final current = session;
    if (current == null) return;
    if (!mounted) return;
    setState(() {
      completionVisible = true;
      controlsVisible = true;
    });
    if (current.preferences.autoplayNext &&
        nextEpisode?.openableBindings.isNotEmpty == true) {
      await _openAdjacent(1);
    }
  }

  void _scheduleHide() {
    hideTimer?.cancel();
    if (engine?.state.value.isPlaying ?? false) {
      hideTimer = Timer(Duration(seconds: widget.isTv ? 5 : 3), () {
        if (mounted) setState(() => controlsVisible = false);
      });
    }
  }

  Future<void> _flush() async {
    final current = session;
    final player = engine;
    if (current == null || player == null) return;
    final value = player.state.value;
    await widget.repository.savePosition(
      current,
      value.position,
      value.duration,
    );
  }

  Future<void> _seek(Duration delta) async {
    final player = engine!;
    await player.seek(player.state.value.position + delta);
    _scheduleHide();
  }

  Future<void> _play([PlaybackEngine? target]) async {
    final player = target ?? engine;
    if (player == null) return;
    if (await mediaBridge.requestAudioFocus()) await player.play();
    _scheduleHide();
  }

  Future<void> _pause() async {
    await engine?.pause();
    if (mounted && widget.isTv) setState(() => controlsVisible = true);
  }

  Future<void> _togglePlayback() async {
    if (engine?.state.value.isPlaying ?? false) {
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
        if (engine != null && session != null) {
          unawaited(
            _seek(Duration(seconds: -session!.preferences.seekStepSeconds)),
          );
        }
        break;
      case AndroidMediaCommand.seekForward:
        if (engine != null && session != null) {
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
    final wasVisible = controlsVisible;
    setState(() => controlsVisible = true);
    if (wasVisible &&
        {
          LogicalKeyboardKey.arrowLeft,
          LogicalKeyboardKey.arrowRight,
          LogicalKeyboardKey.arrowUp,
          LogicalKeyboardKey.arrowDown,
          LogicalKeyboardKey.select,
          LogicalKeyboardKey.enter,
        }.contains(event.logicalKey)) {
      _scheduleHide();
      return KeyEventResult.ignored;
    }
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
        if (engine != null && session != null) {
          unawaited(
            _seek(Duration(seconds: -session!.preferences.seekStepSeconds)),
          );
        }
        break;
      case TvPlayerCommand.seekForward:
        if (engine != null && session != null) {
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
      unawaited(engine?.pause());
      unawaited(_flush());
      unawaited(mediaBridge.deactivate());
    } else if (state == AppLifecycleState.resumed && session != null) {
      unawaited(_restoreMediaSession());
    }
  }

  Future<void> _restoreMediaSession() async {
    final current = session;
    final player = engine;
    if (current == null || player == null) return;
    final value = player.state.value;
    await mediaBridge.activate(
      title: current.episode.label.rawLabel,
      episode: current.manifest.sourceName,
    );
    await mediaBridge.update(
      playing: value.isPlaying,
      position: value.position,
      duration: value.duration,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    hideTimer?.cancel();
    saveTimer?.cancel();
    engine?.state.removeListener(_engineChanged);
    remoteFocus.dispose();
    unawaited(_flush());
    unawaited(engine?.dispose());
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
        // This node observes bubbled remote keys; it must not steal primary
        // focus from the visible TV controls.
        canRequestFocus: false,
        onKeyEvent: _handleRemoteKey,
        child: error != null
            ? _ErrorState(
                error: error!,
                retry: () => _open(),
                alternate: _openAlternate,
              )
            : engine == null || session == null
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
                    VideoDisplaySurface(
                      key: const Key('video-display-surface'),
                      mode: session!.preferences.videoDisplayMode,
                      intrinsicAspectRatio:
                          engine!.state.value.intrinsicAspectRatio,
                      child: engine!.buildSurface(),
                    ),
                    if (engine!.state.value.isBuffering)
                      const Center(child: CircularProgressIndicator()),
                    AnimatedOpacity(
                      opacity: controlsVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: IgnorePointer(
                        ignoring: !controlsVisible,
                        child: _Controls(
                          session: session!,
                          state: engine!.state.value,
                          capabilities: engine!.capabilities,
                          hasPrevious: previousEpisode != null,
                          hasNext: nextEpisode != null,
                          fullscreen: fullscreen,
                          onToggleFullscreen: _toggleFullscreen,
                          onSeek: _seek,
                          onSources: _showSources,
                          onEpisodes: _showEpisodes,
                          onAdjacent: _openAdjacent,
                          onPreferences: _showPreferences,
                          onDisplayMode: _showDisplayMode,
                          onAudio: _showAudio,
                          onSubtitles: _showSubtitles,
                          onTogglePlayback: _togglePlayback,
                          isTv: widget.isTv,
                        ),
                      ),
                    ),
                    if (completionVisible)
                      _CompletionOverlay(
                        hasNext:
                            nextEpisode?.openableBindings.isNotEmpty == true,
                        isTv: widget.isTv,
                        onReplay: _replay,
                        onNext: () => _openAdjacent(1),
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
          engineRegistry: widget.engineRegistry,
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
    final completed = await widget.repository.completedEpisodes(
      session!.mediaId,
    );
    if (!mounted) return;
    final chosen = await showModalBottomSheet<PlaybackEpisodeAvailability>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView.builder(
        itemCount: episodes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return const ListTile(title: Text('Episodes'));
          final value = episodes[index - 1];
          return ListTile(
            selected: value.episode.id == session!.episode.id,
            enabled: value.openableBindings.isNotEmpty,
            leading: Icon(
              completed.contains(value.episode.id)
                  ? Icons.check_circle
                  : Icons.play_circle_outline,
            ),
            title: Text(value.episode.label.rawLabel),
            subtitle: Text(
              value.openableBindings.isEmpty
                  ? 'No playable source'
                  : '${value.playableBindings.length} source(s)',
            ),
            onTap: value.openableBindings.isEmpty
                ? null
                : () => Navigator.pop(context, value),
          );
        },
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
            engineRegistry: widget.engineRegistry,
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
    if (!mounted) return;
    if (value == null) return;
    if (value.openableBindings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'That episode has no playable source. Try another source from Details.',
          ),
        ),
      );
      return;
    }
    await _flush();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => AnimePlayerScreen(
          repository: widget.repository,
          isTv: widget.isTv,
          engineRegistry: widget.engineRegistry,
          request: PlaybackSessionRequest(
            mediaId: session!.mediaId,
            episodeId: value.episode.id,
            startAtBeginning: direction > 0,
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
    final values = const [0.75, 1.0, 1.25, 1.5, 2.0];
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
            if (engine!.capabilities.canSetPlaybackRate)
              for (final value in values)
                ListTile(
                  title: Text('$value× speed'),
                  trailing: engine!.state.value.playbackRate == value
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, value),
                ),
          ],
        ),
      ),
    );
    if (speed != null) {
      await engine!.setPlaybackRate(speed);
      final preferences = session!.preferences.copyWith(speed: speed);
      await widget.repository.savePreferences(preferences);
    }
  }

  Future<void> _showDisplayMode() async {
    final current = session;
    if (current == null) return;
    var mode = current.preferences.videoDisplayMode;
    var customInput =
        mode.aspectPreset == VideoAspectPreset.custom &&
            mode.customAspectRatio != null
        ? '${mode.customAspectRatio}:1'
        : '';
    String? customError;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, updateSheet) {
          void apply(VideoDisplayMode value) {
            mode = value;
            updateSheet(() => customError = null);
            _applyDisplayMode(value);
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.86,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, controller) => SafeArea(
              child: FocusTraversalGroup(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    ListTile(
                      title: const Text('Video display mode'),
                      subtitle: const Text(
                        'Fit and aspect ratio are separate. Auto preserves the video’s original shape.',
                      ),
                      trailing: TextButton.icon(
                        key: const Key('reset-video-display-mode'),
                        autofocus: widget.isTv,
                        onPressed: () => apply(VideoDisplayMode.automatic),
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset to Auto'),
                      ),
                    ),
                    const Divider(),
                    const ListTile(title: Text('Fit mode')),
                    for (final value in VideoDisplayFit.values)
                      ListTile(
                        key: ValueKey('video-fit-${value.name}'),
                        selected: mode.fit == value,
                        leading: Icon(
                          mode.fit == value
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(videoDisplayFitLabel(value)),
                        onTap: () => apply(mode.withFit(value)),
                      ),
                    const Divider(),
                    const ListTile(title: Text('Aspect ratio')),
                    for (final value in VideoAspectPreset.values.where(
                      (value) => value != VideoAspectPreset.custom,
                    ))
                      ListTile(
                        key: ValueKey('video-aspect-${value.name}'),
                        selected: mode.aspectPreset == value,
                        leading: Icon(
                          mode.aspectPreset == value
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(videoAspectPresetLabel(value)),
                        onTap: () => apply(mode.withAspect(value)),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              key: const Key('custom-video-aspect-input'),
                              initialValue: customInput,
                              // A numeric keyboard commonly omits the colon
                              // required by width:height on Android/TV IMEs.
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              enableSuggestions: false,
                              smartDashesType: SmartDashesType.disabled,
                              smartQuotesType: SmartQuotesType.disabled,
                              decoration: InputDecoration(
                                labelText: 'Custom width:height',
                                hintText: '2.39:1',
                                errorText: customError,
                              ),
                              onChanged: (value) => customInput = value,
                              onFieldSubmitted: (_) => _applyCustomVideoAspect(
                                customInput,
                                mode,
                                updateSheet,
                                (value) => mode = value,
                                (value) => customError = value,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            key: const Key('apply-custom-video-aspect'),
                            onPressed: () => _applyCustomVideoAspect(
                              customInput,
                              mode,
                              updateSheet,
                              (value) => mode = value,
                              (value) => customError = value,
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _applyCustomVideoAspect(
    String input,
    VideoDisplayMode current,
    StateSetter updateSheet,
    ValueChanged<VideoDisplayMode> updateMode,
    ValueChanged<String?> updateError,
  ) {
    final ratio = parseVideoAspectRatio(input);
    if (ratio == null) {
      updateSheet(
        () => updateError('Enter two positive values, for example 2.39:1.'),
      );
      return;
    }
    final value = current.withAspect(
      VideoAspectPreset.custom,
      customRatio: ratio,
    );
    updateSheet(() {
      updateMode(value);
      updateError(null);
    });
    _applyDisplayMode(value);
  }

  void _applyDisplayMode(VideoDisplayMode value) {
    final current = session;
    if (current == null) return;
    final preferences = current.preferences.copyWith(videoDisplayMode: value);
    setState(() {
      session = PlaybackSession(
        mediaId: current.mediaId,
        episode: current.episode,
        manifest: current.manifest,
        startPosition: current.startPosition,
        preferences: preferences,
        resume: current.resume,
      );
    });
    unawaited(widget.repository.savePreferences(preferences));
  }

  Future<void> _showAudio() async {
    final player = engine!;
    final tracks = player.state.value.audioTracks;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView.builder(
        itemCount: tracks.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return const ListTile(title: Text('Audio'));
          final track = tracks[index - 1];
          return ListTile(
            title: Text(_trackLabel(track)),
            trailing: player.state.value.selectedAudioTrackId == track.id
                ? const Icon(Icons.check)
                : null,
            onTap: () => Navigator.pop(context, track.id),
          );
        },
      ),
    );
    if (chosen != null) await player.selectAudioTrack(chosen);
  }

  Future<void> _showSubtitles() async {
    final player = engine!;
    final tracks = player.state.value.subtitleTracks;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView.builder(
        itemCount: tracks.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) return const ListTile(title: Text('Subtitles'));
          if (index == 1) {
            return ListTile(
              title: const Text('Off'),
              trailing: player.state.value.selectedSubtitleTrackId == null
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.pop(context, ''),
            );
          }
          final track = tracks[index - 2];
          return ListTile(
            title: Text(_trackLabel(track)),
            trailing: player.state.value.selectedSubtitleTrackId == track.id
                ? const Icon(Icons.check)
                : null,
            onTap: () => Navigator.pop(context, track.id),
          );
        },
      ),
    );
    if (chosen != null) {
      await player.selectSubtitleTrack(chosen.isEmpty ? null : chosen);
    }
  }

  Future<void> _replay() async {
    // Keep completion handling latched while the engine transitions away from
    // its terminal frame; some platforms notify the old completed state once
    // during seekTo(0).
    handledNaturalEnd = true;
    if (mounted) setState(() => completionVisible = false);
    await engine?.seek(Duration.zero);
    await _play();
    handledNaturalEnd = false;
    if (mounted) setState(() {});
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.session,
    required this.state,
    required this.capabilities,
    required this.hasPrevious,
    required this.hasNext,
    required this.fullscreen,
    required this.onToggleFullscreen,
    required this.onSeek,
    required this.onSources,
    required this.onEpisodes,
    required this.onAdjacent,
    required this.onPreferences,
    required this.onDisplayMode,
    required this.onAudio,
    required this.onSubtitles,
    required this.onTogglePlayback,
    required this.isTv,
  });
  final PlaybackSession session;
  final PlaybackEngineState state;
  final PlaybackCapabilities capabilities;
  final bool hasPrevious;
  final bool hasNext;
  final bool fullscreen;
  final Future<void> Function() onToggleFullscreen;
  final Future<void> Function(Duration) onSeek;
  final Future<void> Function() onSources;
  final Future<void> Function() onEpisodes;
  final Future<void> Function(int) onAdjacent;
  final Future<void> Function() onPreferences;
  final Future<void> Function() onDisplayMode;
  final Future<void> Function() onAudio;
  final Future<void> Function() onSubtitles;
  final Future<void> Function() onTogglePlayback;
  final bool isTv;

  @override
  Widget build(BuildContext context) {
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
                if (shouldShowAudioControl(capabilities, state))
                  IconButton(
                    tooltip: 'Audio',
                    onPressed: onAudio,
                    icon: const Icon(Icons.audiotrack, color: Colors.white),
                  ),
                if (shouldShowSubtitleControl(capabilities, state))
                  IconButton(
                    tooltip: 'Subtitles',
                    onPressed: onSubtitles,
                    icon: const Icon(Icons.subtitles, color: Colors.white),
                  ),
                IconButton(
                  tooltip: 'Display mode',
                  onPressed: onDisplayMode,
                  icon: const Icon(Icons.aspect_ratio, color: Colors.white),
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
                  onPressed: hasPrevious ? () => onAdjacent(-1) : null,
                  icon: Icon(
                    Icons.skip_previous,
                    color: hasPrevious ? Colors.white : Colors.white38,
                  ),
                ),
                IconButton(
                  tooltip: 'Back $step seconds',
                  onPressed: () => onSeek(Duration(seconds: -step)),
                  icon: const Icon(Icons.replay_10, color: Colors.white),
                ),
                IconButton.filled(
                  autofocus: isTv,
                  tooltip: state.isPlaying ? 'Pause' : 'Play',
                  onPressed: onTogglePlayback,
                  iconSize: isTv ? 42 : 24,
                  icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  tooltip: 'Forward $step seconds',
                  onPressed: () => onSeek(Duration(seconds: step)),
                  icon: const Icon(Icons.forward_10, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Next episode',
                  onPressed: hasNext ? () => onAdjacent(1) : null,
                  icon: Icon(
                    Icons.skip_next,
                    color: hasNext ? Colors.white : Colors.white38,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                const SizedBox(width: 12),
                Text(
                  _clock(state.position),
                  style: const TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: Slider(
                    value: state.duration.inMilliseconds == 0
                        ? 0
                        : (state.position.inMilliseconds /
                                  state.duration.inMilliseconds)
                              .clamp(0, 1),
                    onChanged: capabilities.canSeek
                        ? (value) => onSeek(
                            Duration(
                                  milliseconds:
                                      (state.duration.inMilliseconds * value)
                                          .round(),
                                ) -
                                state.position,
                          )
                        : null,
                  ),
                ),
                Text(
                  _clock(state.duration),
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

class _CompletionOverlay extends StatelessWidget {
  const _CompletionOverlay({
    required this.hasNext,
    required this.isTv,
    required this.onReplay,
    required this.onNext,
  });

  final bool hasNext;
  final bool isTv;
  final Future<void> Function() onReplay;
  final Future<void> Function() onNext;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black87,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Episode complete',
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
          const SizedBox(height: 12),
          Text(
            hasNext
                ? 'Ready for the next episode?'
                : 'End of available episodes',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          FocusTraversalGroup(
            child: Wrap(
              spacing: 16,
              children: [
                OutlinedButton.icon(
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay),
                  label: const Text('Replay'),
                ),
                if (hasNext)
                  FilledButton.icon(
                    autofocus: isTv,
                    onPressed: onNext,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Next Episode'),
                  ),
              ],
            ),
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

String _trackLabel(PlaybackEngineTrack track) {
  final label = track.label.trim();
  final language = track.language?.trim();
  if (label.isNotEmpty && language != null && language.isNotEmpty) {
    return '$label · ${language.toUpperCase()}';
  }
  if (label.isNotEmpty) return label;
  if (language != null && language.isNotEmpty) return language.toUpperCase();
  return 'Unknown track';
}
