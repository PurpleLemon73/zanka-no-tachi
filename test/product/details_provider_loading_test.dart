import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_media/animeworld_playback_source.dart';
import 'package:zanka_no_tachi/live_media/mangaworld_reader_source.dart';
import 'package:zanka_no_tachi/live_media/live_media_transport.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_adapter.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/player/playback_repository.dart';
import 'package:zanka_no_tachi/player/playback_source.dart';
import 'package:zanka_no_tachi/product/product_controller.dart';
import 'package:zanka_no_tachi/product/product_models.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';
import 'package:zanka_no_tachi/product/ui/media_details_screen.dart';
import 'package:zanka_no_tachi/reader/reader_preferences_store.dart';
import 'package:zanka_no_tachi/reader/reader_repository.dart';
import 'package:zanka_no_tachi/reader/reader_source.dart';
import 'package:zanka_no_tachi/tv/tv_media_details_screen.dart';

void main() {
  for (final kind in CanonicalMediaKind.values) {
    for (final tv in [false, true]) {
      final label = '${tv ? 'TV' : 'phone'} ${kind.name}';
      testWidgets(
        '$label source opening fetches one metadata document and no media payload',
        (tester) async {
          final fixture = _fixture(tester, kind);
          await tester.pumpWidget(fixture.app(tv));
          await tester.pumpAndSettle();
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.text('Details unavailable'), findsNothing);
          expect(fixture.requests.map((uri) => uri.path), [fixture.path]);
          expect(fixture.media.requests, isEmpty);
          final saved = (await fixture.live.database.allMedia()).single;
          final details = (await fixture.controller.details(saved.id))!;
          expect(
            kind == CanonicalMediaKind.manga
                ? details.chapters.length
                : details.episodes.length,
            2,
          );
          expect(
            kind == CanonicalMediaKind.manga
                ? details.readerChapters.length
                : details.playbackEpisodes.length,
            2,
          );
          expect(await fixture.live.database.allLocalAssets(), isEmpty);
          expect(fixture.media.requests, isEmpty);
          expect(
            fixture.requests,
            hasLength(1),
            reason: 'Opening canonical Details again must be offline.',
          );
        },
      );

      testWidgets(
        '$label network error terminates and retry starts a fresh successful request',
        (tester) async {
          final fixture = _fixture(tester, kind);
          fixture.response = (_) =>
              Future.error(const SocketException('offline'));
          await tester.pumpWidget(fixture.app(tv));
          await tester.pumpAndSettle();
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(
            find.text('This source is currently unreachable.'),
            findsOneWidget,
          );
          fixture.response = (_) async => http.Response(fixture.html, 200);
          await tester.tap(find.text('Retry'));
          await tester.pumpAndSettle();
          expect(find.text('Details unavailable'), findsNothing);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(await fixture.live.database.allMedia(), hasLength(1));
          expect(
            fixture.requests,
            hasLength(3),
          ); // Existing transport: two failed attempts, then fresh retry.
          expect(fixture.media.requests, isEmpty);
        },
      );

      testWidgets(
        '$label malformed detail is a parser error and never ingests media',
        (tester) async {
          final fixture = _fixture(tester, kind);
          fixture.response = (_) async =>
              http.Response('<html>Changed markup</html>', 200);
          await tester.pumpWidget(fixture.app(tv));
          await tester.pumpAndSettle();
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(
            find.text('This source changed and needs an update.'),
            findsOneWidget,
          );
          expect(await fixture.live.database.allMedia(), isEmpty);
          expect(fixture.media.requests, isEmpty);
        },
      );

      testWidgets(
        '$label disabled source terminates without network activity',
        (tester) async {
          final fixture = _fixture(tester, kind);
          final config = fixture.live.registry.require(
            fixture.result.sources.single.providerId,
          );
          fixture.live.registry.replace(config.copyWith(enabled: false));
          await tester.pumpWidget(fixture.app(tv));
          await tester.pumpAndSettle();
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.text('This source is disabled.'), findsOneWidget);
          expect(fixture.requests, isEmpty);
          expect(fixture.media.requests, isEmpty);
        },
      );
    }

    testWidgets(
      '${kind.name} hung HTTP request exits at the existing transport deadline; late result is ignored',
      (tester) async {
        final fixture = _fixture(tester, kind);
        final held = Completer<http.Response>();
        fixture.response = (_) => held.future;
        await tester.pumpWidget(fixture.app(false));
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        // Exercise the production 12s-per-attempt deadline, not a UI timer.
        await tester.pump(const Duration(seconds: 13));
        await tester.pump(const Duration(seconds: 13));
        await tester.pumpAndSettle();
        expect(
          find.text('This source is currently unreachable.'),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(fixture.requests, hasLength(2));
        held.complete(http.Response(fixture.html, 200));
        await tester.pumpAndSettle();
        expect(await fixture.live.database.allMedia(), isEmpty);
        expect(
          find.text('This source is currently unreachable.'),
          findsOneWidget,
        );
        expect(fixture.media.requests, isEmpty);
      },
    );
  }
}

_Fixture _fixture(WidgetTester tester, CanonicalMediaKind kind) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1280, 900);
  addTearDown(tester.view.reset);
  final fixture = _Fixture(kind);
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    fixture.controller.dispose();
    await fixture.live.dispose();
  });
  return fixture;
}

class _Fixture {
  _Fixture(this.kind) {
    final registry = ProviderRegistry([
      for (final entry in CanonicalMediaKind.values)
        ProviderConfig(
          id: ProviderId(
            entry == CanonicalMediaKind.manga ? 'mangaworld' : 'animeworld',
          ),
          displayName: entry.name,
          baseUrl: Uri.parse('https://fixture.invalid/'),
          mediaKind: entry,
        ),
    ]);
    response = (_) async => http.Response(html, 200);
    live = LiveProviderRepository(
      registry: registry,
      database: CanonicalDatabase(NativeDatabase.memory()),
      transport: HttpProviderTransport(
        client: MockClient((request) {
          requests.add(request.url);
          return response(request);
        }),
      ),
    );
    controller = ProductController(
      ProductRepository(
        live,
        reader: ReaderRepository(
          database: live.database,
          sources: ReaderSourceRegistry([
            MangaWorldReaderSource.fromRegistry(
              registry: registry,
              transport: media,
            ),
          ]),
          preferencesStore: ReaderPreferencesStore(),
        ),
        playback: PlaybackRepository(
          database: live.database,
          sources: PlaybackSourceRegistry([
            AnimeWorldPlaybackSource.fromRegistry(
              registry: registry,
              transport: media,
            ),
          ]),
          preferencesStore: PlaybackPreferencesStore(),
        ),
      ),
    );
  }
  final CanonicalMediaKind kind;
  final requests = <Uri>[];
  final media = _NoMediaRequests();
  late Future<http.Response> Function(http.Request) response;
  late final LiveProviderRepository live;
  late final ProductController controller;
  String get path => kind == CanonicalMediaKind.manga
      ? '/manga/3693/mad'
      : '/play/fullmetal-alchemist.Ge2kM';
  String get html => File(
    kind == CanonicalMediaKind.manga
        ? 'fixtures/mangaworld/manga_detail_ongoing.html'
        : 'fixtures/animeworld/anime_detail_tv.html',
  ).readAsStringSync();
  ProductSearchResult get result => ProductSearchResult(
    title: 'Test ${kind.name}',
    kind: kind,
    sources: [
      ProviderListingItem(
        providerId: ProviderId(
          kind == CanonicalMediaKind.manga ? 'mangaworld' : 'animeworld',
        ),
        externalId: kind == CanonicalMediaKind.manga ? '3693' : 'Ge2kM',
        title: 'Test ${kind.name}',
        relativeLocator: path,
        mediaKind: kind,
      ),
    ],
  );
  Widget app(bool tv) => MaterialApp(
    home: tv
        ? TvMediaDetailsScreen(
            controller: controller,
            mediaId: null,
            searchResult: result,
          )
        : MediaDetailsScreen(
            controller: controller,
            mediaId: null,
            searchResult: result,
          ),
  );
}

class _NoMediaRequests implements LiveMediaTransport {
  final requests = <Uri>[];
  @override
  Future<LiveMediaResponse> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    requests.add(uri);
    throw StateError('Details must not resolve or download media');
  }

  @override
  void close() {}
}
