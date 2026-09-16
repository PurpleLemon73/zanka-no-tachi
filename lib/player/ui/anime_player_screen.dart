import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../canonical/domain/bindings.dart';
import '../default_playback_engine_registry.dart';
import '../playback_domain.dart';
import '../playback_engine.dart';
import '../playback_repository.dart';
import '../playback_source.dart';
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
  }) : _presentation = null;

  const AnimePlayerScreen._episode(
    this._presentation, {
    required this.repository,
    required this.request,
    required this.isTv,
    required this.engineRegistry,
  }) : mediaBridge = null;

  final PlaybackRepository repository;
  final PlaybackSessionRequest request;
  final bool isTv;
  final AndroidMediaBridge? mediaBridge;
  final PlaybackEngineRegistry? engineRegistry;
  final _FullscreenPresentation? _presentation;

  @override
  State<AnimePlayerScreen> createState() => _AnimePlayerScreenState();
}

/// Episode routes share presentation, never a decoder or progress session.
/// Serialize system-UI changes so a pending enter cannot finish after an exit
/// on the replacement route.
class _FullscreenPresentation {
  bool fullscreen = false;
  // Session intent travels with episode/source replacements, not with saved
  // playback preferences. Any explicit choice wins until the player is left.
  bool _manualOverride = false;
  Future<void> _pending = Future<void>.value();

  Future<void>? updateAutomatic({
    required bool isTv,
    required Orientation orientation,
  }) {
    if (_manualOverride) return null;
    final desired = isTv || orientation == Orientation.landscape;
    if (desired == fullscreen) return null;
    return setFullscreen(desired, automatic: true);
  }

  Future<void> setManualFullscreen(bool value) {
    _manualOverride = true;
    return setFullscreen(value);
  }

  Future<void> setFullscreen(bool value, {bool automatic = false}) {
    fullscreen = value;
    final operation = _pending.then((_) async {
      await SystemChrome.setEnabledSystemUIMode(
        value ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
      await SystemChrome.setPreferredOrientations(
        value && !automatic
            ? const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
            : DeviceOrientation.values,
      );
    });
    // Report this operation's error to its caller without blocking later exits.
    _pending = operation.catchError((Object _) {});
    return operation;
  }
}

class _AnimePlayerScreenState extends State<AnimePlayerScreen>
    with WidgetsBindingObserver {
  PlaybackSession? session;
  PlaybackEngine? engine;
  Object? error;
  bool controlsVisible = true;
  late final _FullscreenPresentation _presentation =
      widget._presentation ?? _FullscreenPresentation();
  bool get fullscreen => _presentation.fullscreen;
  bool _ownsPresentation = true;
  bool _navigatingEpisode = false;
  Timer? hideTimer;
  Timer? saveTimer;
  bool handledNaturalEnd = false;
  bool completionVisible = false;
  PlaybackEpisodeAvailability? previousEpisode;
  PlaybackEpisodeAvailability? nextEpisode;
  late final AndroidMediaBridge mediaBridge =
      widget.mediaBridge ?? AndroidMediaBridge();
  final FocusNode remoteFocus = FocusNode(debugLabel: 'TV player remote');
  final FocusNode backFocus = FocusNode(debugLabel: 'TV app bar Back');
  final FocusScopeNode controlsFocus = FocusScopeNode(
    debugLabel: 'TV controls',
  );
  final FocusScopeNode completionFocus = FocusScopeNode(
    debugLabel: 'TV completion',
    traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
    directionalTraversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
  );
  final Map<_TvControl, FocusNode> tvControls = {
    for (final control in _TvControl.values)
      control: FocusNode(debugLabel: 'TV ${control.name}'),
  };
  bool _sheetOpen = false;
  int _focusGeneration = 0;
  int lastNativeUpdateSecond = -1;
  bool? lastNativePlaying;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mediaBridge.onCommand = _handleMediaCommand;
    unawaited(_open());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_ownsPresentation) return;
    // Only the existing semantic signal identifies TV. Orientation is used
    // solely for automatic phone/tablet presentation, never TV detection.
    final change = _presentation.updateAutomatic(
      isTv: widget.isTv,
      orientation: MediaQuery.orientationOf(context),
    );
    if (change != null) unawaited(change);
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
      final registry = widget.engineRegistry ?? defaultPlaybackEngineRegistry();
      final engineSelection = registry.create(
        opened.preferences.enginePreference,
      );
      player = engineSelection.engine;
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
      final fallbackReason = engineSelection.fallbackReason;
      if (fallbackReason != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(fallbackReason)));
      } else if (player.kind == PlaybackEngineKind.betterPlayerExperimental) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Using Better Player (Experimental) for this session.',
            ),
          ),
        );
      }
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
      _requestTvFocus();
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
    if (widget.isTv) hideTimer?.cancel();
    _requestTvFocus();
    if (current.preferences.autoplayNext &&
        nextEpisode?.openableBindings.isNotEmpty == true) {
      await _openAdjacent(1);
    }
  }

  void _scheduleHide() {
    hideTimer?.cancel();
    if (widget.isTv && (completionVisible || _sheetOpen)) return;
    if (engine?.state.value.isPlaying ?? false) {
      hideTimer = Timer(Duration(seconds: widget.isTv ? 5 : 3), () {
        if (!mounted) return;
        if (widget.isTv) {
          if (completionVisible ||
              _sheetOpen ||
              !(engine?.state.value.isPlaying ?? false)) {
            return;
          }
          // Idle timeout is an explicit hand-off, never an invisible focused
          // button. The next remote interaction reveals and focuses controls.
          _hideTvControls();
        } else {
          setState(() => controlsVisible = false);
        }
      });
    }
  }

  void _requestTvFocus([FocusNode? preferred]) {
    if (!widget.isTv) return;
    final ticket = ++_focusGeneration;
    final player = engine;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          ticket != _focusGeneration ||
          !identical(player, engine) ||
          engine == null ||
          error != null ||
          _sheetOpen ||
          _navigatingEpisode ||
          !controlsVisible ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      final target = completionVisible
          ? tvControls[nextEpisode?.openableBindings.isNotEmpty == true
                ? _TvControl.completionNext
                : _TvControl.replay]!
          : (preferred?.context != null && preferred!.canRequestFocus
                ? preferred
                : tvControls[_TvControl.toggle]!);
      target.requestFocus();
    });
  }

  void _hideTvControls() {
    _focusGeneration++;
    hideTimer?.cancel();
    remoteFocus.requestFocus();
    setState(() => controlsVisible = false);
  }

  void _dismissTvCompletion() {
    setState(() {
      completionVisible = false;
      controlsVisible = true;
    });
    _requestTvFocus();
    _scheduleHide();
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
    if (mounted && widget.isTv) {
      final wasVisible = controlsVisible;
      setState(() => controlsVisible = true);
      hideTimer?.cancel();
      if (!wasVisible) _requestTvFocus();
    }
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
    if (widget.isTv && event is KeyRepeatEvent && controlsVisible) {
      _scheduleHide();
      return KeyEventResult.ignored;
    }
    if (!widget.isTv || event is! KeyDownEvent) return KeyEventResult.ignored;
    final command = tvPlayerCommandFor(event.logicalKey);
    if (command == null) return KeyEventResult.ignored;
    final wasVisible = controlsVisible;
    setState(() => controlsVisible = true);
    if (!wasVisible) _requestTvFocus();
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
    await _presentation.setManualFullscreen(!fullscreen);
    if (mounted) setState(() {});
  }

  Future<void> _restoreSystemUi() => _presentation.setFullscreen(false);

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
    backFocus.dispose();
    _focusGeneration++;
    controlsFocus.dispose();
    completionFocus.dispose();
    for (final node in tvControls.values) {
      node.dispose();
    }
    unawaited(_flush());
    unawaited(engine?.dispose());
    unawaited(mediaBridge.deactivate());
    if (_ownsPresentation && fullscreen) unawaited(_restoreSystemUi());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop:
        !fullscreen &&
        (!widget.isTv || (!controlsVisible && !completionVisible)),
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      if (fullscreen) {
        unawaited(_toggleFullscreen());
        // Keep the established TV contract: outside completion, the first Back
        // exits fullscreen and hides controls; the second can leave the route.
        if (widget.isTv && !completionVisible && controlsVisible) {
          _hideTvControls();
        }
      } else if (widget.isTv && completionVisible) {
        _dismissTvCompletion();
      } else if (widget.isTv && controlsVisible) {
        _hideTvControls();
      }
    },
    child: Scaffold(
      backgroundColor: Colors.black,
      appBar: fullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              leading: widget.isTv && Navigator.of(context).canPop()
                  ? Focus(
                      focusNode: backFocus,
                      canRequestFocus: false,
                      skipTraversal: true,
                      onKeyEvent: (_, event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.arrowDown) {
                          setState(() => controlsVisible = true);
                          _requestTvFocus(tvControls[_TvControl.episodes]);
                          _scheduleHide();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: const BackButton(),
                    )
                  : null,
              title: Text(session?.episode.label.rawLabel ?? 'Player'),
            ),
      body: Focus(
        focusNode: remoteFocus,
        // Parking target only while controls are hidden. Never a traversal stop.
        canRequestFocus: widget.isTv,
        skipTraversal: true,
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
                  if (widget.isTv) {
                    if (completionVisible) return;
                    if (controlsVisible) {
                      _hideTvControls();
                    } else {
                      setState(() => controlsVisible = true);
                      _requestTvFocus();
                      _scheduleHide();
                    }
                    return;
                  }
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
                    ExcludeFocus(
                      excluding: widget.isTv,
                      child: VideoDisplaySurface(
                        key: const Key('video-display-surface'),
                        mode: session!.preferences.videoDisplayMode
                            .forPresentation(isTv: widget.isTv),
                        intrinsicAspectRatio:
                            engine!.state.value.intrinsicAspectRatio,
                        child: engine!.buildSurface(),
                      ),
                    ),
                    if (engine!.state.value.isBuffering)
                      const Center(child: CircularProgressIndicator()),
                    AnimatedOpacity(
                      opacity: controlsVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: IgnorePointer(
                        ignoring: !controlsVisible,
                        child: ExcludeFocus(
                          excluding:
                              widget.isTv &&
                              (!controlsVisible || completionVisible),
                          child: FocusScope(
                            node: controlsFocus,
                            child: FocusTraversalGroup(
                              policy: widget.isTv
                                  ? _TvControlsTraversal(
                                      tvControls,
                                      hasPrevious: previousEpisode != null,
                                      hasNext: nextEpisode != null,
                                      canSeek: engine!.capabilities.canSeek,
                                      onExitUp: () {
                                        backFocus.descendants
                                            .where(
                                              (node) => node.canRequestFocus,
                                            )
                                            .firstOrNull
                                            ?.requestFocus();
                                      },
                                    )
                                  : null,
                              child: _Controls(
                                session: session!,
                                state: engine!.state.value,
                                capabilities: engine!.capabilities,
                                hasPrevious: previousEpisode != null,
                                hasNext: nextEpisode != null,
                                fullscreen: fullscreen,
                                onToggleFullscreen: () async {
                                  if (widget.isTv) _scheduleHide();
                                  await _toggleFullscreen();
                                },
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
                                focusNodes: widget.isTv ? tvControls : const {},
                                experimentalEngine:
                                    engine!.kind ==
                                    PlaybackEngineKind.betterPlayerExperimental,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (completionVisible)
                      ExcludeFocus(
                        excluding: widget.isTv && _sheetOpen,
                        child: FocusScope(
                          node: completionFocus,
                          child: _CompletionOverlay(
                            hasNext:
                                nextEpisode?.openableBindings.isNotEmpty ==
                                true,
                            isTv: widget.isTv,
                            replayFocus: widget.isTv
                                ? tvControls[_TvControl.replay]
                                : null,
                            nextFocus: widget.isTv
                                ? tvControls[_TvControl.completionNext]
                                : null,
                            onReplay: _replay,
                            onNext: () => _openAdjacent(1),
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
    final navigation = Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        settings: RouteSettings(
          name:
              '/player/${session!.mediaId.value}/${session!.episode.id.value}',
        ),
        builder: (_) => AnimePlayerScreen._episode(
          _presentation,
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
    _ownsPresentation = false;
    await navigation;
  }

  Future<void> _showSources() async {
    final values = (await widget.repository.episodes(
      session!.mediaId,
    )).where((item) => item.episode.id == session!.episode.id).first;
    if (!mounted) return;
    final chosen = await _showPlayerSheet<EpisodeSourceBinding>(
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _PlayerSheetHeader(
              title: 'Switch source',
              icon: Icons.source_rounded,
              subtitle:
                  'Different encodes do not share exact timestamps. A new source starts at its own saved position or 0:00.',
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
    final firstPlayableIndex = episodes.indexWhere(
      (episode) => episode.openableBindings.isNotEmpty,
    );
    final chosen = await _showPlayerSheet<PlaybackEpisodeAvailability>(
      builder: (context) => ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: episodes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _PlayerSheetHeader(
              title: 'Episodes',
              icon: Icons.playlist_play_rounded,
              subtitle: '${episodes.length} episodes · Choose where to go next',
            );
          }
          final value = episodes[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              selected: value.episode.id == session!.episode.id,
              autofocus: widget.isTv && index - 1 == firstPlayableIndex,
              enabled: value.openableBindings.isNotEmpty,
              leading: Icon(
                completed.contains(value.episode.id)
                    ? Icons.check_circle
                    : Icons.play_circle_outline,
              ),
              title: Text(
                value.episode.label.rawLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                value.openableBindings.isEmpty
                    ? 'No playable source'
                    : '${value.playableBindings.length} source(s)',
              ),
              onTap: value.openableBindings.isEmpty
                  ? null
                  : () => Navigator.pop(context, value),
              trailing: value.episode.id == session!.episode.id
                  ? const _PlayerBadge(label: 'Current')
                  : const Icon(Icons.chevron_right_rounded),
            ),
          );
        },
      ),
    );
    if (chosen != null && chosen.episode.id != session!.episode.id && mounted) {
      await _flush();
      if (!mounted) return;
      final navigation = Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AnimePlayerScreen._episode(
            _presentation,
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
      _ownsPresentation = false;
      await navigation;
    }
  }

  Future<void> _openAdjacent(int direction) async {
    if (_navigatingEpisode) return;
    _navigatingEpisode = true;
    try {
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
      final navigation = Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AnimePlayerScreen._episode(
            _presentation,
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
      // pushReplacement disposes the old route after its transition. Only the
      // replacement may restore fullscreen, even if Back is pressed meanwhile.
      _ownsPresentation = false;
      await navigation;
    } finally {
      _navigatingEpisode = false;
    }
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
    final speed = await _showPlayerSheet<double>(
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const _PlayerSheetHeader(
              title: 'Playback settings',
              icon: Icons.tune_rounded,
              subtitle:
                  'This player uses the file’s default audio track. Track selection is shown only when the platform can control it reliably.',
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
    await _showPlayerSheet<void>(
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    const _PlayerSheetHeader(
                      title: 'Video display mode',
                      icon: Icons.aspect_ratio_rounded,
                      subtitle:
                          'Fit and aspect ratio are separate. Auto preserves the video’s original shape.',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        key: const Key('reset-video-display-mode'),
                        autofocus: widget.isTv,
                        onPressed: () => apply(VideoDisplayMode.automatic),
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset to Auto'),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 16),
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
    final chosen = await _showPlayerSheet<String>(
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
    final chosen = await _showPlayerSheet<String>(
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
    _requestTvFocus();
  }

  Future<T?> _showPlayerSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
  }) async {
    if (!mounted ||
        (widget.isTv &&
            (_sheetOpen || ModalRoute.of(context)?.isCurrent != true))) {
      return null;
    }
    final returnFocus = tvControls.values
        .where((node) => node.hasFocus)
        .firstOrNull;
    final player = engine;
    _sheetOpen = true;
    if (widget.isTv) {
      _focusGeneration++;
      hideTimer?.cancel();
    }
    try {
      return await showModalBottomSheet<T>(
        context: context,
        showDragHandle: true,
        isScrollControlled: isScrollControlled,
        backgroundColor: _playerPanelColor,
        barrierColor: Colors.black54,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        clipBehavior: Clip.antiAlias,
        constraints: const BoxConstraints(maxWidth: 720),
        builder: (context) =>
            _PlayerSheetTheme(child: Builder(builder: builder)),
      );
    } finally {
      _sheetOpen = false;
      if (mounted &&
          widget.isTv &&
          identical(player, engine) &&
          ModalRoute.of(context)?.isCurrent == true) {
        setState(() => controlsVisible = true);
        _requestTvFocus(returnFocus);
        _scheduleHide();
      }
    }
  }
}

const _playerPanelColor = Color(0xFF191E28);

enum _TvControl {
  episodes,
  source,
  audio,
  subtitles,
  display,
  settings,
  previous,
  rewind,
  toggle,
  forward,
  next,
  timeline,
  fullscreen,
  replay,
  completionNext,
}

/// Explicit TV rows, independent of video size, button size or screen geometry.
/// The slider keeps its native Left/Right adjustment. Down leaves it for the
/// fullscreen action; Up returns to playback. Disabled/absent actions are skipped.
class _TvControlsTraversal extends WidgetOrderTraversalPolicy {
  _TvControlsTraversal(
    this.nodes, {
    required this.onExitUp,
    required this.hasPrevious,
    required this.hasNext,
    required this.canSeek,
  });
  final Map<_TvControl, FocusNode> nodes;
  final VoidCallback onExitUp;
  final bool hasPrevious;
  final bool hasNext;
  final bool canSeek;

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final rows =
        [
              [
                _TvControl.episodes,
                _TvControl.source,
                _TvControl.audio,
                _TvControl.subtitles,
                _TvControl.display,
                _TvControl.settings,
              ],
              [
                if (hasPrevious) _TvControl.previous,
                _TvControl.rewind,
                _TvControl.toggle,
                _TvControl.forward,
                if (hasNext) _TvControl.next,
              ],
              if (canSeek) [_TvControl.timeline],
              [_TvControl.fullscreen],
            ]
            .map(
              (row) => row
                  .map((id) => nodes[id]!)
                  .where((node) => node.context != null && node.canRequestFocus)
                  .toList(),
            )
            .where((row) => row.isNotEmpty)
            .toList();
    final rowIndex = rows.indexWhere((row) => row.contains(currentNode));
    if (rowIndex < 0) return super.inDirection(currentNode, direction);
    final row = rows[rowIndex];
    FocusNode target = currentNode;
    if (direction == TraversalDirection.left ||
        direction == TraversalDirection.right) {
      if (currentNode == nodes[_TvControl.fullscreen] &&
          direction == TraversalDirection.left) {
        target = rows[rowIndex - 1].first;
      } else {
        final index =
            (row.indexOf(currentNode) +
                    (direction == TraversalDirection.left ? -1 : 1))
                .clamp(0, row.length - 1);
        target = row[index];
      }
    } else {
      final nextRow = rowIndex + (direction == TraversalDirection.up ? -1 : 1);
      if (nextRow < 0) {
        onExitUp();
        return true;
      }
      if (nextRow >= rows.length) return true;
      target = rows[nextRow].contains(nodes[_TvControl.toggle])
          ? nodes[_TvControl.toggle]!
          : rows[nextRow].first;
    }
    target.requestFocus();
    return true;
  }
}

class _PlayerSurface extends StatelessWidget {
  const _PlayerSurface({
    required this.child,
    this.radius = 28,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: _playerPanelColor.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _PlayerControlButton extends StatelessWidget {
  const _PlayerControlButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.child,
    this.size = 48,
    this.iconSize = 24,
    this.primary = false,
    this.autofocus = false,
    this.focusNode,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? child;
  final double size;
  final double iconSize;
  final bool primary;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      autofocus: autofocus,
      focusNode: focusNode,
      iconSize: iconSize,
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(Size.square(size)),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: const WidgetStatePropertyAll(CircleBorder()),
        side: WidgetStateProperty.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.focused)
                ? Colors.white
                : Colors.white.withValues(alpha: primary ? 0.16 : 0.06),
            width: states.contains(WidgetState.focused) ? 2.5 : 1,
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.white10;
          if (states.contains(WidgetState.focused)) {
            return primary ? colors.primaryContainer : Colors.white24;
          }
          return primary ? colors.primary : Colors.black.withValues(alpha: 0.2);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return Colors.white30;
          if (!primary) return Colors.white;
          return states.contains(WidgetState.focused)
              ? colors.onPrimaryContainer
              : colors.onPrimary;
        }),
        overlayColor: WidgetStatePropertyAll(
          Colors.white.withValues(alpha: 0.12),
        ),
        elevation: WidgetStatePropertyAll(primary ? 4 : 0),
        shadowColor: const WidgetStatePropertyAll(Colors.black54),
        animationDuration: const Duration(milliseconds: 120),
      ),
      icon: child ?? Icon(icon),
    );
  }
}

class _SeekGlyph extends StatelessWidget {
  const _SeekGlyph({required this.forward, required this.step});
  final bool forward;
  final int step;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Let the decorative icon yield space to the fully scaled seek label.
      Flexible(
        child: Icon(
          forward ? Icons.forward_rounded : Icons.replay_rounded,
          size: 20,
        ),
      ),
      Text(
        '${forward ? '+' : '-'}${step}s',
        style: const TextStyle(
          fontSize: 11,
          height: 1.15,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _PlayerBadge extends StatelessWidget {
  const _PlayerBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class _PlayerSheetHeader extends StatelessWidget {
  const _PlayerSheetHeader({
    required this.title,
    required this.icon,
    required this.subtitle,
  });
  final String title;
  final IconData icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
      ],
    ),
  );
}

class _PlayerSheetTheme extends StatelessWidget {
  const _PlayerSheetTheme({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final colors = ColorScheme.fromSeed(
      seedColor: base.colorScheme.primary,
      brightness: Brightness.dark,
      surface: _playerPanelColor,
    );
    return Theme(
      data: base.copyWith(
        colorScheme: colors,
        focusColor: Colors.white.withValues(alpha: 0.18),
        textTheme: base.textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        listTileTheme: ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          textColor: Colors.white,
          iconColor: Colors.white70,
          selectedColor: colors.primary,
          selectedTileColor: colors.primary.withValues(alpha: 0.12),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(shape: const StadiumBorder()),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(shape: const StadiumBorder()),
        ),
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      child: child,
    );
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
    required this.experimentalEngine,
    required this.focusNodes,
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
  final bool experimentalEngine;
  final Map<_TvControl, FocusNode> focusNodes;

  @override
  Widget build(BuildContext context) {
    final step = session.preferences.seekStepSeconds;
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xB3000000), Color(0x18000000), Color(0xB3000000)],
          stops: [0, 0.48, 1],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 360;
            final inset = isTv && !compact ? 24.0 : 12.0;
            final title = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  session.episode.label.rawLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTv ? 22 : 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  session.manifest.sourceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                if (experimentalEngine) ...[
                  const SizedBox(height: 6),
                  const _PlayerBadge(label: 'Better Player · Experimental'),
                ],
              ],
            );
            final tools = _PlayerSurface(
              radius: 32,
              padding: const EdgeInsets.all(4),
              child: Wrap(
                spacing: 2,
                children: [
                  _PlayerControlButton(
                    tooltip: 'Episodes',
                    focusNode: focusNodes[_TvControl.episodes],
                    onPressed: onEpisodes,
                    icon: Icons.playlist_play_rounded,
                  ),
                  _PlayerControlButton(
                    tooltip: 'Source',
                    focusNode: focusNodes[_TvControl.source],
                    onPressed: onSources,
                    icon: Icons.source_rounded,
                  ),
                  if (shouldShowAudioControl(capabilities, state))
                    _PlayerControlButton(
                      tooltip: 'Audio',
                      focusNode: focusNodes[_TvControl.audio],
                      onPressed: onAudio,
                      icon: Icons.audiotrack_rounded,
                    ),
                  if (shouldShowSubtitleControl(capabilities, state))
                    _PlayerControlButton(
                      tooltip: 'Subtitles',
                      focusNode: focusNodes[_TvControl.subtitles],
                      onPressed: onSubtitles,
                      icon: Icons.subtitles_rounded,
                    ),
                  _PlayerControlButton(
                    tooltip: 'Display mode',
                    focusNode: focusNodes[_TvControl.display],
                    onPressed: onDisplayMode,
                    icon: Icons.aspect_ratio_rounded,
                  ),
                  _PlayerControlButton(
                    tooltip: 'Settings',
                    focusNode: focusNodes[_TvControl.settings],
                    onPressed: onPreferences,
                    icon: Icons.tune_rounded,
                  ),
                ],
              ),
            );
            return Padding(
              padding: EdgeInsets.all(inset),
              child: Column(
                children: [
                  if (constraints.maxWidth < 560)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        title,
                        const SizedBox(height: 10),
                        Align(alignment: Alignment.centerRight, child: tools),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: 16),
                        tools,
                      ],
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: constraints.maxWidth < 360 ? 4 : 8,
                      children: [
                        _PlayerControlButton(
                          tooltip: 'Previous episode',
                          focusNode: focusNodes[_TvControl.previous],
                          onPressed: hasPrevious ? () => onAdjacent(-1) : null,
                          icon: Icons.skip_previous_rounded,
                          iconSize: 28,
                        ),
                        _PlayerControlButton(
                          tooltip: 'Back $step seconds',
                          focusNode: focusNodes[_TvControl.rewind],
                          onPressed: () => onSeek(Duration(seconds: -step)),
                          size: isTv && !compact ? 64 : 52,
                          child: _SeekGlyph(forward: false, step: step),
                        ),
                        _PlayerControlButton(
                          autofocus: isTv,
                          focusNode: focusNodes[_TvControl.toggle],
                          tooltip: state.isPlaying ? 'Pause' : 'Play',
                          onPressed: onTogglePlayback,
                          primary: true,
                          size: isTv ? (compact ? 80 : 96) : 72,
                          iconSize: isTv ? 44 : 36,
                          icon: state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        _PlayerControlButton(
                          tooltip: 'Forward $step seconds',
                          focusNode: focusNodes[_TvControl.forward],
                          onPressed: () => onSeek(Duration(seconds: step)),
                          size: isTv && !compact ? 64 : 52,
                          child: _SeekGlyph(forward: true, step: step),
                        ),
                        _PlayerControlButton(
                          tooltip: 'Next episode',
                          focusNode: focusNodes[_TvControl.next],
                          onPressed: hasNext ? () => onAdjacent(1) : null,
                          icon: Icons.skip_next_rounded,
                          iconSize: 28,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _PlayerSurface(
                    radius: 28,
                    padding: const EdgeInsets.fromLTRB(12, 4, 6, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  activeTrackColor: colors.primary,
                                  inactiveTrackColor: Colors.white24,
                                  thumbColor: colors.primary,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16,
                                  ),
                                ),
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    // Native slider key handling otherwise consumes
                                    // Up/Down as seeking and traps remote traversal.
                                    navigationMode: isTv
                                        ? NavigationMode.directional
                                        : MediaQuery.navigationModeOf(context),
                                  ),
                                  child: Slider(
                                    focusNode: focusNodes[_TvControl.timeline],
                                    value: state.duration.inMilliseconds == 0
                                        ? 0
                                        : (state.position.inMilliseconds /
                                                  state.duration.inMilliseconds)
                                              .clamp(0, 1),
                                    onChanged: capabilities.canSeek
                                        ? (value) => onSeek(
                                            Duration(
                                                  milliseconds:
                                                      (state
                                                                  .duration
                                                                  .inMilliseconds *
                                                              value)
                                                          .round(),
                                                ) -
                                                state.position,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _clock(state.position),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _clock(state.duration),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontFeatures: [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PlayerControlButton(
                          focusNode: focusNodes[_TvControl.fullscreen],
                          tooltip: fullscreen
                              ? 'Exit fullscreen'
                              : 'Fullscreen',
                          onPressed: onToggleFullscreen,
                          icon: fullscreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
    this.replayFocus,
    this.nextFocus,
  });

  final bool hasNext;
  final bool isTv;
  final Future<void> Function() onReplay;
  final Future<void> Function() onNext;
  final FocusNode? replayFocus;
  final FocusNode? nextFocus;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    ButtonStyle actionStyle({required bool primary}) => ButtonStyle(
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      minimumSize: WidgetStatePropertyAll(
        Size(primary ? 168 : 120, isTv ? 56 : 48),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      foregroundColor: WidgetStatePropertyAll(
        primary ? colors.onPrimary : Colors.white,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? (primary
                  ? Color.alphaBlend(Colors.white24, colors.primary)
                  : Colors.white24)
            : (primary ? colors.primary : Colors.transparent),
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.focused)
              ? Colors.white
              : Colors.white24,
          width: states.contains(WidgetState.focused) ? 2.5 : 1,
        ),
      ),
    );

    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _PlayerSurface(
              radius: 32,
              padding: EdgeInsets.all(isTv ? 28 : 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: colors.primary,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Episode complete',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasNext
                        ? 'Ready for the next episode?'
                        : 'End of available episodes',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  FocusTraversalGroup(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          focusNode: replayFocus,
                          autofocus: isTv && !hasNext,
                          style: actionStyle(primary: false),
                          onPressed: onReplay,
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('Replay'),
                        ),
                        if (hasNext)
                          FilledButton.icon(
                            focusNode: nextFocus,
                            style: actionStyle(primary: true),
                            autofocus: isTv,
                            onPressed: onNext,
                            icon: const Icon(Icons.skip_next_rounded),
                            label: const Text('Next Episode'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
