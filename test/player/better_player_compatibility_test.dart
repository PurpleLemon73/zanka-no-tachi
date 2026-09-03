import 'package:better_player/better_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('original Better Player public library compiles and initializes', () {
    const configuration = PlayerConfiguration(
      autoPlay: false,
      handleLifecycle: false,
      autoDispose: false,
      controlsConfiguration: PlayerControlsConfiguration(
        showControls: false,
        showControlsOnInitialize: false,
        enablePip: false,
      ),
      playerLogConfiguration: PlayerLoggerConfiguration(
        logLevel: PlayerLogLevel.none,
        printCallerInfo: false,
        outputs: [],
      ),
    );
    final controller = BetterPlayerController(configuration);

    expect(controller.betterPlayerConfiguration, same(configuration));
    expect(
      BetterPlayerUiUtils.formatDuration(const Duration(seconds: 65)),
      '01:05',
    );

    controller.dispose(forceDispose: true);
  });
}
