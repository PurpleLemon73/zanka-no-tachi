import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/canonical_ingestion_service.dart';
import 'package:zanka_no_tachi/reconnaissance/animeworld/animeworld_dtos.dart';
import 'package:zanka_no_tachi/reconnaissance/animeworld/animeworld_parser.dart';
import 'package:zanka_no_tachi/reconnaissance/mangaworld/mangaworld_dtos.dart';
import 'package:zanka_no_tachi/reconnaissance/source_contracts.dart';

void main() {
  test(
    'AnimeWorld refresh reuses media and episode IDs without duplicates',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      final ids = _Ids();
      final service = CanonicalIngestionService(
        database: database,
        idGenerator: ids,
      );
      final dto = AnimeWorldParser(config: _source('animeworld')).parseTitle(
        _fixture('animeworld/anime_detail_tv.html'),
        sourceUrl: Uri.parse(
          'https://fixture.invalid/play/fullmetal-alchemist.Ge2kM',
        ),
      );

      final first = await service.ingestAnimeWorld(dto);
      final firstEpisodes = await database.episodesFor(first.media.id);
      final second = await service.ingestAnimeWorld(dto);
      final secondEpisodes = await database.episodesFor(second.media.id);

      expect(first.created, isTrue);
      expect(second.created, isFalse);
      expect(second.media.id, first.media.id);
      expect(
        secondEpisodes.map((episode) => episode.id),
        firstEpisodes.map((episode) => episode.id),
      );
      expect(secondEpisodes, hasLength(2));
      expect(await database.allMedia(), hasLength(1));
      await database.close();
    },
  );

  test(
    'new provider-local items allocate app-controlled canonical IDs',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      final service = CanonicalIngestionService(
        database: database,
        idGenerator: _Ids(),
      );
      final result = await service.ingestMangaWorld(
        MangaWorldTitleDto(
          sourceId: 'provider-99',
          sourceUrl: Uri.parse('https://host.invalid/manga/99/title'),
          title: 'Title',
          chapters: const [],
        ),
      );
      expect(result.created, isTrue);
      expect(result.media.id.value, 'app-media-1');
      expect(result.media.id.value, isNot(contains('provider-99')));
      expect(result.media.id.value, isNot(contains('host.invalid')));
      await database.close();
    },
  );

  test(
    'same title from different providers is not automatically merged',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      final service = CanonicalIngestionService(
        database: database,
        idGenerator: _Ids(),
      );
      final manga = await service.ingestMangaWorld(
        MangaWorldTitleDto(
          sourceId: 'same-local',
          sourceUrl: Uri.parse('https://m.invalid/manga/1/same'),
          title: 'Identical Display Title',
          chapters: const [],
        ),
      );
      final anime = await service.ingestAnimeWorld(
        AnimeWorldTitleDto(
          sourceId: 'same-local',
          sourceUrl: Uri.parse('https://a.invalid/play/same.Token'),
          title: 'Identical Display Title',
          episodes: const [],
        ),
      );
      expect(anime.media.id, isNot(manga.media.id));
      expect(await database.allMedia(), hasLength(2));
      await database.close();
    },
  );

  test('refresh retains metadata owned by another provenance source', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    const id = CanonicalMediaId('explicit-mapping');
    await database.saveMedia(
      const CanonicalManga(
        id: id,
        title: SourcedValue(
          value: 'Curated title',
          provenance: FieldProvenance(providerId: ProviderId('curator')),
        ),
      ),
    );
    await database.saveMediaBinding(
      const MediaSourceBinding(
        canonicalId: id,
        providerId: ProviderId('mangaworld'),
        externalId: '99',
      ),
    );
    final service = CanonicalIngestionService(
      database: database,
      idGenerator: _Ids(),
    );
    final result = await service.ingestMangaWorld(
      MangaWorldTitleDto(
        sourceId: '99',
        sourceUrl: Uri.parse('https://m.invalid/manga/99/provider-title'),
        title: 'Provider title',
        chapters: const [],
      ),
    );
    expect(result.media.title.value, 'Curated title');
    expect(
      result.media.title.provenance.providerId,
      const ProviderId('curator'),
    );
    await database.close();
  });

  test('concurrent first ingestion creates one canonical entity', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    final firstService = CanonicalIngestionService(
      database: database,
      idGenerator: _Ids(),
    );
    final secondService = CanonicalIngestionService(
      database: database,
      idGenerator: _Ids(),
    );
    final dto = MangaWorldTitleDto(
      sourceId: 'concurrent-99',
      sourceUrl: Uri.parse('https://m.invalid/manga/99/title'),
      title: 'Concurrent Title',
      chapters: const [],
    );

    final results = await Future.wait([
      firstService.ingestMangaWorld(dto),
      secondService.ingestMangaWorld(dto),
    ]);

    expect(results.map((result) => result.media.id).toSet(), hasLength(1));
    expect(results.where((result) => result.created), hasLength(1));
    expect(await database.allMedia(), hasLength(1));
    expect(
      await database.mediaBinding(
        const ProviderId('mangaworld'),
        'concurrent-99',
      ),
      results.first.media.id,
    );
    await database.close();
  });
}

SourceConfig _source(String id) => SourceConfig(
  providerId: id,
  baseUrl: Uri.parse('https://fixture.invalid/'),
);

String _fixture(String path) => File('fixtures/$path').readAsStringSync();

class _Ids implements CanonicalIdGenerator {
  var m = 0;
  var c = 0;
  var e = 0;
  @override
  CanonicalMediaId media() => CanonicalMediaId('app-media-${++m}');
  @override
  CanonicalChapterId chapter() => CanonicalChapterId('app-chapter-${++c}');
  @override
  CanonicalEpisodeId episode() => CanonicalEpisodeId('app-episode-${++e}');
}
