import '../canonical/domain/identifiers.dart';
import '../canonical/persistence/canonical_database.dart';
import 'adapter_descriptor.dart';
import 'adapter_errors.dart';
import 'adapter_sdk.dart';

class MetadataEnrichmentService {
  const MetadataEnrichmentService(this.database, this.adapters);
  final CanonicalDatabase database;
  final List<MetadataEnrichmentAdapter> adapters;

  Future<MetadataEnrichment> enrichReviewed(
    CanonicalMediaId mediaId,
    AdapterId adapterId,
  ) async {
    final media = await database.media(mediaId);
    if (media == null) {
      throw AdapterEnrichmentConflict(adapterId, 'Canonical media is missing');
    }
    final adapter = adapters
        .where((value) => value.descriptor.id == adapterId)
        .firstOrNull;
    if (adapter == null) {
      throw AdapterUnsupportedCapability(
        adapterId,
        'No metadata enrichment implementation is registered',
      );
    }
    final result = await adapter.enrich(
      EnrichmentRequest(media: media, reviewed: true),
    );
    await database.saveEnrichment(mediaId, result);
    return result;
  }
}

class DeterministicEnrichmentAdapter implements MetadataEnrichmentAdapter {
  const DeterministicEnrichmentAdapter();

  @override
  AdapterDescriptor get descriptor => const AdapterDescriptor(
    id: AdapterId('deterministic-enrichment'),
    displayName: 'Deterministic Metadata',
    scope: AdapterMediaScope.mixed,
    capabilities: {AdapterCapability.metadataEnrichment},
  );

  @override
  Future<MetadataEnrichment> enrich(EnrichmentRequest request) async {
    if (!request.reviewed) {
      throw const AdapterEnrichmentConflict(
        AdapterId('deterministic-enrichment'),
        'Enrichment requires reviewed canonical attachment',
      );
    }
    return MetadataEnrichment(
      adapterId: descriptor.id,
      alternateTitles: ['${request.media.title.value} · enriched'],
      genres: request.media.genres.map((value) => value.value).toList(),
    );
  }
}
