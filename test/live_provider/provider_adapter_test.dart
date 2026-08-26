import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/live_provider/provider_adapter.dart';
import 'package:zanka_no_tachi/live_provider/provider_errors.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';

void main() {
  group('provider registry', () {
    test(
      'owns stable IDs, base URLs, kinds, and replacement configuration',
      () {
        final registry = ProviderRegistry.defaults();
        final manga = registry.require(const ProviderId('mangaworld'));
        expect(manga.mediaKind, CanonicalMediaKind.manga);
        expect(manga.enabled, isTrue);
        registry.replace(
          manga.copyWith(baseUrl: Uri.parse('https://new.invalid/')),
        );
        expect(
          registry.require(const ProviderId('mangaworld')).baseUrl.host,
          'new.invalid',
        );
        expect(registry.all, hasLength(2));
      },
    );
  });

  group('live adapters through fake transport', () {
    test(
      'MangaWorld catalog, search, detail, and health use M0 boundaries',
      () async {
        final transport = _Routes({
          '/archive': _fixture('mangaworld/catalog_page.html'),
          '/archive?page=2': _fixture('mangaworld/catalog_page.html'),
          '/archive?keyword=mad': _fixture('mangaworld/search_results.html'),
          '/archive?keyword=mad&page=2': _fixture(
            'mangaworld/search_results.html',
          ),
          '/manga/3693/mad': _fixture('mangaworld/manga_detail_ongoing.html'),
        });
        final adapter = MangaWorldLiveAdapter(
          config: _config('mangaworld', CanonicalMediaKind.manga),
          transport: transport,
        );
        expect(
          (await adapter.checkHealth()).state,
          ProviderHealthState.available,
        );
        expect((await adapter.catalog()).items.first.externalId, '3693');
        expect((await adapter.catalog(page: 2)).items.first.externalId, '3693');
        final search = await adapter.search('mad');
        expect(search.items.single.title, 'MAD');
        expect(
          (await adapter.search('mad', page: 2)).items.single.title,
          'MAD',
        );
        final detail = await adapter.detail(search.items.single);
        expect((detail as MangaWorldTitleResult).dto.chapters, hasLength(2));
      },
    );

    test(
      'AnimeWorld catalog, search, detail, and health use M0 boundaries',
      () async {
        final transport = _Routes({
          '/animes': _fixture('animeworld/catalog_page.html'),
          '/search?keyword=fullmetal': _fixture(
            'animeworld/search_results.html',
          ),
          '/play/fullmetal-alchemist.Ge2kM': _fixture(
            'animeworld/anime_detail_tv.html',
          ),
        });
        final adapter = AnimeWorldLiveAdapter(
          config: _config('animeworld', CanonicalMediaKind.anime),
          transport: transport,
        );
        expect(
          (await adapter.checkHealth()).state,
          ProviderHealthState.available,
        );
        expect((await adapter.catalog()).items, hasLength(2));
        final search = await adapter.search('fullmetal');
        final detail = await adapter.detail(search.items.single);
        expect((detail as AnimeWorldTitleResult).dto.episodes, hasLength(2));
      },
    );

    test('HTTP 200 with incompatible HTML is parserMismatch', () async {
      final adapter = MangaWorldLiveAdapter(
        config: _config('mangaworld', CanonicalMediaKind.manga),
        transport: _Routes({
          '/archive': '<html><h1>Still reachable</h1></html>',
        }),
      );
      final health = await adapter.checkHealth();
      expect(health.state, ProviderHealthState.parserMismatch);
      expect(health.diagnostic, contains('markers'));
    });

    test('network and HTTP failures have distinct health states', () async {
      final network = MangaWorldLiveAdapter(
        config: _config('mangaworld', CanonicalMediaKind.manga),
        transport: _ThrowingTransport(TimeoutException('slow')),
      );
      expect(
        (await network.checkHealth()).state,
        ProviderHealthState.unreachable,
      );
      final httpFailure = MangaWorldLiveAdapter(
        config: _config('mangaworld', CanonicalMediaKind.manga),
        transport: _StatusTransport(503),
      );
      expect(
        (await httpFailure.checkHealth()).state,
        ProviderHealthState.unexpectedResponse,
      );
    });

    test(
      'disabled provider does no network work and reports disabled',
      () async {
        final transport = _CountingTransport();
        final adapter = MangaWorldLiveAdapter(
          config: _config(
            'mangaworld',
            CanonicalMediaKind.manga,
            enabled: false,
          ),
          transport: transport,
        );
        expect(
          (await adapter.checkHealth()).state,
          ProviderHealthState.disabled,
        );
        expect(transport.calls, 0);
        await expectLater(
          adapter.catalog(),
          throwsA(isA<ProviderDisabledException>()),
        );
        expect(transport.calls, 0);
      },
    );
  });

  test(
    'production transport enforces timeout and adapter maps it to network error',
    () async {
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return http.Response('late', 200);
      });
      final transport = HttpProviderTransport(
        client: client,
        timeout: const Duration(milliseconds: 1),
        maxTransientRetries: 0,
      );
      final adapter = MangaWorldLiveAdapter(
        config: _config('mangaworld', CanonicalMediaKind.manga),
        transport: transport,
      );
      await expectLater(
        adapter.catalog(),
        throwsA(isA<ProviderNetworkException>()),
      );
      transport.close();
    },
  );
}

ProviderConfig _config(
  String id,
  CanonicalMediaKind kind, {
  bool enabled = true,
}) => ProviderConfig(
  id: ProviderId(id),
  displayName: id,
  baseUrl: Uri.parse('https://fixture.invalid/'),
  mediaKind: kind,
  enabled: enabled,
);

String _fixture(String path) => File('fixtures/$path').readAsStringSync();

class _Routes implements ProviderTransport {
  _Routes(this.routes);
  final Map<String, String> routes;
  @override
  Future<ProviderResponse> get(Uri uri) async {
    final key = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
    final body = routes[key];
    return ProviderResponse(
      statusCode: body == null ? 404 : 200,
      body: body ?? '',
      finalUri: uri,
    );
  }

  @override
  void close() {}
}

class _ThrowingTransport implements ProviderTransport {
  _ThrowingTransport(this.error);
  final Object error;
  @override
  Future<ProviderResponse> get(Uri uri) => Future.error(error);
  @override
  void close() {}
}

class _StatusTransport implements ProviderTransport {
  _StatusTransport(this.status);
  final int status;
  @override
  Future<ProviderResponse> get(Uri uri) async =>
      ProviderResponse(statusCode: status, body: 'error', finalUri: uri);
  @override
  void close() {}
}

class _CountingTransport implements ProviderTransport {
  int calls = 0;
  @override
  Future<ProviderResponse> get(Uri uri) async {
    calls++;
    return ProviderResponse(statusCode: 200, body: '', finalUri: uri);
  }

  @override
  void close() {}
}
