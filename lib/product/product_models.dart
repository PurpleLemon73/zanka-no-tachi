import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/media.dart';
import '../canonical/domain/user_state.dart';
import '../canonical/reconciliation/source_availability.dart';
import '../live_provider/provider_adapter.dart';
import '../reader/reader_repository.dart';
import '../player/playback_repository.dart';
import '../adapter_platform/adapter_sdk.dart';
import '../product_maturity/maturity_domain.dart';
import '../local_library/local_asset.dart';

class ProductMediaSummary {
  const ProductMediaSummary({
    required this.media,
    required this.bindings,
    this.library,
    this.mangaProgress,
    this.animeProgress,
    this.progressLabel,
    this.progressCompleted = false,
    this.hasMissingLocalSource = false,
  });

  final CanonicalMedia media;
  final List<MediaSourceBinding> bindings;
  final CanonicalLibraryEntry? library;
  final CanonicalMangaProgress? mangaProgress;
  final CanonicalAnimeProgress? animeProgress;
  final String? progressLabel;
  final bool progressCompleted;
  final bool hasMissingLocalSource;

  bool get isSaved => library?.isSaved ?? false;
  bool get isFavorite => library?.isFavorite ?? false;
  bool get hasProgress => mangaProgress != null || animeProgress != null;
}

class ProductMediaDetails {
  const ProductMediaDetails({
    required this.summary,
    required this.chapters,
    required this.episodes,
    this.readerChapters = const [],
    this.playbackEpisodes = const [],
    this.preferredProvider,
    this.chapterCompletions = const [],
    this.episodeCompletions = const [],
    this.chapterEdits = const {},
    this.episodeEdits = const {},
    this.localAssets = const [],
    this.metadataOverride,
  });

  final ProductMediaSummary summary;
  final List<CanonicalChapterAvailability> chapters;
  final List<CanonicalEpisodeAvailability> episodes;
  final List<ReaderChapterAvailability> readerChapters;
  final List<PlaybackEpisodeAvailability> playbackEpisodes;
  final ProviderId? preferredProvider;
  final List<ChapterCompletion> chapterCompletions;
  final List<EpisodeCompletion> episodeCompletions;
  final Map<CanonicalChapterId, ChapterUserEdit> chapterEdits;
  final Map<CanonicalEpisodeId, EpisodeUserEdit> episodeEdits;
  final List<LocalAsset> localAssets;
  final MetadataOverride? metadataOverride;
}

class ProductSearchResult {
  const ProductSearchResult({
    required this.title,
    required this.kind,
    required this.sources,
    this.canonicalId,
    this.persisted,
    this.coverUrl,
    this.subtitle,
  });

  final String title;
  final CanonicalMediaKind kind;
  final List<ProviderListingItem> sources;
  final CanonicalMediaId? canonicalId;
  final ProductMediaSummary? persisted;
  final Uri? coverUrl;
  final String? subtitle;
}

class ProductSearchResponse {
  const ProductSearchResponse({
    required this.results,
    required this.failures,
    this.nextCursors = const {},
  });
  final List<ProductSearchResult> results;
  final Map<ProviderId, String> failures;
  final Map<ProviderId, PaginationCursor> nextCursors;
  bool get isPartial => results.isNotEmpty && failures.isNotEmpty;
}

class ProductDiscoverResponse {
  const ProductDiscoverResponse({
    required this.manga,
    required this.anime,
    required this.failures,
    this.nextCursors = const {},
  });
  final List<ProductSearchResult> manga;
  final List<ProductSearchResult> anime;
  final Map<ProviderId, String> failures;
  final Map<ProviderId, PaginationCursor> nextCursors;
}

class ProductInstallmentSelection {
  const ProductInstallmentSelection({
    required this.mediaId,
    required this.providerId,
    this.chapter,
    this.episode,
  });
  final CanonicalMediaId mediaId;
  final ProviderId providerId;
  final CanonicalChapter? chapter;
  final CanonicalEpisode? episode;
}
