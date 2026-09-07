import 'dart:async';

import 'package:better_player/better_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/player/better_player_playback_engine.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_engine.dart';

void main() {
  test('experimental engine advertises only certified MP4 capabilities', () {
    final engine = BetterPlayerPlaybackEngine(
      driverFactory: _FakeBetterPlayerDriver.new,
    );

    expect(engine.kind, PlaybackEngineKind.betterPlayerExperimental);
    expect(engine.capabilities.canSeek, isTrue);
    expect(engine.capabilities.canSetPlaybackRate, isTrue);
    expect(engine.capabilities.supportsHls, isFalse);
    expect(engine.capabilities.supportsDash, isFalse);
    expect(engine.capabilities.canSelectAudioTrack, isFalse);
    expect(engine.capabilities.canSelectSubtitleTrack, isFalse);
  });

  test('real bridge permanently disables package logging and extras', () {
    const logger = OriginalBetterPlayerDriver.loggerConfiguration;
    const configuration = OriginalBetterPlayerDriver.controllerConfiguration;
    expect(logger.logLevel, PlayerLogLevel.none);
    expect(logger.printCallerInfo, isFalse);
    expect(logger.outputs, isEmpty);
    expect(configuration.playerLogConfiguration, same(logger));
    expect(configuration.autoPlay, isFalse);
    expect(configuration.handleLifecycle, isFalse);
    expect(configuration.autoDispose, isFalse);
    expect(configuration.controlsConfiguration.showControls, isFalse);
    expect(configuration.controlsConfiguration.enablePip, isFalse);

    final source = OriginalBetterPlayerDriver.dataSourceFor(
      _manifest('https://media.invalid/basic.mp4?ephemeral=secret'),
    );
    expect(source.type, DataSourceType.network);
    expect(source.videoFormat, VideoFormat.other);
    expect(source.useAsmsTracks, isFalse);
    expect(source.useAsmsAudioTracks, isFalse);
    expect(source.useAsmsSubtitles, isFalse);
    expect(source.notificationConfiguration?.showNotification, isFalse);
  });

  testWidgets('open applies exact bounded resume while remaining paused', (
    tester,
  ) async {
    final driver = _FakeBetterPlayerDriver(
      openedState: const BetterPlayerDriverState(
        initialized: true,
        duration: Duration(seconds: 100),
        isPlaying: true,
        intrinsicAspectRatio: 4 / 3,
      ),
    );
    final engine = BetterPlayerPlaybackEngine(driverFactory: () => driver);

    await engine.open(
      _manifest('https://media.invalid/basic.mp4'),
      startPosition: const Duration(seconds: 37),
    );

    expect(driver.seekCalls, [const Duration(seconds: 37)]);
    expect(driver.pauseCalls, 1);
    expect(engine.state.value.position, const Duration(seconds: 37));
    expect(engine.state.value.isPlaying, isFalse);
    expect(engine.state.value.intrinsicAspectRatio, 4 / 3);
    await tester.pumpWidget(engine.buildSurface());
    expect(find.byKey(const Key('fake-better-player-surface')), findsOneWidget);
    await engine.dispose();
  });

  test('resume at or beyond duration resets safely to the beginning', () async {
    final driver = _FakeBetterPlayerDriver(
      openedState: const BetterPlayerDriverState(
        initialized: true,
        duration: Duration(seconds: 20),
      ),
    );
    final engine = BetterPlayerPlaybackEngine(driverFactory: () => driver);

    await engine.open(
      _manifest('file:///tmp/basic.mp4'),
      startPosition: const Duration(seconds: 20),
    );

    expect(driver.seekCalls, isEmpty);
    expect(engine.state.value.position, Duration.zero);
    await engine.dispose();
  });

  test('non-MP4 sources fail before a package driver is constructed', () async {
    var factoryCalls = 0;
    final engine = BetterPlayerPlaybackEngine(
      driverFactory: () {
        factoryCalls++;
        return _FakeBetterPlayerDriver();
      },
    );

    await expectLater(
      engine.open(_manifest('https://media.invalid/master.m3u8')),
      throwsA(
        isA<PlaybackException>().having(
          (error) => error.kind,
          'kind',
          PlaybackErrorKind.unsupportedFormat,
        ),
      ),
    );
    expect(factoryCalls, 0);
    expect(engine.state.value.phase, PlaybackEnginePhase.failed);
    await engine.dispose();
  });

  test('unsupported replacement fully retires the active MP4', () async {
    final driver = _FakeBetterPlayerDriver(
      openedState: const BetterPlayerDriverState(
        initialized: true,
        duration: Duration(seconds: 20),
      ),
    );
    final engine = BetterPlayerPlaybackEngine(driverFactory: () => driver);
    await engine.open(_manifest('https://media.invalid/basic.mp4'));

    await expectLater(
      engine.open(_manifest('https://media.invalid/master.m3u8')),
      throwsA(
        isA<PlaybackException>().having(
          (error) => error.kind,
          'kind',
          PlaybackErrorKind.unsupportedFormat,
        ),
      ),
    );

    expect(driver.disposeCalls, 1);
    expect(engine.state.value.phase, PlaybackEnginePhase.failed);
    await engine.dispose();
    expect(driver.disposeCalls, 1);
  });

  test('readiness is bounded and failures do not expose locators', () async {
    final driver = _FakeBetterPlayerDriver();
    final engine = BetterPlayerPlaybackEngine(
      driverFactory: () => driver,
      readinessTimeout: const Duration(milliseconds: 5),
    );

    await expectLater(
      engine.open(
        _manifest('https://secret.invalid/private/basic.mp4?token=do-not-log'),
      ),
      throwsA(isA<PlaybackException>()),
    );
    final failure = engine.state.value.error.toString();
    expect(failure, isNot(contains('secret.invalid')));
    expect(failure, isNot(contains('do-not-log')));
    expect(driver.disposeCalls, 1);
    driver.emit(
      const BetterPlayerDriverState(
        initialized: true,
        duration: Duration(seconds: 10),
      ),
    );
    expect(engine.state.value.phase, PlaybackEnginePhase.failed);
    await engine.dispose();
  });

  test('driver source errors become sanitized fatal failures', () async {
    final driver = _FakeBetterPlayerDriver(
      openedState: const BetterPlayerDriverState(
        failureMessage:
            'https://secret.invalid/basic.mp4?token=must-not-escape',
      ),
    );
    final engine = BetterPlayerPlaybackEngine(driverFactory: () => driver);

    await expectLater(
      engine.open(_manifest('https://secret.invalid/basic.mp4')),
      throwsA(isA<PlaybackException>()),
    );

    expect(engine.state.value.phase, PlaybackEnginePhase.failed);
    expect(engine.state.value.error.toString(), isNot(contains('secret')));
    expect(engine.state.value.error.toString(), isNot(contains('token')));
    expect(driver.disposeCalls, 1);
    await engine.dispose();
  });

  test(
    'driver updates normalize buffering, playback, and completion',
    () async {
      final driver = _FakeBetterPlayerDriver(
        openedState: const BetterPlayerDriverState(
          initialized: true,
          duration: Duration(seconds: 10),
        ),
      );
      final engine = BetterPlayerPlaybackEngine(driverFactory: () => driver);
      await engine.open(_manifest('file:///tmp/basic.mp4'));

      driver.emit(
        const BetterPlayerDriverState(
          initialized: true,
          duration: Duration(seconds: 10),
          position: Duration(seconds: 4),
          isPlaying: true,
          isBuffering: true,
          playbackRate: 1.5,
        ),
      );
      expect(engine.state.value.phase, PlaybackEnginePhase.ready);
      expect(engine.state.value.isPlaying, isTrue);
      expect(engine.state.value.isBuffering, isTrue);
      expect(engine.state.value.playbackRate, 1.5);

      driver.emit(
        const BetterPlayerDriverState(
          initialized: true,
          duration: Duration(seconds: 10),
          position: Duration(seconds: 10),
        ),
      );
      expect(engine.state.value.phase, PlaybackEnginePhase.completed);
      await engine.dispose();
    },
  );

  test('events from retired driver generations cannot replace state', () async {
    final first = _FakeBetterPlayerDriver(
      openedState: const BetterPlayerDriverState(
        initialized: true,
        duration: Duration(seconds: 10),
        position: Duration(seconds: 1),
      ),
    );
    final second = _FakeBetterPlayerDriver(
      openedState: const BetterPlayerDriverState(
        initialized: true,
        duration: Duration(seconds: 30),
        position: Duration(seconds: 2),
      ),
    );
    final drivers = [first, second];
    final engine = BetterPlayerPlaybackEngine(
      driverFactory: () => drivers.removeAt(0),
    );

    await engine.open(_manifest('https://media.invalid/first.mp4'));
    await engine.open(_manifest('https://media.invalid/second.mp4'));
    first.emit(
      const BetterPlayerDriverState(
        failureMessage: 'stale source included a private locator',
      ),
    );

    expect(first.disposeCalls, 1);
    expect(engine.state.value.phase, PlaybackEnginePhase.ready);
    expect(engine.state.value.duration, const Duration(seconds: 30));
    await engine.dispose();
  });

  test(
    'a new engine lease fully retires an overlapping Better session',
    () async {
      final firstGate = Completer<void>();
      final firstDisposeGate = Completer<void>();
      final firstDriver = _FakeBetterPlayerDriver(
        openGate: firstGate,
        disposeGate: firstDisposeGate,
        openedState: const BetterPlayerDriverState(
          initialized: true,
          duration: Duration(seconds: 15),
          position: Duration(seconds: 5),
        ),
      );
      final secondDriver = _FakeBetterPlayerDriver(
        openedState: const BetterPlayerDriverState(
          initialized: true,
          duration: Duration(seconds: 30),
          position: Duration(seconds: 2),
        ),
      );
      final firstEngine = BetterPlayerPlaybackEngine(
        driverFactory: () => firstDriver,
      );
      final secondEngine = BetterPlayerPlaybackEngine(
        driverFactory: () => secondDriver,
      );

      final firstOpen = firstEngine.open(
        _manifest('https://media.invalid/first.mp4'),
      );
      final firstFailure = expectLater(
        firstOpen,
        throwsA(isA<PlaybackException>()),
      );
      while (firstDriver.openCalls == 0) {
        await Future<void>.delayed(Duration.zero);
      }

      final secondOpen = secondEngine.open(
        _manifest('https://media.invalid/second.mp4'),
      );
      while (firstDriver.disposeCalls == 0) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(firstDriver.disposeCalls, 1);
      expect(secondDriver.openCalls, 0);

      firstDisposeGate.complete();
      await secondOpen;
      expect(firstEngine.state.value.phase, PlaybackEnginePhase.failed);
      expect(secondEngine.state.value.phase, PlaybackEnginePhase.ready);

      firstGate.complete();
      await firstFailure;
      await Future<void>.delayed(Duration.zero);
      expect(secondEngine.state.value.duration, const Duration(seconds: 30));
      expect(secondEngine.state.value.position, const Duration(seconds: 2));

      await firstEngine.dispose();
      await secondEngine.dispose();
      expect(secondDriver.disposeCalls, 1);
    },
  );

  test('post-initialization failure retires the active driver', () async {
    final driver = _FakeBetterPlayerDriver(
      openedState: const BetterPlayerDriverState(
        initialized: true,
        duration: Duration(seconds: 10),
      ),
    );
    final engine = BetterPlayerPlaybackEngine(driverFactory: () => driver);
    await engine.open(_manifest('file:///tmp/basic.mp4'));

    driver.emit(
      const BetterPlayerDriverState(
        failureMessage: 'private/file/path/basic.mp4?token=must-not-escape',
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(engine.state.value.phase, PlaybackEnginePhase.failed);
    expect(engine.state.value.error.toString(), isNot(contains('private')));
    expect(driver.disposeCalls, 1);
    await engine.dispose();
  });

  test('forced engine disposal is idempotent', () async {
    final disposeGate = Completer<void>();
    final driver = _FakeBetterPlayerDriver(
      disposeGate: disposeGate,
      openedState: const BetterPlayerDriverState(
        initialized: true,
        duration: Duration(seconds: 10),
      ),
    );
    final engine = BetterPlayerPlaybackEngine(driverFactory: () => driver);
    await engine.open(_manifest('file:///tmp/basic.mp4'));

    final firstDispose = engine.dispose();
    final secondDispose = engine.dispose();

    expect(secondDispose, same(firstDispose));
    expect(driver.disposeCalls, 1);
    disposeGate.complete();
    await Future.wait([firstDispose, secondDispose]);
    expect(engine.state.value.phase, PlaybackEnginePhase.disposed);
  });
}

PlaybackManifest _manifest(String locator) => PlaybackManifest(
  sourceName: 'Adapter test',
  binding: const EpisodeSourceBinding(
    canonicalId: CanonicalEpisodeId('episode'),
    providerId: ProviderId('provider'),
    externalId: 'external-episode',
  ),
  uri: Uri.parse(locator),
  isLocalFile: locator.startsWith('file:'),
);

class _FakeBetterPlayerDriver implements BetterPlayerDriver {
  _FakeBetterPlayerDriver({this.openedState, this.openGate, this.disposeGate});

  final BetterPlayerDriverState? openedState;
  final Completer<void>? openGate;
  final Completer<void>? disposeGate;
  final ValueNotifier<BetterPlayerDriverState> _state = ValueNotifier(
    const BetterPlayerDriverState(),
  );
  final List<Duration> seekCalls = [];
  int pauseCalls = 0;
  int disposeCalls = 0;
  int openCalls = 0;

  @override
  ValueListenable<BetterPlayerDriverState> get state => _state;

  void emit(BetterPlayerDriverState value) => _state.value = value;

  @override
  Future<void> open(PlaybackManifest manifest) async {
    openCalls++;
    await openGate?.future;
    if (openedState case final value?) emit(value);
  }

  @override
  Future<void> seek(Duration position) async {
    seekCalls.add(position);
    final current = _state.value;
    emit(
      BetterPlayerDriverState(
        initialized: current.initialized,
        position: position,
        duration: current.duration,
        isPlaying: current.isPlaying,
        isBuffering: current.isBuffering,
        playbackRate: current.playbackRate,
        intrinsicAspectRatio: current.intrinsicAspectRatio,
        failureMessage: current.failureMessage,
      ),
    );
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    final current = _state.value;
    emit(
      BetterPlayerDriverState(
        initialized: current.initialized,
        position: current.position,
        duration: current.duration,
        isPlaying: false,
        isBuffering: current.isBuffering,
        playbackRate: current.playbackRate,
        intrinsicAspectRatio: current.intrinsicAspectRatio,
        failureMessage: current.failureMessage,
      ),
    );
  }

  @override
  Future<void> play() async {}

  @override
  Future<void> setPlaybackRate(double rate) async {}

  @override
  Widget buildSurface() =>
      const SizedBox(key: Key('fake-better-player-surface'));

  @override
  Future<void> dispose() async {
    disposeCalls++;
    await disposeGate?.future;
    // Intentionally keep the notifier alive so tests can simulate a buggy
    // late native callback after disposal.
  }
}
