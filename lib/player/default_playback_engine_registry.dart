import 'better_player_engine_builder_stub.dart'
    if (dart.library.io) 'better_player_engine_builder_io.dart';
import 'playback_engine.dart';
import 'video_player_playback_engine.dart';
import '../app/build_profile.dart';

/// Application composition for playback engines.
///
/// Automatic is always the production video_player adapter. The experimental
/// builder is exposed only on Android, the platform covered by M19-B.
PlaybackEngineRegistry defaultPlaybackEngineRegistry() =>
    BuildProfile.current.allowsExperimentalEngines
    ? PlaybackEngineRegistry(
        productionBuilder: VideoPlayerPlaybackEngine.new,
        betterPlayerExperimentalBuilder:
            betterPlayerExperimentalBuilderForPlatform(),
      )
    : const _ProductionRegistry();

// Old device-local experiment preferences must not activate an experiment or
// expose an internal fallback message in production. No saved value is rewritten.
class _ProductionRegistry extends PlaybackEngineRegistry {
  const _ProductionRegistry()
    : super(productionBuilder: VideoPlayerPlaybackEngine.new);

  @override
  PlaybackEngineSelection create([
    PlaybackEnginePreference preference = PlaybackEnginePreference.automatic,
  ]) => super.create(PlaybackEnginePreference.automatic);
}
