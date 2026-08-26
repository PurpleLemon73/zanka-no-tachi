import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/live_media/animeworld_playback_source.dart';
import 'package:zanka_no_tachi/live_media/live_media_transport.dart';
import 'package:zanka_no_tachi/live_media/mangaworld_reader_source.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/reader/reader_domain.dart';

const mediaId = CanonicalMediaId('media');
const chapterId = CanonicalChapterId('chapter');
const episodeId = CanonicalEpisodeId('episode');

void main() {
  final mangaConfig = ProviderConfig(
    id: mangaWorldProviderId,
    displayName: 'MangaWorld',
    baseUrl: Uri.parse('https://www.fixture.invalid/'),
    mediaKind: CanonicalMediaKind.manga,
  );
  final animeConfig = ProviderConfig(
    id: animeWorldProviderId,
    displayName: 'AnimeWorld',
    baseUrl: Uri.parse('https://anime.fixture.invalid/'),
    mediaKind: CanonicalMediaKind.anime,
  );

  test(
    'MangaWorld parses ordered public pages and lazily loads bytes',
    () async {
      final transport = _FakeTransport({
        '/manga/work/read/chapter-token': _fixture(
          'mangaworld/chapter_reader_public.html',
        ),
        'https://cdn.fixture.invalid/chapters/work/volume-03/chapter-10/1.jpg':
            'one',
        'https://cdn.fixture.invalid/chapters/work/volume-03/chapter-10/2.png':
            'two',
        'https://cdn.fixture.invalid/chapters/work/volume-03/chapter-10/03.webp':
            'three',
      });
      final resolver = MangaWorldReaderSource(
        config: mangaConfig,
        transport: transport,
      );
      const binding = ChapterSourceBinding(
        canonicalId: chapterId,
        providerId: mangaWorldProviderId,
        externalId: 'chapter-token',
        relativeLocator: '/manga/work/read/chapter-token',
      );
      final manifest = await resolver.resolve(
        const ReaderSessionRequest(
          mediaId: mediaId,
          chapterId: chapterId,
          binding: binding,
        ),
      );
      expect(manifest.pages.map((page) => page.index), [0, 1, 2]);
      expect(transport.requests, hasLength(1));
      expect(utf8.decode(await manifest.pages[1].loadBytes()), 'two');
      expect(
        transport.requests.last.headers['Referer'],
        contains('/manga/work/read/'),
      );
      expect(manifest.pages.first.displayLocator, isNot(contains('https://')));
    },
  );

  test('MangaWorld parser drift and network failure stay distinct', () async {
    expect(
      () => parseMangaWorldPages(
        _fixture('mangaworld/chapter_reader_drift.html'),
        Uri.parse('https://www.fixture.invalid/read/a'),
      ),
      throwsA(
        isA<ReaderException>().having(
          (e) => e.kind,
          'kind',
          ReaderErrorKind.manifestInvalid,
        ),
      ),
    );
    final resolver = MangaWorldReaderSource(
      config: mangaConfig,
      transport: _ThrowingTransport(),
    );
    await expectLater(
      resolver.resolve(
        const ReaderSessionRequest(
          mediaId: mediaId,
          chapterId: chapterId,
          binding: ChapterSourceBinding(
            canonicalId: chapterId,
            providerId: mangaWorldProviderId,
            externalId: 'x',
            relativeLocator: '/read/x',
          ),
        ),
      ),
      throwsA(
        isA<ReaderException>().having(
          (e) => e.kind,
          'kind',
          ReaderErrorKind.sourceUnavailable,
        ),
      ),
    );
  });

  test(
    'AnimeWorld resolves public JSON and iframe to MP4 with headers',
    () async {
      final transport = _FakeTransport({
        '/play/work.series/episode-token': _fixture(
          'animeworld/episode_page_public.html',
        ),
        '/api/episode/info?alt=0&id=episode-token': _fixture(
          'animeworld/episode_info_public.json',
        ),
        '/api/episode/serverPlayerAnimeWorld?id=episode-token': _fixture(
          'animeworld/player_public_mp4.html',
        ),
      });
      final resolver = AnimeWorldPlaybackSource(
        config: animeConfig,
        transport: transport,
      );
      const binding = EpisodeSourceBinding(
        canonicalId: episodeId,
        providerId: animeWorldProviderId,
        externalId: 'episode-token',
        relativeLocator: '/play/work.series/episode-token',
      );
      final manifest = await resolver.resolve(
        const PlaybackSessionRequest(
          mediaId: mediaId,
          episodeId: episodeId,
          binding: binding,
        ),
      );
      expect(manifest.uri.host, 'media.fixture.invalid');
      expect(manifest.isLocalFile, isFalse);
      expect(
        manifest.httpHeaders['Referer'],
        contains('/api/episode/serverPlayerAnimeWorld'),
      );
      expect(transport.requests[1].headers['CSRF-Token'], 'fixture-csrf');
      expect(manifest.audioTracks, isEmpty);
      expect(manifest.subtitleTracks, isEmpty);
    },
  );

  test('AnimeWorld player drift is typed separately from reachability', () {
    expect(
      () => parseAnimeWorldMedia(
        _fixture('animeworld/player_drift.html'),
        Uri.parse('https://anime.fixture.invalid/player'),
      ),
      throwsA(
        isA<PlaybackException>().having(
          (e) => e.kind,
          'kind',
          PlaybackErrorKind.manifestInvalid,
        ),
      ),
    );
  });

  test(
    'configured provider replacement changes resolution authority, not binding identity',
    () async {
      final registry = ProviderRegistry([mangaConfig]);
      final transport = _FakeTransport({
        'https://old.fixture.invalid/read/chapter-token': _fixture(
          'mangaworld/chapter_reader_public.html',
        ),
        'https://new.fixture.invalid/read/chapter-token': _fixture(
          'mangaworld/chapter_reader_public.html',
        ),
      });
      registry.replace(
        mangaConfig.copyWith(
          baseUrl: Uri.parse('https://old.fixture.invalid/'),
        ),
      );
      final resolver = MangaWorldReaderSource.fromRegistry(
        registry: registry,
        transport: transport,
      );
      const binding = ChapterSourceBinding(
        canonicalId: chapterId,
        providerId: mangaWorldProviderId,
        externalId: 'chapter-token',
        relativeLocator: '/read/chapter-token',
      );
      await resolver.resolve(
        const ReaderSessionRequest(
          mediaId: mediaId,
          chapterId: chapterId,
          binding: binding,
        ),
      );
      registry.replace(
        mangaConfig.copyWith(
          baseUrl: Uri.parse('https://new.fixture.invalid/'),
        ),
      );
      await resolver.resolve(
        const ReaderSessionRequest(
          mediaId: mediaId,
          chapterId: chapterId,
          binding: binding,
        ),
      );
      expect(transport.requests.map((value) => value.uri.host), [
        'old.fixture.invalid',
        'new.fixture.invalid',
      ]);
      expect(binding.externalId, 'chapter-token');
    },
  );
}

String _fixture(String name) => File('fixtures/$name').readAsStringSync();

class _Request {
  const _Request(this.uri, this.headers);
  final Uri uri;
  final Map<String, String> headers;
}

class _FakeTransport implements LiveMediaTransport {
  _FakeTransport(this.responses);
  final Map<String, String> responses;
  final List<_Request> requests = [];
  @override
  Future<LiveMediaResponse> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    requests.add(_Request(uri, headers));
    final key = responses.containsKey(uri.toString())
        ? uri.toString()
        : uri.hasQuery
        ? '${uri.path}?${Uri(queryParameters: Map.fromEntries(uri.queryParameters.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))).query}'
        : uri.path;
    final value = responses[key];
    if (value == null) {
      return LiveMediaResponse(
        statusCode: 404,
        bytes: Uint8List(0),
        finalUri: uri,
      );
    }
    final media =
        uri.path.endsWith('.jpg') ||
        uri.path.endsWith('.png') ||
        uri.path.endsWith('.webp');
    return LiveMediaResponse(
      statusCode: 200,
      bytes: Uint8List.fromList(utf8.encode(value)),
      finalUri: uri,
      headers: {
        'content-type': media
            ? 'image/jpeg'
            : uri.path.endsWith('/info')
            ? 'application/json'
            : 'text/html',
      },
    );
  }

  @override
  void close() {}
}

class _ThrowingTransport implements LiveMediaTransport {
  @override
  Future<LiveMediaResponse> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) => throw const SocketException('offline');
  @override
  void close() {}
}
