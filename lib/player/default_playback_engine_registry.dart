import 'better_player_engine_builder_stub.dart'
    if (dart.library.io) 'better_player_engine_builder_io.dart';
import 'playback_engine.dart';
import 'video_player_playback_engine.dart';

/// Application composition for playback engines.
///
/// Automatic is always the production video_player adapter. The experimental
/// builder is exposed only on Android, the platform covered by M19-B.
PlaybackEngineRegistry defaultPlaybackEngineRegistry() =>
    PlaybackEngineRegistry(
      productionBuilder: VideoPlayerPlaybackEngine.new,
      betterPlayerExperimentalBuilder:
          betterPlayerExperimentalBuilderForPlatform(),
    );
