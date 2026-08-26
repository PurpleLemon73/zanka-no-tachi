import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/canonical_ingestion_service.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_adapter.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';

void main() {
  test(
    'same-provider refresh reuses IDs and preserves library and progress',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      final transport = _FixtureTransport({
        '/archive': _fixture('mangaworld/search_results.html'),
        '/manga/4000/the-angel-next-door': _fixture(
          'mangaworld/manga_detail_decimal_chapters.html',
        ),
      });
      final repository = LiveProviderRepository(
        registry: ProviderRegistry([_mangaConfig('https://base-a.invalid/')]),
        database: database,
        transport: transport,
        idGenerator: _SequentialIds(),
      );
      const item = ProviderListingItem(
        providerId: ProviderId('mangaworld'),
        externalId: '4000',
        title: 'The Angel Next Door',
        relativeLocator: '/manga/4000/the-angel-next-door',
        mediaKind: CanonicalMediaKind.manga,
      );

      final first = await repository.ingestDetail(item);
      final chapters = await database.chaptersFor(first.media.id);
      final now = DateTime.utc(2026, 8, 25);
      await database.saveLibraryEntry(
        CanonicalLibraryEntry(
          mediaId: first.media.id,
          isSaved: true,
          isFavorite: true,
          status: CanonicalLibraryStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: first.media.id,
          chapterId: chapters.first.id,
          pageIndex: 8,
          updatedAt: now,
        ),
      );
      transport.responses['/manga/4000/the-angel-next-door'] = transport
          .responses['/manga/4000/the-angel-next-door']!
          .replaceFirst('The Angel Next Door', 'The Angel Next Door Updated');

      final refreshed = await repository.ingestDetail(item);

      expect(refreshed.created, isFalse);
      expect(refreshed.media.id, first.media.id);
      expect(refreshed.media.title.value, 'The Angel Next Door Updated');
      expect(await database.allMedia(), hasLength(1));
      expect(await database.chaptersFor(first.media.id), hasLength(3));
      expect((await database.libraryEntry(first.media.id))?.isFavorite, isTrue);
      expect((await database.mangaProgress(first.media.id))?.pageIndex, 8);
      transport.responses['/manga/4000/the-angel-next-door'] =
          '<div class="comic-info"><h1 class="name">Temporarily sparse</h1>'
          '</div><div class="volume-element"><div class="volume-chapters">'
          '<div class="chapter"><a class="chap" href="/read/4000/c30-2">'
          '<span>Capitolo 30.2</span></a></div></div></div>';
      await repository.ingestDetail(item);
      expect(await database.chaptersFor(first.media.id), hasLength(3));
      expect((await database.mangaProgress(first.media.id))?.pageIndex, 8);
      await database.close();
    },
  );

  test(
    'changing only base URL preserves canonical identity and binding',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      final transport = _FixtureTransport({
        '/manga/4000/the-angel-next-door': _fixture(
          'mangaworld/manga_detail_decimal_chapters.html',
        ),
      });
      final registry = ProviderRegistry([
        _mangaConfig('https://base-a.invalid/'),
      ]);
      final repository = LiveProviderRepository(
        registry: registry,
        database: database,
        transport: transport,
        idGenerator: _SequentialIds(),
      );
      const item = ProviderListingItem(
        providerId: ProviderId('mangaworld'),
        externalId: '4000',
        title: 'The Angel Next Door',
        relativeLocator: '/manga/4000/the-angel-next-door',
        mediaKind: CanonicalMediaKind.manga,
      );

      final first = await repository.ingestDetail(item);
      registry.replace(_mangaConfig('https://base-b.invalid/'));
      final second = await repository.ingestDetail(item);

      expect(transport.hosts, ['base-a.invalid', 'base-b.invalid']);
      expect(second.media.id, first.media.id);
      expect(await database.allMedia(), hasLength(1));
      expect(
        await database.mediaBinding(const ProviderId('mangaworld'), '4000'),
        first.media.id,
      );
      final binding = await database.mediaSourceBinding(
        const ProviderId('mangaworld'),
        '4000',
      );
      expect(binding?.relativeLocator, '/manga/4000/the-angel-next-door');
      expect(binding?.relativeLocator, isNot(contains('base-')));
      await database.close();
    },
  );

  test('ingested canonical query data survives database reopen', () async {
    final directory = await Directory.systemTemp.createTemp('zanka-m2-reopen-');
    final file = File('${directory.path}/canonical.sqlite');
    var database = CanonicalDatabase(NativeDatabase(file));
    var repository = LiveProviderRepository(
      registry: ProviderRegistry([
        ProviderConfig(
          id: const ProviderId('animeworld'),
          displayName: 'AnimeWorld',
          baseUrl: Uri.parse('https://fixture.invalid/'),
          mediaKind: CanonicalMediaKind.anime,
        ),
      ]),
      database: database,
      transport: _FixtureTransport({
        '/play/fullmetal-alchemist.Ge2kM': _fixture(
          'animeworld/anime_detail_tv.html',
        ),
      }),
      idGenerator: _SequentialIds(),
    );
    const item = ProviderListingItem(
      providerId: ProviderId('animeworld'),
      externalId: 'Ge2kM',
      title: 'Fullmetal Alchemist (ITA)',
      relativeLocator: '/play/fullmetal-alchemist.Ge2kM',
      mediaKind: CanonicalMediaKind.anime,
    );
    final ingested = await repository.ingestDetail(item);
    await database.close();

    database = CanonicalDatabase(NativeDatabase(file));
    repository = LiveProviderRepository(
      registry: ProviderRegistry([
        ProviderConfig(
          id: const ProviderId('animeworld'),
          displayName: 'AnimeWorld',
          baseUrl: Uri.parse('https://fixture.invalid/'),
          mediaKind: CanonicalMediaKind.anime,
        ),
      ]),
      database: database,
      transport: _FixtureTransport({}),
    );
    final inspection = await repository.inspect(ingested.media.id);
    expect(inspection?.media.title.value, 'Fullmetal Alchemist (ITA)');
    expect(inspection?.episodes, hasLength(2));
    expect(inspection?.bindings.single.externalId, 'Ge2kM');
    await database.close();
    await directory.delete(recursive: true);
  });
}

ProviderConfig _mangaConfig(String baseUrl) => ProviderConfig(
  id: const ProviderId('mangaworld'),
  displayName: 'MangaWorld',
  baseUrl: Uri.parse(baseUrl),
  mediaKind: CanonicalMediaKind.manga,
);

String _fixture(String path) => File('fixtures/$path').readAsStringSync();

class _FixtureTransport implements ProviderTransport {
  _FixtureTransport(this.responses);
  final Map<String, String> responses;
  final List<String> hosts = [];

  @override
  Future<ProviderResponse> get(Uri uri) async {
    hosts.add(uri.host);
    final body = responses[uri.path];
    if (body == null) {
      return ProviderResponse(statusCode: 404, body: '', finalUri: uri);
    }
    return ProviderResponse(statusCode: 200, body: body, finalUri: uri);
  }

  @override
  void close() {}
}

class _SequentialIds implements CanonicalIdGenerator {
  var _media = 0;
  var _chapter = 0;
  var _episode = 0;
  @override
  CanonicalMediaId media() => CanonicalMediaId('generated-m-${++_media}');
  @override
  CanonicalChapterId chapter() =>
      CanonicalChapterId('generated-c-${++_chapter}');
  @override
  CanonicalEpisodeId episode() =>
      CanonicalEpisodeId('generated-e-${++_episode}');
}
