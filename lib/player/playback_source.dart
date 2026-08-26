import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import 'playback_domain.dart';

abstract interface class PlaybackSourceResolver {
  ProviderId get providerId;
  PlaybackSourceCapability capability(EpisodeSourceBinding binding);
  Future<PlaybackManifest> resolve(PlaybackSessionRequest request);
}

/// Opt-in for remote sources whose ephemeral playback locator may safely be
/// resolved once more after a temporary session-open failure.
abstract interface class FreshPlaybackManifestRetry {}

abstract interface class FreshPlaybackRetryObserver {
  void recordMediaInitializationFailure(EpisodeSourceBinding binding);
  void recordMediaInitializationRecovery(EpisodeSourceBinding binding);
}

class PlaybackSourceRegistry {
  PlaybackSourceRegistry(Iterable<PlaybackSourceResolver> resolvers)
    : _resolvers = {for (final item in resolvers) item.providerId: item};
  final Map<ProviderId, PlaybackSourceResolver> _resolvers;
  Set<ProviderId> get providerIds => _resolvers.keys.toSet();
  PlaybackSourceCapability capability(EpisodeSourceBinding binding) =>
      _resolvers[binding.providerId]?.capability(binding) ??
      PlaybackSourceCapability.metadataOnly;
  PlaybackSourceResolver? resolver(ProviderId providerId) =>
      _resolvers[providerId];
}
