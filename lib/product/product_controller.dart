import 'dart:async';

import 'package:flutter/foundation.dart';

import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../canonical/domain/user_state.dart';
import '../live_provider/provider_registry.dart';
import 'product_models.dart';
import 'product_repository.dart';
import '../reader/sample_manga_installer.dart';
import '../player/sample_anime_installer.dart';
import '../local_library/local_library_service.dart';
import '../local_library/backup_service.dart';
import '../adapter_platform/adapter_sdk.dart';
import 'search_history_store.dart';
import '../product_maturity/maturity_domain.dart';

class ProductController extends ChangeNotifier {
  ProductController(
    this.repository, {
    this.sampleInstaller,
    this.sampleAnimeInstaller,
    this.localLibrary,
    this.backup,
    SearchHistoryStore? searchHistoryStore,
  }) : searchHistoryStore = searchHistoryStore ?? SearchHistoryStore.memory();
  final ProductRepository repository;
  final SampleMangaInstaller? sampleInstaller;
  final SampleAnimeInstaller? sampleAnimeInstaller;
  final LocalLibraryService? localLibrary;
  final ZankaBackupService? backup;
  final SearchHistoryStore searchHistoryStore;
  List<String> recentSearches = const [];

  List<ProductMediaSummary> persisted = const [];
  List<ProductSearchResult> discoverManga = const [];
  List<ProductSearchResult> discoverAnime = const [];
  List<ProductSearchResult> searchResults = const [];
  Map<ProviderId, String> discoverFailures = const {};
  Map<ProviderId, String> searchFailures = const {};
  Map<ProviderId, PaginationCursor> discoverCursors = const {};
  Map<ProviderId, PaginationCursor> searchCursors = const {};
  Set<CanonicalMediaKind> searchKinds = {
    CanonicalMediaKind.manga,
    CanonicalMediaKind.anime,
  };
  bool loadingLocal = true;
  bool loadingDiscover = true;
  bool searching = false;
  bool loadingMoreDiscover = false;
  bool loadingMoreSearch = false;
  String searchQuery = '';
  int selectedTab = 0;
  Timer? _debounce;
  int _searchGeneration = 0;

  List<ProviderConfig> get providers => repository.live.providers;

  List<ProductMediaSummary> get library =>
      persisted.where((item) => item.library?.isSaved ?? false).toList();
  List<ProductMediaSummary> get continueItems =>
      persisted
          .where((item) => item.hasProgress && !item.progressCompleted)
          .toList()
        ..sort((a, b) {
          final left = a.mangaProgress?.updatedAt ?? a.animeProgress?.updatedAt;
          final right =
              b.mangaProgress?.updatedAt ?? b.animeProgress?.updatedAt;
          return (right ?? DateTime(0)).compareTo(left ?? DateTime(0));
        });

  Future<void> initialize() async {
    recentSearches = await searchHistoryStore.load();
    if (localLibrary != null &&
        (await repository.live.database.allLocalAssets()).isNotEmpty) {
      await localLibrary!.refreshStates();
    }
    await repository.live.loadPersistedProviderConfiguration();
    await refreshLocal();
    await refreshDiscover();
  }

  Future<void> refreshLocal() async {
    loadingLocal = true;
    notifyListeners();
    persisted = await repository.persisted();
    loadingLocal = false;
    notifyListeners();
  }

  Future<void> refreshDiscover() async {
    loadingDiscover = true;
    notifyListeners();
    final response = await repository.discover();
    discoverManga = response.manga;
    discoverAnime = response.anime;
    discoverFailures = response.failures;
    discoverCursors = response.nextCursors;
    loadingDiscover = false;
    notifyListeners();
  }

  void selectTab(int index) {
    selectedTab = index;
    if (index == 2) unawaited(refreshLocal());
    notifyListeners();
  }

  void setProviderEnabled(ProviderId id, bool enabled) {
    final current = repository.live.registry.require(id);
    unawaited(
      repository.live.persistProvider(current.copyWith(enabled: enabled)),
    );
    notifyListeners();
    unawaited(refreshDiscover());
  }

  void setSearchKind(CanonicalMediaKind kind, bool enabled) {
    final next = {...searchKinds};
    enabled ? next.add(kind) : next.remove(kind);
    if (next.isEmpty) next.add(kind);
    searchKinds = next;
    scheduleSearch(searchQuery, immediate: true);
  }

  void scheduleSearch(String value, {bool immediate = false}) {
    searchQuery = value.trim();
    _debounce?.cancel();
    if (searchQuery.isEmpty) {
      _searchGeneration++;
      searchResults = const [];
      searchFailures = const {};
      searchCursors = const {};
      searching = false;
      notifyListeners();
      return;
    }
    if (immediate) {
      unawaited(_performSearch());
    } else {
      _debounce = Timer(const Duration(milliseconds: 350), _performSearch);
    }
    notifyListeners();
  }

  Future<void> submitSearch(String value) async {
    searchQuery = value.trim();
    if (searchQuery.isNotEmpty) {
      unawaited(
        searchHistoryStore.add(searchQuery).then((values) {
          recentSearches = values;
          notifyListeners();
        }),
      );
    }
    _debounce?.cancel();
    await _performSearch();
  }

  Future<void> clearRecentSearches() async {
    await searchHistoryStore.clear();
    recentSearches = const [];
    notifyListeners();
  }

  Future<void> _performSearch() async {
    if (searchQuery.isEmpty) return;
    final generation = ++_searchGeneration;
    final query = searchQuery;
    final kinds = {...searchKinds};
    searching = true;
    notifyListeners();
    final response = await repository.search(query, kinds: kinds);
    if (generation != _searchGeneration || query != searchQuery) {
      loadingMoreSearch = false;
      notifyListeners();
      return;
    }
    searchResults = response.results;
    searchFailures = response.failures;
    searchCursors = response.nextCursors;
    searching = false;
    notifyListeners();
  }

  Future<void> loadMoreSearch() async {
    if (loadingMoreSearch || searchCursors.isEmpty || searchQuery.isEmpty) {
      return;
    }
    final generation = ++_searchGeneration;
    final query = searchQuery;
    loadingMoreSearch = true;
    notifyListeners();
    final response = await repository.search(
      query,
      kinds: {...searchKinds},
      cursors: {...searchCursors},
    );
    if (generation != _searchGeneration || query != searchQuery) {
      loadingMoreSearch = false;
      notifyListeners();
      return;
    }
    searchResults = repository.deduplicateResults([
      ...searchResults,
      ...response.results,
    ]);
    searchFailures = {...searchFailures, ...response.failures};
    searchCursors = response.nextCursors;
    loadingMoreSearch = false;
    notifyListeners();
  }

  Future<void> loadMoreDiscover() async {
    if (loadingMoreDiscover || discoverCursors.isEmpty) return;
    loadingMoreDiscover = true;
    notifyListeners();
    final response = await repository.discover(cursors: {...discoverCursors});
    discoverManga = repository.deduplicateResults([
      ...discoverManga,
      ...response.manga,
    ]);
    discoverAnime = repository.deduplicateResults([
      ...discoverAnime,
      ...response.anime,
    ]);
    discoverFailures = {...discoverFailures, ...response.failures};
    discoverCursors = response.nextCursors;
    loadingMoreDiscover = false;
    notifyListeners();
  }

  Future<ProductMediaDetails> openResult(ProductSearchResult result) async {
    final details = await repository.openSearchResult(result);
    await refreshLocal();
    return details;
  }

  Future<ProductMediaDetails?> details(CanonicalMediaId id) =>
      repository.details(id);

  Future<ProductMediaDetails> refreshDetails(CanonicalMediaId id) async {
    final value = await repository.refreshDetails(id);
    await refreshLocal();
    return value;
  }

  Future<ProductMediaDetails> updateLibrary(
    ProductMediaDetails details, {
    bool? saved,
    bool? favorite,
    CanonicalLibraryStatus? status,
  }) async {
    final current = details.summary.library;
    await repository.setLibrary(
      mediaId: details.summary.media.id,
      saved: saved ?? current?.isSaved ?? false,
      favorite: favorite,
      status: status,
    );
    await refreshLocal();
    return (await repository.details(details.summary.media.id))!;
  }

  Future<ProductMediaDetails> setPreferredProvider(
    ProductMediaDetails details,
    ProviderId? providerId,
  ) async {
    await repository.setPreferredProvider(details.summary.media.id, providerId);
    return (await repository.details(details.summary.media.id))!;
  }

  Future<ProductMediaDetails> saveMetadataOverride(
    ProductMediaDetails details, {
    required String displayTitle,
    required List<String> alternateTitles,
    required String? coverLocator,
    required List<String> genres,
    String? description,
    CanonicalMediaStatus? status,
    AnimeFormat? animeFormat,
    String? creatorOrStudio,
  }) async {
    await repository.saveMetadataOverride(
      MetadataOverride(
        mediaId: details.summary.media.id,
        displayTitle: displayTitle.trim(),
        alternateTitles: alternateTitles,
        coverLocator: coverLocator,
        genres: genres,
        description: description,
        status: status,
        animeFormat: animeFormat,
        creatorOrStudio: creatorOrStudio,
      ),
    );
    await refreshLocal();
    return (await repository.details(details.summary.media.id))!;
  }

  Future<ProductMediaDetails> clearMetadataOverrides(
    ProductMediaDetails details,
  ) async {
    await repository.live.database.clearMetadataOverride(
      details.summary.media.id,
    );
    await refreshLocal();
    return (await repository.details(details.summary.media.id))!;
  }

  Future<ProductMediaDetails> clearMetadataOverrideField(
    ProductMediaDetails details,
    MetadataOverrideField field,
  ) async {
    await repository.live.database.clearMetadataOverrideField(
      details.summary.media.id,
      field,
    );
    await refreshLocal();
    return (await repository.details(details.summary.media.id))!;
  }

  Future<ProductMediaDetails> enrichReviewed(
    ProductMediaDetails details,
  ) async {
    await repository.enrichWithDeterministicProof(details.summary.media.id);
    await refreshLocal();
    return (await repository.details(details.summary.media.id))!;
  }

  Future<void> editChapter(ChapterUserEdit edit) async {
    await repository.live.database.saveChapterUserEdit(edit);
    notifyListeners();
  }

  Future<void> editEpisode(EpisodeUserEdit edit) async {
    await repository.live.database.saveEpisodeUserEdit(edit);
    notifyListeners();
  }

  Future<CanonicalMediaId?> installSampleManga() async {
    final installer = sampleInstaller;
    if (installer == null) return null;
    final id = await installer.install();
    await refreshLocal();
    return id;
  }

  Future<CanonicalMediaId?> installSampleAnime() async {
    final installer = sampleAnimeInstaller;
    if (installer == null) return null;
    final id = await installer.install();
    await refreshLocal();
    return id;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
