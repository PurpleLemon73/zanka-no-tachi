import 'dart:io';

import 'better_player_playback_engine.dart';
import 'playback_engine.dart';

PlaybackEngineBuilder? betterPlayerExperimentalBuilderForPlatform() =>
    Platform.isAndroid ? BetterPlayerPlaybackEngine.new : null;
