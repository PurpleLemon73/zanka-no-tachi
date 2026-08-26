import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../canonical/domain/user_state.dart';
import '../adapter_platform/adapter_sdk.dart';
import '../adapter_platform/adapter_descriptor.dart';
import '../adapter_platform/metadata_enrichment_service.dart';
import '../adapter_platform/adapter_errors.dart';
import '../live_provider/live_provider_repository.dart';
import '../live_provider/provider_adapter.dart';
import '../live_provider/provider_errors.dart';
import 'product_models.dart';
import '../reader/reader_repository.dart';
import '../player/playback_repository.dart';
import '../local_library/local_asset.dart';
import 'smart_resume.dart';

class ProductRepository {
  const ProductRepository(this.live, {this.reader, this.playback});
  final LiveProviderRepository live;
  final ReaderRepository? reader;
  final PlaybackRepository? playback;

  Future<void> enrichWithDeterministicProof(CanonicalMediaId id) async {
    const adapter = DeterministicEnrichmentAdapter();
    await MetadataEnrichmentService(live.database, const [
      adapter,
    ]).enrichReviewed(id, adapter.descriptor.id);
  }

  Future<List<ProductMediaSummary>> persisted() async {
    final media = <CanonicalMedia>[];
    for (final item in await live.persistedMedia()) {
      media.add(await live.database.effectiveMedia(item.id) ?? item);
    }
    final library = {
      for (final entry in await live.database.allLibraryEntries())
        entry.mediaId: entry,
    };
    final mangaProgress = {
      for (final progress in await live.database.allMangaProgress())
        progress.mediaId: progress,
    };
    final animeProgress = {
      for (final progress in await live.database.allAnimeProgress())
        progress.mediaId: progress,
    };
    final bindings = await live.database.allMediaBindingsByMedia();
    final chapterLabels = await live.database.allChapterLabels();
    final episodeLabels = await live.database.allEpisodeLabels();
    final completedChapters = await live.database.allCompletedChapterIds();
    final completedEpisodes = await live.database.allCompletedEpisodeIds();
    final missingLocalMedia = (await live.database.allLocalAssets())
        .where((asset) => asset.state != LocalAssetState.available)
        .map((asset) => asset.mediaId)
        .toSet();
    final summaries = <ProductMediaSummary>[];
    for (final item in media) {
      final manga = mangaProgress[item.id];
      final anime = animeProgress[item.id];
      summaries.add(
        ProductMediaSummary(
          media: item,
          bindings: bindings[item.id] ?? const [],
          library: library[item.id],
          mangaProgress: manga,
          animeProgress: anime,
          progressLabel: manga == null
              ? anime == null
                    ? null
                    : episodeLabels[anime.episodeId]
              : chapterLabels[manga.chapterId],
          progressCompleted:
              (manga != null && completedChapters.contains(manga.chapterId)) ||
              (anime != null && completedEpisodes.contains(anime.episodeId)),
          hasMissingLocalSource: missingLocalMedia.contains(item.id),
        ),
      );
    }
    return summaries;
  }

  Future<ProductMediaDetails?> details(CanonicalMediaId requestedId) async {
    final id = await live.database.resolveCanonicalId(requestedId);
    final media = await live.database.effectiveMedia(id);
    if (media == null) return null;
    final chapters = await live.availability.chapters(id);
    final episodes = await live.availability.episodes(id);
    final readerChapters = await reader?.chapters(id) ?? const [];
    final playbackEpisodes = await playback?.episodes(id) ?? const [];
    final preferred = await live.database.preferredProvider(id);
    final chapterCompletions = await live.database.chapterCompletionsFor(id);
    final episodeCompletions = await live.database.episodeCompletionsFor(id);
    final mangaProgress = await live.database.mangaProgress(id);
    final animeProgress = await live.database.animeProgress(id);
    final smartResume = media is CanonicalManga
        ? await SmartResumePolicy.manga(
            chapters: readerChapters,
            completed: chapterCompletions.map((item) => item.chapterId).toSet(),
            progress: mangaProgress,
            preferredProvider: preferred,
            resumeFor: (binding) => live.database.mangaSourcePageResume(
              binding.providerId,
              binding.externalId,
            ),
          )
        : await SmartResumePolicy.anime(
            episodes: playbackEpisodes,
            completed: episodeCompletions.map((item) => item.episodeId).toSet(),
            progress: animeProgress,
            preferredProvider: preferred,
            resumeFor: (binding) => live.database.animeSourcePlaybackResume(
              binding.providerId,
              binding.externalId,
            ),
          );
    return ProductMediaDetails(
      summary: ProductMediaSummary(
        media: media,
        bindings: await live.database.mediaBindingsFor(id),
        library: await live.database.libraryEntry(id),
        mangaProgress: mangaProgress,
        animeProgress: animeProgress,
        progressLabel: await _progressLabel(id),
        smartResume: smartResume,
      ),
      chapters: chapters,
      episodes: episodes,
      readerChapters: readerChapters,
      playbackEpisodes: playbackEpisodes,
      preferredProvider: preferred,
      chapterCompletions: chapterCompletions,
      episodeCompletions: episodeCompletions,
      chapterEdits: await live.database.chapterUserEditsFor(id),
      episodeEdits: await live.database.episodeUserEditsFor(id),
      localAssets: (await live.database.allLocalAssets())
          .where((asset) => asset.mediaId == id)
          .toList(),
      metadataOverride: await live.database.metadataOverride(id),
      smartResume: smartResume,
    );
  }

  Future<SmartResumeTarget?> smartResume(CanonicalMediaId id) async =>
      (await details(id))?.smartResume;

  Future<String?> _progressLabel(CanonicalMediaId id) async {
    final manga = await live.database.mangaProgress(id);
    if (manga != null) {
      return (await live.database.chapter(manga.chapterId))?.number.rawLabel;
    }
    final anime = await live.database.animeProgress(id);
    return anime == null
        ? null
        : (await live.database.episode(anime.episodeId))?.label.rawLabel;
  }

  Future<ProductDiscoverResponse> discover({
    Map<ProviderId, PaginationCursor> cursors = const {},
  }) async {
    final failures = <ProviderId, String>{};
    final manga = <ProductSearchResult>[];
    final anime = <ProductSearchResult>[];
    final next = <ProviderId, PaginationCursor>{};
    await Future.wait([
      for (final descriptor in live.adapters.descriptors.where(
        (item) => item.supports(AdapterCapability.catalog),
      ))
        if (_enabled(descriptor.id.providerId) &&
            (cursors.isEmpty || cursors.containsKey(descriptor.id.providerId)))
          () async {
            final providerId = descriptor.id.providerId;
            try {
              final page = await live.catalogPage(
                providerId,
                PageRequest(cursor: cursors[providerId]),
              );
              final mapped = await _mapListings(page.items);
              for (final item in mapped) {
                (item.kind == CanonicalMediaKind.manga ? manga : anime).add(
                  item,
                );
              }
              if (page.nextCursor case final cursor?) {
                next[providerId] = cursor;
              }
            } on Object catch (error) {
              failures[providerId] = _friendlyError(error);
            }
          }(),
    ]);
    return ProductDiscoverResponse(
      manga: _deduplicate(manga),
      anime: _deduplicate(anime),
      failures: failures,
      nextCursors: next,
    );
  }

  Future<ProductSearchResponse> search(
    String query, {
    Set<CanonicalMediaKind> kinds = const {
      CanonicalMediaKind.manga,
      CanonicalMediaKind.anime,
    },
    Map<ProviderId, PaginationCursor> cursors = const {},
  }) async {
    final failures = <ProviderId, String>{};
    final results = <ProductSearchResult>[];
    final next = <ProviderId, PaginationCursor>{};
    await Future.wait([
      for (final descriptor in live.adapters.descriptors.where(
        (item) =>
            item.supports(AdapterCapability.search) &&
            kinds.any(item.supportsKind),
      ))
        if (_enabled(descriptor.id.providerId) &&
            (cursors.isEmpty || cursors.containsKey(descriptor.id.providerId)))
          () async {
            final providerId = descriptor.id.providerId;
            try {
              final page = await live.searchPage(
                providerId,
                query,
                PageRequest(cursor: cursors[providerId]),
              );
              results.addAll(
                (await _mapListings(
                  page.items,
                )).where((item) => kinds.contains(item.kind)),
              );
              if (page.nextCursor case final cursor?) {
                next[providerId] = cursor;
              }
            } on Object catch (error) {
              failures[providerId] = _friendlyError(error);
            }
          }(),
    ]);
    return ProductSearchResponse(
      results: _deduplicate(results),
      failures: failures,
      nextCursors: next,
    );
  }

  Future<ProductMediaDetails> openSearchResult(
    ProductSearchResult result,
  ) async {
    if (result.canonicalId case final id?) {
      return (await details(id))!;
    }
    if (result.sources.isEmpty) {
      throw StateError('Search result has no available source');
    }
    final ingested = await live.ingestDetail(result.sources.first);
    return (await details(ingested.media.id))!;
  }

  Future<ProductMediaDetails> refreshDetails(
    CanonicalMediaId requestedId,
  ) async {
    final mediaId = await live.database.resolveCanonicalId(requestedId);
    final media = await live.database.media(mediaId);
    if (media == null) throw StateError('Media is no longer available');
    final bindings = await live.database.mediaBindingsFor(mediaId);
    var refreshed = false;
    Object? lastError;
    for (final binding in bindings) {
      final locator = binding.relativeLocator;
      if (locator == null || !_enabled(binding.providerId)) continue;
      try {
        await live.ingestDetail(
          ProviderListingItem(
            providerId: binding.providerId,
            externalId: binding.externalId,
            title: media.title.value,
            relativeLocator: locator,
            mediaKind: media.kind,
          ),
        );
        refreshed = true;
      } on Object catch (error) {
        lastError = error;
      }
    }
    if (!refreshed && lastError != null) throw lastError;
    return (await details(mediaId))!;
  }

  Future<void> setLibrary({
    required CanonicalMediaId mediaId,
    required bool saved,
    bool? favorite,
    CanonicalLibraryStatus? status,
  }) async {
    final current = await live.database.libraryEntry(mediaId);
    final now = DateTime.now().toUtc();
    await live.database.saveLibraryEntry(
      CanonicalLibraryEntry(
        mediaId: mediaId,
        isSaved: saved,
        isFavorite: favorite ?? current?.isFavorite ?? false,
        status: status ?? current?.status ?? CanonicalLibraryStatus.planned,
        createdAt: current?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  Future<void> setPreferredProvider(
    CanonicalMediaId mediaId,
    ProviderId? providerId,
  ) async {
    if (providerId != null) {
      final available = await live.database.mediaBindingsFor(mediaId);
      if (!available.any((binding) => binding.providerId == providerId)) {
        throw StateError('Preferred provider is not available for this media');
      }
    }
    await live.database.setPreferredProvider(mediaId, providerId);
  }

  Future<void> saveMetadataOverride(MetadataOverride value) =>
      live.database.saveMetadataOverride(value);

  Future<List<ProductSearchResult>> _mapListings(
    List<ProviderListingItem> listings,
  ) async {
    final persistedById = {
      for (final item in await persisted()) item.media.id: item,
    };
    final results = <ProductSearchResult>[];
    for (final listing in listings) {
      final canonicalId = await live.database.mediaBinding(
        listing.providerId,
        listing.externalId,
      );
      final summary = canonicalId == null ? null : persistedById[canonicalId];
      results.add(
        ProductSearchResult(
          title: summary?.media.title.value ?? listing.title,
          kind: summary?.media.kind ?? listing.mediaKind,
          sources: [listing],
          canonicalId: canonicalId,
          persisted: summary,
          coverUrl: summary?.media.coverLocator == null
              ? listing.coverUrl
              : Uri.tryParse(summary!.media.coverLocator!),
          subtitle: listing.subtitle,
        ),
      );
    }
    return results;
  }

  List<ProductSearchResult> _deduplicate(List<ProductSearchResult> values) {
    final result = <ProductSearchResult>[];
    final canonicalIndexes = <CanonicalMediaId, int>{};
    final unseen = <String>{};
    for (final value in values) {
      if (value.canonicalId case final id?) {
        final index = canonicalIndexes[id];
        if (index == null) {
          canonicalIndexes[id] = result.length;
          result.add(value);
        } else {
          final current = result[index];
          result[index] = ProductSearchResult(
            title: current.title,
            kind: current.kind,
            sources: [...current.sources, ...value.sources],
            canonicalId: id,
            persisted: current.persisted,
            coverUrl: current.coverUrl ?? value.coverUrl,
            subtitle: current.subtitle ?? value.subtitle,
          );
        }
      } else {
        final key =
            '${value.sources.first.providerId.value}/${value.sources.first.externalId}';
        if (unseen.add(key)) result.add(value);
      }
    }
    result.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
    return result;
  }

  List<ProductSearchResult> deduplicateResults(
    List<ProductSearchResult> values,
  ) => _deduplicate(values);

  bool _enabled(ProviderId id) =>
      live.providers.where((value) => value.id == id).firstOrNull?.enabled ??
      true;

  String _friendlyError(Object error) => switch (error) {
    AdapterParseError() => 'This source changed and needs an update.',
    AdapterNetworkError() => 'This source is currently unreachable.',
    AdapterHttpError() => 'This source returned an unexpected response.',
    AdapterRateLimitError() => 'This source asked Zanka to slow down.',
    AdapterUnavailable() => 'This source is unavailable or disabled.',
    AdapterConfigurationError() => 'This source configuration is invalid.',
    ProviderParserException() => 'This source changed and needs an update.',
    ProviderNetworkException() => 'This source is currently unreachable.',
    ProviderHttpException() => 'This source returned an unexpected response.',
    ProviderDisabledException() => 'This source is disabled.',
    _ => 'This source could not be loaded.',
  };
}
