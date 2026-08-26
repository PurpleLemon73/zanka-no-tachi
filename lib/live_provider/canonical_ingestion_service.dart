import 'dart:async';
import 'dart:math';

import '../canonical/canonical_repository.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../canonical/mapping/animeworld_canonical_mapper.dart';
import '../canonical/mapping/canonical_import.dart';
import '../canonical/mapping/mangaworld_canonical_mapper.dart';
import '../canonical/persistence/canonical_database.dart';
import '../reconnaissance/animeworld/animeworld_dtos.dart';
import '../reconnaissance/mangaworld/mangaworld_dtos.dart';
import 'provider_adapter.dart';

abstract interface class CanonicalIdGenerator {
  CanonicalMediaId media();
  CanonicalChapterId chapter();
  CanonicalEpisodeId episode();
}

class RandomCanonicalIdGenerator implements CanonicalIdGenerator {
  RandomCanonicalIdGenerator() : _random = Random.secure();
  final Random _random;
  int _counter = 0;

  String _next(String prefix) {
    _counter++;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-'
        '${_random.nextInt(1 << 32).toRadixString(36)}-${_counter.toRadixString(36)}';
  }

  @override
  CanonicalMediaId media() => CanonicalMediaId(_next('media'));
  @override
  CanonicalChapterId chapter() => CanonicalChapterId(_next('chapter'));
  @override
  CanonicalEpisodeId episode() => CanonicalEpisodeId(_next('episode'));
}

class IngestionResult {
  const IngestionResult({
    required this.media,
    required this.created,
    required this.installmentCount,
  });
  final CanonicalMedia media;
  final bool created;
  final int installmentCount;
}

class CanonicalIngestionService {
  CanonicalIngestionService({
    required this.database,
    CanonicalIdGenerator? idGenerator,
  }) : idGenerator = idGenerator ?? RandomCanonicalIdGenerator(),
       _repository = CanonicalRepository(database);

  final CanonicalDatabase database;
  final CanonicalIdGenerator idGenerator;
  final CanonicalRepository _repository;
  static final Map<String, Future<void>> _ingestionTails = {};

  Future<IngestionResult> ingest(ProviderTitleResult result) =>
      switch (result) {
        MangaWorldTitleResult(:final dto) => ingestMangaWorld(dto),
        AnimeWorldTitleResult(:final dto) => ingestAnimeWorld(dto),
      };

  Future<IngestionResult> ingestMangaWorld(MangaWorldTitleDto dto) =>
      _serializedIngestion(
        'mangaworld/${dto.sourceId}',
        () => database.transaction(() => _ingestMangaWorld(dto)),
      );

  Future<IngestionResult> _ingestMangaWorld(MangaWorldTitleDto dto) async {
    const providerId = ProviderId('mangaworld');
    final knownId = await database.mediaBinding(providerId, dto.sourceId);
    final mediaId = knownId ?? idGenerator.media();
    final chapterIds = <String, CanonicalChapterId>{};
    for (final chapter in dto.chapters) {
      chapterIds[chapter.sourceId] =
          await database.chapterBinding(providerId, chapter.sourceId) ??
          idGenerator.chapter();
    }
    var bundle = const MangaWorldCanonicalMapper().mapTitle(
      dto: dto,
      mediaId: mediaId,
      chapterIdFor: (chapter) => chapterIds[chapter.sourceId]!,
    );
    final existing = await database.media(mediaId);
    if (existing != null) {
      if (existing is! CanonicalManga) {
        throw StateError('Provider binding points to a non-manga entity');
      }
      bundle = MangaCanonicalImport(
        media: _mergeManga(existing, bundle.media, providerId),
        chapters: bundle.chapters,
        mediaBinding: bundle.mediaBinding,
        chapterBindings: bundle.chapterBindings,
      );
    }
    await _repository.saveMangaImport(bundle);
    return IngestionResult(
      media: bundle.media,
      created: knownId == null,
      installmentCount: bundle.chapters.length,
    );
  }

  Future<IngestionResult> ingestAnimeWorld(AnimeWorldTitleDto dto) =>
      _serializedIngestion(
        'animeworld/${dto.sourceId}',
        () => database.transaction(() => _ingestAnimeWorld(dto)),
      );

  Future<IngestionResult> _ingestAnimeWorld(AnimeWorldTitleDto dto) async {
    const providerId = ProviderId('animeworld');
    final knownId = await database.mediaBinding(providerId, dto.sourceId);
    final mediaId = knownId ?? idGenerator.media();
    final episodeIds = <String, CanonicalEpisodeId>{};
    for (final episode in dto.episodes) {
      episodeIds[episode.sourceId] =
          await database.episodeBinding(providerId, episode.sourceId) ??
          idGenerator.episode();
    }
    var bundle = const AnimeWorldCanonicalMapper().mapTitle(
      dto: dto,
      mediaId: mediaId,
      episodeIdFor: (episode) => episodeIds[episode.sourceId]!,
    );
    final existing = await database.media(mediaId);
    if (existing != null) {
      if (existing is! CanonicalAnime) {
        throw StateError('Provider binding points to a non-anime entity');
      }
      bundle = AnimeCanonicalImport(
        media: _mergeAnime(existing, bundle.media, providerId),
        episodes: bundle.episodes,
        mediaBinding: bundle.mediaBinding,
        episodeBindings: bundle.episodeBindings,
      );
    }
    await _repository.saveAnimeImport(bundle);
    return IngestionResult(
      media: bundle.media,
      created: knownId == null,
      installmentCount: bundle.episodes.length,
    );
  }

  Future<T> _serializedIngestion<T>(
    String key,
    Future<T> Function() action,
  ) async {
    final previous = _ingestionTails[key] ?? Future<void>.value();
    final gate = Completer<void>();
    final mine = previous.catchError((Object _) {}).then((_) => gate.future);
    _ingestionTails[key] = mine;
    await previous.catchError((Object _) {});
    try {
      return await action();
    } finally {
      gate.complete();
      if (identical(_ingestionTails[key], mine)) {
        _ingestionTails.remove(key);
      }
    }
  }
}

CanonicalManga _mergeManga(
  CanonicalManga current,
  CanonicalManga incoming,
  ProviderId providerId,
) => CanonicalManga(
  id: current.id,
  title: _refreshValue(current.title, incoming.title, providerId),
  alternateTitles: _refreshList(
    current.alternateTitles,
    incoming.alternateTitles,
    providerId,
  ),
  description: _refreshNullable(
    current.description,
    incoming.description,
    providerId,
  ),
  status: _providerOwns(current.title, providerId)
      ? incoming.status
      : current.status,
  genres: _refreshList(current.genres, incoming.genres, providerId),
  coverLocator: _providerOwns(current.title, providerId)
      ? incoming.coverLocator
      : current.coverLocator,
);

CanonicalAnime _mergeAnime(
  CanonicalAnime current,
  CanonicalAnime incoming,
  ProviderId providerId,
) => CanonicalAnime(
  id: current.id,
  title: _refreshValue(current.title, incoming.title, providerId),
  alternateTitles: _refreshList(
    current.alternateTitles,
    incoming.alternateTitles,
    providerId,
  ),
  description: _refreshNullable(
    current.description,
    incoming.description,
    providerId,
  ),
  status: _providerOwns(current.title, providerId)
      ? incoming.status
      : current.status,
  genres: _refreshList(current.genres, incoming.genres, providerId),
  coverLocator: _providerOwns(current.title, providerId)
      ? incoming.coverLocator
      : current.coverLocator,
  format: _providerOwns(current.title, providerId)
      ? incoming.format
      : current.format,
  airingWindow: _providerOwns(current.title, providerId)
      ? incoming.airingWindow
      : current.airingWindow,
  narrativeSeason: current.narrativeSeason,
  knownEpisodeTotal: _providerOwns(current.title, providerId)
      ? incoming.knownEpisodeTotal
      : current.knownEpisodeTotal,
  rawEpisodeTotal: _providerOwns(current.title, providerId)
      ? incoming.rawEpisodeTotal
      : current.rawEpisodeTotal,
);

bool _providerOwns(SourcedValue<String> value, ProviderId providerId) =>
    value.provenance.providerId == providerId;

SourcedValue<String> _refreshValue(
  SourcedValue<String> current,
  SourcedValue<String> incoming,
  ProviderId providerId,
) => _providerOwns(current, providerId) ? incoming : current;

SourcedValue<String>? _refreshNullable(
  SourcedValue<String>? current,
  SourcedValue<String>? incoming,
  ProviderId providerId,
) {
  if (current == null) return incoming;
  return _providerOwns(current, providerId) ? incoming : current;
}

List<SourcedValue<String>> _refreshList(
  List<SourcedValue<String>> current,
  List<SourcedValue<String>> incoming,
  ProviderId providerId,
) => [
  ...current.where((value) => value.provenance.providerId != providerId),
  ...incoming,
];
