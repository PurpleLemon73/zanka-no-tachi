import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';

final class AdapterId {
  const AdapterId(this.value) : assert(value != '');
  final String value;
  ProviderId get providerId => ProviderId(value);
  @override
  bool operator ==(Object other) => other is AdapterId && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

enum AdapterMediaScope { manga, anime, mixed }

enum AdapterCapability {
  catalog,
  search,
  details,
  chapterMetadata,
  episodeMetadata,
  readerManifest,
  playbackManifest,
  coverAsset,
  metadataEnrichment,
  pagination,
}

enum AdapterStatus { ready, disabled, unavailable, parserMismatch }

class AdapterDescriptor {
  const AdapterDescriptor({
    required this.id,
    required this.displayName,
    required this.scope,
    required this.capabilities,
    this.isLocal = false,
  });
  final AdapterId id;
  final String displayName;
  final AdapterMediaScope scope;
  final Set<AdapterCapability> capabilities;
  final bool isLocal;

  bool supports(AdapterCapability capability) =>
      capabilities.contains(capability);

  bool supportsKind(CanonicalMediaKind kind) =>
      scope == AdapterMediaScope.mixed ||
      (scope == AdapterMediaScope.manga && kind == CanonicalMediaKind.manga) ||
      (scope == AdapterMediaScope.anime && kind == CanonicalMediaKind.anime);
}
