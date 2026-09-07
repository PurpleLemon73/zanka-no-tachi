import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'playback_domain.dart';
import 'playback_engine.dart';

/// Minimal state exposed by the package-specific driver to the engine adapter.
///
/// Keeping this separate from [PlaybackEngineState] makes the engine contract
/// testable without loading a native Better Player plugin.
class BetterPlayerDriverState {
  const BetterPlayerDriverState({
    this.initialized = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.playbackRate = 1,
    this.intrinsicAspectRatio,
    this.failureMessage,
  });

  final bool initialized;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;
  final double playbackRate;
  final double? intrinsicAspectRatio;
  final String? failureMessage;
}

abstract interface class BetterPlayerDriver {
  ValueListenable<BetterPlayerDriverState> get state;
  Future<void> open(PlaybackManifest manifest);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setPlaybackRate(double rate);
  Widget buildSurface();
  Future<void> dispose();
}

typedef BetterPlayerDriverFactory = BetterPlayerDriver Function();

/// Experimental, basic-MP4-only implementation of Zanka's playback contract.
///
/// Better Player owns decoding and a texture only. Zanka remains authoritative
/// for controls, display geometry, lifecycle, MediaSession, audio focus, and
/// persisted progress.
class BetterPlayerPlaybackEngine implements PlaybackEngine {
  BetterPlayerPlaybackEngine({
    BetterPlayerDriverFactory? driverFactory,
    this.readinessTimeout = const Duration(seconds: 20),
    this.commandTimeout = const Duration(seconds: 5),
  }) : _driverFactory = driverFactory ?? OriginalBetterPlayerDriver.new;

  final BetterPlayerDriverFactory _driverFactory;
  final Duration readinessTimeout;
  final Duration commandTimeout;
  final ValueNotifier<PlaybackEngineState> _state = ValueNotifier(
    const PlaybackEngineState(),
  );

  // better_player_android 1.2.0 (resolved by better_player 1.3.0) broadcasts
  // native callbacks to every live Better texture. Serialize ownership so an
  // outgoing route is fully retired before another experimental engine opens.
  static Future<void>? _leaseOperation;
  static BetterPlayerPlaybackEngine? _leaseOwner;
  static int _nextLeaseToken = 0;

  BetterPlayerDriver? _driver;
  VoidCallback? _driverListener;
  _BetterPlayerReadiness? _readiness;
  int? _leaseToken;
  int _generation = 0;
  bool _disposed = false;
  Future<void>? _driverRetirement;
  Future<void>? _disposeFuture;

  @override
  PlaybackEngineKind get kind => PlaybackEngineKind.betterPlayerExperimental;

  @override
  String get diagnosticName => 'better_player 1.3.0 (experimental)';

  @override
  PlaybackCapabilities get capabilities =>
      const PlaybackCapabilities(canSeek: true, canSetPlaybackRate: true);

  @override
  ValueListenable<PlaybackEngineState> get state => _state;

  @override
  Future<void> open(
    PlaybackManifest manifest, {
    Duration startPosition = Duration.zero,
  }) async {
    if (_disposed) throw StateError('The video engine has been disposed.');

    final generation = ++_generation;
    final previousLeaseToken = _leaseToken;
    _cancelPendingReadiness();
    await _retireDriver();
    if (_disposed || generation != _generation) {
      throw const PlaybackException(
        PlaybackErrorKind.decoderFailure,
        'The experimental video engine open was superseded.',
      );
    }

    if (!_isBasicMp4(manifest)) {
      _releaseLease(previousLeaseToken);
      final failure = const PlaybackEngineFailure(
        message: 'The experimental engine currently supports basic MP4 only.',
        severity: PlaybackEngineErrorSeverity.fatal,
      );
      _state.value = PlaybackEngineState(
        phase: PlaybackEnginePhase.failed,
        error: failure,
      );
      throw const PlaybackException(
        PlaybackErrorKind.unsupportedFormat,
        'The experimental engine currently supports basic MP4 only.',
      );
    }

    final leaseToken = await _claimExclusiveLease();
    if (_disposed || generation != _generation || !_ownsLease(leaseToken)) {
      _releaseLease(leaseToken);
      throw const PlaybackException(
        PlaybackErrorKind.decoderFailure,
        'The experimental video engine open was superseded.',
      );
    }

    _state.value = const PlaybackEngineState(
      phase: PlaybackEnginePhase.loading,
      isBuffering: true,
    );
    late final BetterPlayerDriver driver;
    try {
      driver = _driverFactory();
    } on Object {
      _state.value = const PlaybackEngineState(
        phase: PlaybackEnginePhase.failed,
        error: PlaybackEngineFailure(
          message: 'The experimental video engine could not start.',
          severity: PlaybackEngineErrorSeverity.fatal,
        ),
      );
      _generation++;
      _releaseLease(leaseToken);
      throw const PlaybackException(
        PlaybackErrorKind.decoderFailure,
        'The experimental video engine could not start.',
      );
    }
    _driver = driver;
    void listener() => _driverChanged(driver, generation);
    _driverListener = listener;
    driver.state.addListener(listener);

    final readiness = _BetterPlayerReadiness(generation);
    _readiness = readiness;
    final ready = readiness.completer.future.timeout(readinessTimeout);
    unawaited(_openDriver(driver, manifest, generation));

    try {
      await ready;
      _ensureCurrent(driver, generation);
      final start = boundedPlaybackStart(
        startPosition,
        driver.state.value.duration,
      );
      if (start > Duration.zero) {
        await driver.seek(start).timeout(commandTimeout);
      }
      // Opening never decides autoplay. The caller may play only after the
      // exact, binding-specific resume has been applied.
      await driver.pause().timeout(commandTimeout);
      _ensureCurrent(driver, generation);
      _publishDriverState(driver.state.value);
    } on Object {
      if (_isCurrent(driver, generation)) {
        _state.value = const PlaybackEngineState(
          phase: PlaybackEnginePhase.failed,
          error: PlaybackEngineFailure(
            message: 'The experimental video engine could not open this MP4.',
            severity: PlaybackEngineErrorSeverity.fatal,
          ),
        );
        _generation++;
        await _retireDriver();
        _releaseLease(leaseToken);
      }
      throw const PlaybackException(
        PlaybackErrorKind.decoderFailure,
        'The experimental video engine could not open this MP4.',
      );
    } finally {
      if (identical(_readiness, readiness)) _readiness = null;
    }
  }

  Future<void> _openDriver(
    BetterPlayerDriver driver,
    PlaybackManifest manifest,
    int generation,
  ) async {
    try {
      await driver.open(manifest);
      if (_isCurrent(driver, generation)) {
        _driverChanged(driver, generation);
      }
    } on Object {
      if (!_isCurrent(driver, generation)) return;
      _completeReadinessWithError(
        generation,
        const PlaybackException(
          PlaybackErrorKind.decoderFailure,
          'The experimental video engine could not open this MP4.',
        ),
      );
    }
  }

  void _driverChanged(BetterPlayerDriver driver, int generation) {
    if (!_isCurrent(driver, generation)) return;
    final value = driver.state.value;
    if (value.failureMessage != null) {
      _state.value = const PlaybackEngineState(
        phase: PlaybackEnginePhase.failed,
        error: PlaybackEngineFailure(
          message: 'The experimental video engine could not decode this MP4.',
          severity: PlaybackEngineErrorSeverity.fatal,
        ),
      );
      _completeReadinessWithError(
        generation,
        const PlaybackException(
          PlaybackErrorKind.decoderFailure,
          'The experimental video engine could not decode this MP4.',
        ),
      );
      unawaited(_retireFailedDriver(driver, generation));
      return;
    }
    if (!value.initialized) return;
    _publishDriverState(value);
    final readiness = _readiness;
    if (readiness?.generation == generation &&
        !(readiness?.completer.isCompleted ?? true)) {
      readiness!.completer.complete();
    }
  }

  void _publishDriverState(BetterPlayerDriverState value) {
    if (_disposed || !value.initialized) return;
    final completed =
        value.duration > Duration.zero && value.position >= value.duration;
    _state.value = PlaybackEngineState(
      phase: completed
          ? PlaybackEnginePhase.completed
          : PlaybackEnginePhase.ready,
      position: value.position,
      duration: value.duration,
      isPlaying: value.isPlaying,
      isBuffering: value.isBuffering,
      playbackRate: value.playbackRate,
      intrinsicAspectRatio: value.intrinsicAspectRatio,
    );
  }

  void _completeReadinessWithError(int generation, Object error) {
    final readiness = _readiness;
    if (readiness?.generation == generation &&
        !(readiness?.completer.isCompleted ?? true)) {
      readiness!.completer.completeError(error);
    }
  }

  bool _isCurrent(BetterPlayerDriver driver, int generation) =>
      !_disposed &&
      generation == _generation &&
      identical(driver, _driver) &&
      _leaseToken != null &&
      identical(_leaseOwner, this);

  Future<int> _claimExclusiveLease() async {
    while (true) {
      final pending = _leaseOperation;
      if (pending != null) {
        await pending;
        continue;
      }
      final completion = Completer<void>();
      final operation = completion.future;
      _leaseOperation = operation;
      try {
        if (_disposed) throw StateError('The video engine has been disposed.');
        final previous = _leaseOwner;
        if (previous != null && !identical(previous, this)) {
          await previous._revokeLeaseForReplacement();
        }
        if (_disposed) {
          throw StateError('The video engine has been disposed.');
        }
        final token = ++_nextLeaseToken;
        _leaseOwner = this;
        _leaseToken = token;
        return token;
      } finally {
        if (identical(_leaseOperation, operation)) _leaseOperation = null;
        completion.complete();
      }
    }
  }

  bool _ownsLease(int token) =>
      identical(_leaseOwner, this) && _leaseToken == token;

  void _releaseLease([int? expectedToken]) {
    if (!identical(_leaseOwner, this)) return;
    if (expectedToken != null && _leaseToken != expectedToken) return;
    _leaseOwner = null;
    _leaseToken = null;
  }

  Future<void> _revokeLeaseForReplacement() async {
    final leaseToken = _leaseToken;
    _generation++;
    _cancelPendingReadiness();
    await _retireDriver();
    _releaseLease(leaseToken);
    if (!_disposed) {
      _state.value = const PlaybackEngineState(
        phase: PlaybackEnginePhase.failed,
        error: PlaybackEngineFailure(
          message: 'This experimental playback session was replaced.',
          severity: PlaybackEngineErrorSeverity.recoverable,
        ),
      );
    }
  }

  Future<void> _retireFailedDriver(
    BetterPlayerDriver driver,
    int generation,
  ) async {
    if (!_isCurrent(driver, generation)) return;
    final leaseToken = _leaseToken;
    _generation++;
    await _retireDriver();
    _releaseLease(leaseToken);
  }

  void _ensureCurrent(BetterPlayerDriver driver, int generation) {
    if (!_isCurrent(driver, generation)) {
      throw const PlaybackException(
        PlaybackErrorKind.decoderFailure,
        'The experimental video engine open was superseded.',
      );
    }
  }

  void _cancelPendingReadiness() {
    final readiness = _readiness;
    _readiness = null;
    if (readiness != null && !readiness.completer.isCompleted) {
      readiness.completer.completeError(
        const PlaybackException(
          PlaybackErrorKind.decoderFailure,
          'The experimental video engine open was superseded.',
        ),
      );
    }
  }

  Future<void> _retireDriver() {
    final pending = _driverRetirement;
    if (pending != null) return pending;
    final driver = _driver;
    final listener = _driverListener;
    _driver = null;
    _driverListener = null;
    if (driver == null) return Future<void>.value();
    final operation = _disposeDriver(driver, listener);
    _driverRetirement = operation;
    return operation.whenComplete(() {
      if (identical(_driverRetirement, operation)) {
        _driverRetirement = null;
      }
    });
  }

  Future<void> _disposeDriver(
    BetterPlayerDriver driver,
    VoidCallback? listener,
  ) async {
    if (listener != null) driver.state.removeListener(listener);
    try {
      await driver.dispose();
    } on Object {
      // Native teardown is best-effort and must never leak a raw locator via
      // an uncaught disposal failure.
    }
  }

  BetterPlayerDriver _requireDriver() {
    final driver = _driver;
    if (_disposed || driver == null || !driver.state.value.initialized) {
      throw StateError('The video engine is not ready.');
    }
    return driver;
  }

  @override
  Widget buildSurface() => _driver?.buildSurface() ?? const SizedBox.shrink();

  @override
  Future<void> play() => _requireDriver().play();

  @override
  Future<void> pause() => _requireDriver().pause();

  @override
  Future<void> seek(Duration position) {
    final driver = _requireDriver();
    return driver.seek(boundedSeek(position, _state.value.duration));
  }

  @override
  Future<void> setPlaybackRate(double rate) =>
      _requireDriver().setPlaybackRate(rate);

  @override
  Future<void> selectAudioTrack(String id) =>
      Future.error(UnsupportedError('Audio track selection is not certified.'));

  @override
  Future<void> selectSubtitleTrack(String? id) => Future.error(
    UnsupportedError('Subtitle track selection is not certified.'),
  );

  @override
  Future<void> dispose() {
    final pending = _disposeFuture;
    if (pending != null) return pending;
    final operation = _disposeEngine();
    _disposeFuture = operation;
    return operation;
  }

  Future<void> _disposeEngine() async {
    _disposed = true;
    _generation++;
    final leaseToken = _leaseToken;
    _cancelPendingReadiness();
    await _retireDriver();
    _releaseLease(leaseToken);
    _state.value = const PlaybackEngineState(
      phase: PlaybackEnginePhase.disposed,
    );
    _state.dispose();
  }

  static bool _isBasicMp4(PlaybackManifest manifest) {
    if (!manifest.uri.path.toLowerCase().endsWith('.mp4')) return false;
    if (manifest.isLocalFile) return manifest.uri.scheme == 'file';
    return manifest.uri.scheme == 'http' || manifest.uri.scheme == 'https';
  }
}

class _BetterPlayerReadiness {
  _BetterPlayerReadiness(this.generation);
  final int generation;
  final Completer<void> completer = Completer<void>();
}

/// Thin package bridge. It is deliberately invisible to product widgets.
class OriginalBetterPlayerDriver implements BetterPlayerDriver {
  static const loggerConfiguration = PlayerLoggerConfiguration(
    logLevel: PlayerLogLevel.none,
    printCallerInfo: false,
    outputs: [],
  );

  static const controllerConfiguration = PlayerConfiguration(
    autoPlay: false,
    looping: false,
    fullScreenByDefault: false,
    handleLifecycle: false,
    autoDispose: false,
    expandToFill: true,
    fit: BoxFit.fill,
    controlsConfiguration: PlayerControlsConfiguration(
      showControls: false,
      showControlsOnInitialize: false,
      enableFullscreen: false,
      enableMute: false,
      enableProgressText: false,
      enableProgressBar: false,
      enableProgressBarDrag: false,
      enablePlayPause: false,
      enableSkips: false,
      enableAudioTracks: false,
      enableOverflowMenu: false,
      enablePlaybackSpeed: false,
      enableSubtitles: false,
      enableQualities: false,
      enablePip: false,
      enableRetry: false,
    ),
    playerLogConfiguration: loggerConfiguration,
  );

  final ValueNotifier<BetterPlayerDriverState> _state = ValueNotifier(
    const BetterPlayerDriverState(),
  );
  BetterPlayerController? _controller;
  ValueListenable<VideoPlayerValue>? _videoState;
  bool _disposed = false;

  @override
  ValueListenable<BetterPlayerDriverState> get state => _state;

  @override
  Future<void> open(PlaybackManifest manifest) {
    final completion = Completer<void>();
    runZonedGuarded(
      () async {
        try {
          await _openInsideGuardedZone(manifest);
          if (!completion.isCompleted) completion.complete();
        } on Object {
          _recordSanitizedFailure();
          if (!completion.isCompleted) {
            completion.completeError(_sanitizedDriverFailure());
          }
        }
      },
      (Object _, StackTrace __) {
        // better_player's post-initialization video event subscription has no
        // onError callback. Contain its raw PlatformException in this
        // persistent zone so URLs and headers cannot reach the root logger.
        _recordSanitizedFailure();
        if (!completion.isCompleted) {
          completion.completeError(_sanitizedDriverFailure());
        }
      },
    );
    return completion.future;
  }

  Future<void> _openInsideGuardedZone(PlaybackManifest manifest) async {
    if (_disposed) throw StateError('The Better Player driver is disposed.');
    if (_controller != null) {
      throw StateError('The Better Player driver has already been opened.');
    }
    final controller = BetterPlayerController(controllerConfiguration);
    _controller = controller;
    controller.addEventsListener(_handleEvent);
    await controller.setupDataSource(dataSourceFor(manifest));
    if (_disposed || !identical(controller, _controller)) return;
    _attachVideoState();
    // Zanka's native bridge remains the single audio-focus owner.
    controller.setMixWithOthers(true);
    _syncFromController();
  }

  StateError _sanitizedDriverFailure() =>
      StateError('The experimental video engine could not open this MP4.');

  void _recordSanitizedFailure() {
    if (_disposed) return;
    _state.value = const BetterPlayerDriverState(
      failureMessage: 'Better Player could not decode this MP4.',
    );
  }

  @visibleForTesting
  static PlayerDataSource dataSourceFor(PlaybackManifest manifest) =>
      PlayerDataSource(
        manifest.isLocalFile ? DataSourceType.file : DataSourceType.network,
        manifest.isLocalFile
            ? manifest.uri.toFilePath()
            : manifest.uri.toString(),
        headers: manifest.httpHeaders,
        useAsmsSubtitles: false,
        useAsmsTracks: false,
        useAsmsAudioTracks: false,
        notificationConfiguration: const NotificationConfiguration(
          showNotification: false,
        ),
        videoFormat: VideoFormat.other,
      );

  void _handleEvent(PlayerEvent event) {
    if (_disposed) return;
    switch (event.betterPlayerEventType) {
      case PlayerEventType.setupDataSource:
      case PlayerEventType.initialized:
        _attachVideoState();
        _syncFromController();
      case PlayerEventType.exception:
        _state.value = const BetterPlayerDriverState(
          failureMessage: 'Better Player could not decode this MP4.',
        );
      default:
        _syncFromController();
    }
  }

  void _attachVideoState() {
    final next = _controller?.videoPlayerController;
    if (identical(next, _videoState)) return;
    _videoState?.removeListener(_syncFromController);
    _videoState = next;
    _videoState?.addListener(_syncFromController);
  }

  void _syncFromController() {
    if (_disposed || _state.value.failureMessage != null) return;
    final value = _controller?.videoPlayerController?.value;
    if (value == null) return;
    if (value.hasError) {
      _state.value = const BetterPlayerDriverState(
        failureMessage: 'Better Player could not decode this MP4.',
      );
      return;
    }
    final size = value.size;
    final ratio = size != null && size.width > 0 && size.height > 0
        ? size.width / size.height
        : null;
    _state.value = BetterPlayerDriverState(
      initialized: value.initialized,
      position: value.position,
      duration: value.duration ?? Duration.zero,
      isPlaying: value.isPlaying,
      isBuffering: value.isBuffering,
      playbackRate: value.speed,
      intrinsicAspectRatio: ratio,
    );
  }

  BetterPlayerController _requireController() {
    final controller = _controller;
    if (_disposed || controller == null) {
      throw StateError('The Better Player driver is not ready.');
    }
    return controller;
  }

  @override
  Widget buildSurface() {
    final textureId = _controller?.textureId;
    if (textureId == null) return const SizedBox.shrink();
    // Render only the decoder texture. Better Player's controls/aspect-ratio
    // widget is intentionally bypassed so Zanka's Display Mode owns geometry.
    return SizedBox.expand(
      child: BetterPlayerPlatform.instance.buildView(textureId),
    );
  }

  @override
  Future<void> play() => _requireController().play();

  @override
  Future<void> pause() => _requireController().pause();

  @override
  Future<void> seek(Duration position) => _requireController().seekTo(position);

  @override
  Future<void> setPlaybackRate(double rate) =>
      _requireController().setSpeed(rate);

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final controller = _controller;
    _controller = null;
    _videoState?.removeListener(_syncFromController);
    _videoState = null;
    if (controller != null) {
      controller.removeEventsListener(_handleEvent);
      final textureId = controller.textureId;
      controller.dispose(forceDispose: true);
      if (textureId != null) {
        try {
          // BetterPlayerController.dispose starts this asynchronously. Await a
          // direct idempotent platform disposal too, so the broadcast Android
          // bridge has removed the old texture before a new lease can open.
          await BetterPlayerPlatform.instance.dispose(textureId);
        } on Object {
          // Teardown errors are intentionally contained and never logged.
        }
      }
      await Future<void>.delayed(Duration.zero);
    }
    _state.dispose();
  }
}
