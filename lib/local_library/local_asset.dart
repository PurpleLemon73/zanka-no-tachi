import '../canonical/domain/identifiers.dart';

final class LocalAssetId extends CanonicalId {
  const LocalAssetId(super.value);
}

enum LocalAssetKind { mangaArchive, mangaFolder, video }

enum LocalAssetOwnership { appOwnedCopy, externalReference, bundledSample }

enum LocalAssetState {
  available,
  missing,
  unreadable,
  unsupported,
  pendingPreparation,
}

class LocalAsset {
  const LocalAsset({
    required this.id,
    required this.kind,
    required this.ownership,
    required this.state,
    required this.providerId,
    required this.bindingExternalId,
    required this.mediaId,
    required this.installmentId,
    required this.originalName,
    required this.createdAt,
    required this.updatedAt,
    this.managedRelativePath,
    this.sizeBytes,
  });
  final LocalAssetId id;
  final LocalAssetKind kind;
  final LocalAssetOwnership ownership;
  final LocalAssetState state;
  final ProviderId providerId;
  final String bindingExternalId;
  final CanonicalMediaId mediaId;
  final String installmentId;
  final String originalName;
  final String? managedRelativePath;
  final int? sizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;
}
