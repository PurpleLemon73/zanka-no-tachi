import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../live_provider/provider_adapter.dart';
import '../player/playback_domain.dart';
import '../reader/reader_domain.dart';
import 'adapter_descriptor.dart';

final class PaginationCursor {
  const PaginationCursor(this.value) : assert(value != '');
  final String value;
}

class PageRequest {
  const PageRequest({this.cursor, this.pageSize = 24})
    : assert(pageSize > 0 && pageSize <= 50);
  final PaginationCursor? cursor;
  final int pageSize;
  int get page => int.tryParse(cursor?.value ?? '1') ?? 1;
}

class PageResult<T> {
  const PageResult({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });
  final List<T> items;
  final bool hasMore;
  final PaginationCursor? nextCursor;
}

abstract interface class AdapterComponent {
  AdapterDescriptor get descriptor;
}

abstract interface class CatalogAdapter implements AdapterComponent {
  Future<PageResult<ProviderListingItem>> catalog(PageRequest request);
}

abstract interface class SearchAdapter implements AdapterComponent {
  Future<PageResult<ProviderListingItem>> search(
    String query,
    PageRequest request,
  );
}

abstract interface class DetailsAdapter implements AdapterComponent {
  Future<ProviderTitleResult> details(ProviderListingItem item);
}

abstract interface class MetadataEnrichmentAdapter implements AdapterComponent {
  Future<MetadataEnrichment> enrich(EnrichmentRequest request);
}

abstract interface class ReaderManifestAdapter implements AdapterComponent {
  Future<ReaderManifest> readerManifest(ReaderSessionRequest request);
}

abstract interface class PlaybackManifestAdapter implements AdapterComponent {
  Future<PlaybackManifest> playbackManifest(PlaybackSessionRequest request);
}

class EnrichmentRequest {
  const EnrichmentRequest({required this.media, required this.reviewed});
  final CanonicalMedia media;
  final bool reviewed;
}

class MetadataEnrichment {
  const MetadataEnrichment({
    required this.adapterId,
    this.title,
    this.description,
    this.coverLocator,
    this.alternateTitles = const [],
    this.genres = const [],
  });
  final AdapterId adapterId;
  final String? title;
  final String? description;
  final String? coverLocator;
  final List<String> alternateTitles;
  final List<String> genres;
}

class MetadataOverride {
  const MetadataOverride({
    required this.mediaId,
    this.displayTitle,
    this.description,
    this.coverLocator,
    this.alternateTitles = const [],
    this.genres = const [],
    this.status,
    this.animeFormat,
    this.creatorOrStudio,
  });
  final CanonicalMediaId mediaId;
  final String? displayTitle;
  final String? description;
  final String? coverLocator;
  final List<String> alternateTitles;
  final List<String> genres;
  final CanonicalMediaStatus? status;
  final AnimeFormat? animeFormat;
  final String? creatorOrStudio;

  bool get isEmpty =>
      displayTitle == null &&
      description == null &&
      coverLocator == null &&
      alternateTitles.isEmpty &&
      genres.isEmpty &&
      status == null &&
      animeFormat == null &&
      creatorOrStudio == null;
}

enum MetadataOverrideField {
  displayTitle,
  alternateTitles,
  description,
  cover,
  genres,
  status,
  format,
  creatorOrStudio,
}

abstract interface class InstallmentMetadataAdapter
    implements AdapterComponent {
  CanonicalMediaKind get mediaKind;
}

abstract interface class ReaderBindingAdapter implements AdapterComponent {
  bool supportsBinding(ChapterSourceBinding binding);
}

abstract interface class PlaybackBindingAdapter implements AdapterComponent {
  bool supportsBinding(EpisodeSourceBinding binding);
}
