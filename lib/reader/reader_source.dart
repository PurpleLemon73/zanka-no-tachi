import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import 'reader_domain.dart';

abstract interface class ReaderSourceResolver {
  ProviderId get providerId;
  ReaderSourceCapability capability(ChapterSourceBinding binding);
  Future<ReaderManifest> resolve(ReaderSessionRequest request);
}

class ReaderSourceRegistry {
  ReaderSourceRegistry(Iterable<ReaderSourceResolver> resolvers)
    : _resolvers = {
        for (final resolver in resolvers) resolver.providerId: resolver,
      };

  final Map<ProviderId, ReaderSourceResolver> _resolvers;
  Set<ProviderId> get providerIds => _resolvers.keys.toSet();

  ReaderSourceCapability capability(ChapterSourceBinding binding) =>
      _resolvers[binding.providerId]?.capability(binding) ??
      ReaderSourceCapability.metadataOnly;

  ReaderSourceResolver? resolver(ProviderId providerId) =>
      _resolvers[providerId];
}
