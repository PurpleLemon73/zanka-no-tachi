import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/matching.dart';
import '../canonical/domain/media.dart';
import '../canonical/persistence/canonical_database.dart';
import '../canonical/reconciliation/canonical_reconciliation_service.dart';
import '../canonical/reconciliation/source_availability.dart';
import '../adapter_platform/adapter_descriptor.dart';
import '../adapter_platform/adapter_registry.dart';
import '../adapter_platform/adapter_sdk.dart';
import '../adapter_platform/adapter_state.dart';
import '../adapter_platform/live_adapter_bridge.dart';
import 'canonical_ingestion_service.dart';
import 'provider_adapter.dart';
import 'provider_errors.dart';
import 'provider_registry.dart';
import 'provider_transport.dart';

class CanonicalMediaInspection {
  const CanonicalMediaInspection({
    required this.media,
    required this.bindings,
    required this.chapters,
    required this.episodes,
    required this.chapterAvailability,
    required this.episodeAvailability,
    this.requestedId,
  });
  final CanonicalMedia media;
  final List<MediaSourceBinding> bindings;
  final List<CanonicalChapter> chapters;
  final List<CanonicalEpisode> episodes;
  final List<CanonicalChapterAvailability> chapterAvailability;
  final List<CanonicalEpisodeAvailability> episodeAvailability;
  final CanonicalMediaId? requestedId;

  bool get followedAlias => requestedId != null && requestedId != media.id;
}

class LiveProviderRepository {
  LiveProviderRepository({
    required this.registry,
    required this.database,
    required this.transport,
    CanonicalIdGenerator? idGenerator,
    this.additionalAdapters = const [],
  }) : ingestion = CanonicalIngestionService(
         database: database,
         idGenerator: idGenerator,
       ),
       reconciliation = CanonicalReconciliationService(database),
       availability = SourceAvailabilityRepository(database),
       sourceSelector = PreferredSourceSelector(database);

  final ProviderRegistry registry;
  final CanonicalDatabase database;
  final ProviderTransport transport;
  final CanonicalIngestionService ingestion;
  final CanonicalReconciliationService reconciliation;
  final SourceAvailabilityRepository availability;
  final PreferredSourceSelector sourceSelector;
  final List<AdapterRegistration> additionalAdapters;
  AdapterRegistry get adapters => _buildAdapters();

  List<ProviderConfig> get providers => registry.all;

  void updateProvider(ProviderConfig config) => registry.replace(config);

  Future<void> persistProvider(ProviderConfig config) async {
    _validateBaseUrl(config.baseUrl, config.id);
    registry.replace(config);
    final order = registry.all.indexWhere((value) => value.id == config.id);
    await database.saveAdapterConfiguration(
      PersistedAdapterConfiguration(
        adapterId: AdapterId(config.id.value),
        enabled: config.enabled,
        baseUrl: config.baseUrl,
        order: order,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> loadPersistedProviderConfiguration() async {
    for (final value in await database.allAdapterConfigurations()) {
      final id = value.adapterId.providerId;
      if (!registry.all.any((provider) => provider.id == id)) continue;
      final current = registry.require(id);
      final baseUrl = value.baseUrl ?? current.baseUrl;
      _validateBaseUrl(baseUrl, id);
      registry.replace(
        current.copyWith(baseUrl: baseUrl, enabled: value.enabled),
      );
    }
  }

  void _validateBaseUrl(Uri value, ProviderId id) {
    if (!value.hasAuthority ||
        (value.scheme != 'https' && value.scheme != 'http')) {
      throw ProviderConfigurationException(
        id,
        'Base URL must be an absolute HTTP(S) URL',
      );
    }
  }

  LiveProviderAdapter adapter(ProviderId id) {
    final config = registry.require(id);
    return switch (config.mediaKind) {
      CanonicalMediaKind.manga => MangaWorldLiveAdapter(
        config: config,
        transport: transport,
      ),
      CanonicalMediaKind.anime => AnimeWorldLiveAdapter(
        config: config,
        transport: transport,
      ),
    };
  }

  AdapterRegistry _buildAdapters() {
    final descriptors = AdapterRegistry.coreDescriptors();
    final registrations = <AdapterRegistration>[];
    for (final descriptor in descriptors) {
      if (registry.all.any((value) => value.id == descriptor.id.providerId)) {
        final bridge = LiveAdapterSdkBridge(
          descriptor: descriptor,
          adapter: adapter(descriptor.id.providerId),
        );
        registrations.add(
          AdapterRegistration(
            descriptor: descriptor,
            catalog: bridge,
            search: bridge,
            details: bridge,
          ),
        );
      } else {
        registrations.add(AdapterRegistration(descriptor: descriptor));
      }
    }
    registrations.addAll(additionalAdapters);
    return AdapterRegistry(registrations);
  }

  Future<Map<ProviderId, ProviderHealth>> providerStatuses() async {
    final statuses = <ProviderId, ProviderHealth>{};
    for (final provider in registry.all) {
      statuses[provider.id] = await adapter(provider.id).checkHealth();
    }
    return statuses;
  }

  Future<ProviderHealth> check(ProviderId providerId) async {
    final health = await adapter(providerId).checkHealth();
    final success = health.state == ProviderHealthState.available;
    await database.recordAdapterCheck(
      AdapterId(providerId.value),
      success: success,
      parserMismatch: health.state == ProviderHealthState.parserMismatch,
      error: health.diagnostic,
    );
    return health;
  }

  Future<ProviderListingPage> catalog(ProviderId providerId) =>
      adapter(providerId).catalog();
  Future<ProviderListingPage> search(ProviderId providerId, String query) =>
      adapter(providerId).search(query);

  Future<PageResult<ProviderListingItem>> catalogPage(
    ProviderId providerId,
    PageRequest request,
  ) => adapters
      .requireCapability<CatalogAdapter>(
        AdapterId(providerId.value),
        AdapterCapability.catalog,
      )
      .catalog(request);

  Future<PageResult<ProviderListingItem>> searchPage(
    ProviderId providerId,
    String query,
    PageRequest request,
  ) => adapters
      .requireCapability<SearchAdapter>(
        AdapterId(providerId.value),
        AdapterCapability.search,
      )
      .search(query, request);

  Future<IngestionResult> ingestDetail(ProviderListingItem item) async {
    final detail = await adapter(item.providerId).detail(item);
    return ingestion.ingest(detail);
  }

  Future<List<CanonicalMedia>> persistedMedia() => database.allMedia();

  Future<CanonicalMediaInspection?> inspect(CanonicalMediaId id) async {
    final resolvedId = await database.resolveCanonicalId(id);
    final media = await database.media(resolvedId);
    if (media == null) return null;
    return CanonicalMediaInspection(
      media: media,
      bindings: await database.mediaBindingsFor(resolvedId),
      chapters: await database.chaptersFor(resolvedId),
      episodes: await database.episodesFor(resolvedId),
      chapterAvailability: await availability.chapters(resolvedId),
      episodeAvailability: await availability.episodes(resolvedId),
      requestedId: id,
    );
  }

  Future<List<MatchCandidate>> candidatesFor(CanonicalMediaId id) =>
      reconciliation.candidatesFor(id);

  Future<MergeResult> mergeCanonicalMedia({
    required CanonicalMediaId sourceId,
    required CanonicalMediaId targetId,
  }) => reconciliation.mergeCanonicalMedia(
    sourceId: sourceId,
    targetId: targetId,
    reason: MergeReason.reviewedUserDecision,
  );

  Future<void> undoMerge(String auditId) => reconciliation.undoMerge(auditId);

  Future<void> seedSyntheticReconciliationScenarios() async {
    await database.transaction(() async {
      await _seedSyntheticManga('m3-berserk-a', 'synthetic-manga-a', [
        140,
        141,
        143,
      ]);
      await _seedSyntheticManga('m3-berserk-b', 'synthetic-manga-b', [
        141,
        142,
        143,
      ]);
      await _seedSyntheticAnime('m3-anime-a', 'synthetic-anime-a', [1, 2, 3]);
      await _seedSyntheticAnime('m3-anime-b', 'synthetic-anime-b', [2, 3, 4]);
    });
  }

  Future<void> _seedSyntheticManga(
    String mediaValue,
    String providerValue,
    List<int> chapterNumbers,
  ) async {
    final mediaId = CanonicalMediaId(mediaValue);
    final providerId = ProviderId(providerValue);
    if (await database.media(mediaId) != null) return;
    await database.saveMedia(
      CanonicalManga(
        id: mediaId,
        title: SourcedValue(
          value: 'Berserk (M3 synthetic)',
          provenance: FieldProvenance(providerId: providerId),
        ),
      ),
    );
    await database.saveMediaBinding(
      MediaSourceBinding(
        canonicalId: mediaId,
        providerId: providerId,
        externalId: '$providerValue-berserk',
      ),
    );
    for (final number in chapterNumbers) {
      final chapterId = CanonicalChapterId('$mediaValue-chapter-$number');
      await database.saveChapter(
        CanonicalChapter(
          id: chapterId,
          mediaId: mediaId,
          number: ChapterNumber.parse('$number'),
        ),
      );
      await database.saveChapterBinding(
        ChapterSourceBinding(
          canonicalId: chapterId,
          providerId: providerId,
          externalId: '$providerValue-chapter-$number',
        ),
      );
    }
  }

  Future<void> _seedSyntheticAnime(
    String mediaValue,
    String providerValue,
    List<int> episodeNumbers,
  ) async {
    final mediaId = CanonicalMediaId(mediaValue);
    final providerId = ProviderId(providerValue);
    if (await database.media(mediaId) != null) return;
    await database.saveMedia(
      CanonicalAnime(
        id: mediaId,
        title: SourcedValue(
          value: 'Example Anime (M3 synthetic)',
          provenance: FieldProvenance(providerId: providerId),
        ),
        format: AnimeFormat.tv,
      ),
    );
    await database.saveMediaBinding(
      MediaSourceBinding(
        canonicalId: mediaId,
        providerId: providerId,
        externalId: '$providerValue-anime',
      ),
    );
    for (final number in episodeNumbers) {
      final episodeId = CanonicalEpisodeId('$mediaValue-episode-$number');
      await database.saveEpisode(
        CanonicalEpisode(
          id: episodeId,
          mediaId: mediaId,
          label: EpisodeLabel(
            rawLabel: 'Episode $number',
            number: number.toDouble(),
          ),
          narrativeSeason: 1,
        ),
      );
      await database.saveEpisodeBinding(
        EpisodeSourceBinding(
          canonicalId: episodeId,
          providerId: providerId,
          externalId: '$providerValue-episode-$number',
        ),
      );
    }
  }

  Future<void> dispose() async {
    transport.close();
    await database.close();
  }
}
