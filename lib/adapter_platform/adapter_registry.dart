import '../canonical/domain/identifiers.dart';
import 'adapter_descriptor.dart';
import 'adapter_errors.dart';
import 'adapter_sdk.dart';

class AdapterRegistration {
  const AdapterRegistration({
    required this.descriptor,
    this.catalog,
    this.search,
    this.details,
    this.enrichment,
  });
  final AdapterDescriptor descriptor;
  final CatalogAdapter? catalog;
  final SearchAdapter? search;
  final DetailsAdapter? details;
  final MetadataEnrichmentAdapter? enrichment;
}

class AdapterRegistry {
  AdapterRegistry(Iterable<AdapterRegistration> registrations)
    : _registrations = {
        for (final registration in registrations)
          registration.descriptor.id: registration,
      } {
    for (final registration in _registrations.values) {
      _validate(registration);
    }
  }

  final Map<AdapterId, AdapterRegistration> _registrations;
  List<AdapterDescriptor> get descriptors =>
      _registrations.values.map((value) => value.descriptor).toList();

  AdapterRegistration require(AdapterId id) {
    final value = _registrations[id];
    if (value == null) {
      throw AdapterUnavailable(id, 'Adapter is not registered');
    }
    return value;
  }

  AdapterDescriptor descriptorFor(ProviderId id) =>
      require(AdapterId(id.value)).descriptor;

  void validateSourceRegistries({
    required Set<ProviderId> readerProviderIds,
    required Set<ProviderId> playbackProviderIds,
  }) {
    for (final descriptor in descriptors) {
      final provider = descriptor.id.providerId;
      if (descriptor.supports(AdapterCapability.readerManifest) !=
          readerProviderIds.contains(provider)) {
        throw StateError('${descriptor.id.value} reader registry disagrees');
      }
      if (descriptor.supports(AdapterCapability.playbackManifest) !=
          playbackProviderIds.contains(provider)) {
        throw StateError('${descriptor.id.value} playback registry disagrees');
      }
    }
  }

  T requireCapability<T>(AdapterId id, AdapterCapability capability) {
    final registration = require(id);
    final Object? component = switch (capability) {
      AdapterCapability.catalog => registration.catalog,
      AdapterCapability.search => registration.search,
      AdapterCapability.details => registration.details,
      AdapterCapability.metadataEnrichment => registration.enrichment,
      _ => null,
    };
    if (!registration.descriptor.supports(capability) || component is! T) {
      throw AdapterUnsupportedCapability(
        id,
        '${registration.descriptor.displayName} does not support ${capability.name}',
      );
    }
    return component;
  }

  void _validate(AdapterRegistration value) {
    final descriptor = value.descriptor;
    final declared = <AdapterCapability, Object?>{
      AdapterCapability.catalog: value.catalog,
      AdapterCapability.search: value.search,
      AdapterCapability.details: value.details,
      AdapterCapability.metadataEnrichment: value.enrichment,
    };
    for (final entry in declared.entries) {
      if (descriptor.supports(entry.key) != (entry.value != null)) {
        throw StateError(
          '${descriptor.id.value} declaration disagrees for ${entry.key.name}',
        );
      }
    }
  }

  static List<AdapterDescriptor> coreDescriptors() => const [
    AdapterDescriptor(
      id: AdapterId('mangaworld'),
      displayName: 'MangaWorld',
      scope: AdapterMediaScope.manga,
      capabilities: {
        AdapterCapability.catalog,
        AdapterCapability.search,
        AdapterCapability.details,
        AdapterCapability.chapterMetadata,
        AdapterCapability.coverAsset,
        AdapterCapability.pagination,
        AdapterCapability.readerManifest,
      },
    ),
    AdapterDescriptor(
      id: AdapterId('animeworld'),
      displayName: 'AnimeWorld',
      scope: AdapterMediaScope.anime,
      capabilities: {
        AdapterCapability.catalog,
        AdapterCapability.search,
        AdapterCapability.details,
        AdapterCapability.episodeMetadata,
        AdapterCapability.coverAsset,
        AdapterCapability.pagination,
        AdapterCapability.playbackManifest,
      },
    ),
    AdapterDescriptor(
      id: AdapterId('local-import-manga'),
      displayName: 'Local Manga',
      scope: AdapterMediaScope.manga,
      capabilities: {
        AdapterCapability.chapterMetadata,
        AdapterCapability.readerManifest,
        AdapterCapability.coverAsset,
      },
      isLocal: true,
    ),
    AdapterDescriptor(
      id: AdapterId('local-import-video'),
      displayName: 'Local Video',
      scope: AdapterMediaScope.anime,
      capabilities: {
        AdapterCapability.episodeMetadata,
        AdapterCapability.playbackManifest,
        AdapterCapability.coverAsset,
      },
      isLocal: true,
    ),
    AdapterDescriptor(
      id: AdapterId('local-folder'),
      displayName: 'Sample Local Manga',
      scope: AdapterMediaScope.manga,
      capabilities: {AdapterCapability.readerManifest},
      isLocal: true,
    ),
    AdapterDescriptor(
      id: AdapterId('local-video'),
      displayName: 'Sample Local Video',
      scope: AdapterMediaScope.anime,
      capabilities: {AdapterCapability.playbackManifest},
      isLocal: true,
    ),
  ];
}
