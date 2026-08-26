import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/main.dart';

void main() {
  testWidgets(
    'developer UI checks, searches, ingests, and inspects canonical data',
    (tester) async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      final repository = _repository(database);
      await tester.pumpWidget(ZankaApp(repository: repository));
      await tester.pumpAndSettle();
      expect(find.text('Zanka'), findsWidgets);
      await _openDeveloper(tester);
      expect(find.text('Developer Sources'), findsOneWidget);
      expect(find.byKey(const Key('provider-mangaworld')), findsOneWidget);
      expect(find.byKey(const Key('provider-animeworld')), findsOneWidget);

      await tester.tap(find.byKey(const Key('check-mangaworld')));
      await tester.pumpAndSettle();
      expect(find.textContaining('available'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const Key('developer-search-field')),
      );
      await tester.enterText(
        find.byKey(const Key('developer-search-field')),
        'mad',
      );
      await tester.tap(find.byKey(const Key('developer-search')));
      await tester.pumpAndSettle();
      expect(find.text('MAD'), findsOneWidget);

      await tester.tap(find.text('MAD'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('detail-inspection')), findsOneWidget);
      expect(find.textContaining('Canonical ID:'), findsOneWidget);
      expect(find.text('Chapters: 2'), findsOneWidget);
      expect(await database.allMedia(), hasLength(1));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(ZankaApp(repository: repository));
      await tester.pumpAndSettle();
      await _openDeveloper(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();
      expect(find.text('MAD'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await repository.dispose();
    },
  );

  testWidgets('developer UI changes provider base URL from one authority', (
    tester,
  ) async {
    final repository = _repository(CanonicalDatabase(NativeDatabase.memory()));
    await tester.pumpWidget(ZankaApp(repository: repository));
    await tester.pumpAndSettle();
    await _openDeveloper(tester);
    final field = find.byKey(const Key('base-url-mangaworld'));
    await tester.enterText(field, 'https://replacement.invalid/');
    await tester.tap(find.byKey(const Key('apply-url-mangaworld')));
    await tester.pump();
    expect(
      repository.registry.require(const ProviderId('mangaworld')).baseUrl.host,
      'replacement.invalid',
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets('developer UI reviews, merges, resolves alias, and undoes', (
    tester,
  ) async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    await _seedManga(database, 'target', 'provider-a');
    await _seedManga(database, 'source', 'provider-b');
    final repository = _repository(database);
    await tester.pumpWidget(ZankaApp(repository: repository));
    await tester.pumpAndSettle();
    await _openDeveloper(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('show-candidates')));
    await tester.pumpAndSettle();
    expect(find.textContaining('ambiguousCandidate'), findsOneWidget);

    await tester.tap(find.byKey(const Key('reviewed-merge')));
    await tester.pumpAndSettle();
    expect(await database.allMedia(), hasLength(1));
    expect(find.byKey(const Key('alias-resolution')), findsOneWidget);
    expect(find.textContaining('provider-a'), findsWidgets);
    expect(find.textContaining('provider-b'), findsWidgets);

    await tester.ensureVisible(find.byKey(const Key('undo-merge')));
    await tester.tap(find.byKey(const Key('undo-merge')));
    await tester.pumpAndSettle();
    expect(await database.allMedia(), hasLength(2));
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });
}

Future<void> _openDeveloper(WidgetTester tester) async {
  await tester.tap(find.text('Settings'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(const Key('open-developer-tools')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('open-developer-tools')));
  await tester.pumpAndSettle();
}

Future<void> _seedManga(
  CanonicalDatabase database,
  String id,
  String provider,
) async {
  await database.saveMedia(
    CanonicalManga(
      id: CanonicalMediaId(id),
      title: SourcedValue(
        value: 'Synthetic Berserk',
        provenance: FieldProvenance(providerId: ProviderId(provider)),
      ),
    ),
  );
  await database.saveMediaBinding(
    MediaSourceBinding(
      canonicalId: CanonicalMediaId(id),
      providerId: ProviderId(provider),
      externalId: '$provider-$id',
    ),
  );
}

LiveProviderRepository _repository(CanonicalDatabase database) =>
    LiveProviderRepository(
      registry: ProviderRegistry([
        ProviderConfig(
          id: const ProviderId('mangaworld'),
          displayName: 'MangaWorld',
          baseUrl: Uri.parse('https://fixture.invalid/'),
          mediaKind: CanonicalMediaKind.manga,
        ),
        ProviderConfig(
          id: const ProviderId('animeworld'),
          displayName: 'AnimeWorld',
          baseUrl: Uri.parse('https://fixture.invalid/'),
          mediaKind: CanonicalMediaKind.anime,
        ),
      ]),
      database: database,
      transport: _FixtureTransport(),
    );

class _FixtureTransport implements ProviderTransport {
  final routes = <String, String>{
    '/archive': File(
      'fixtures/mangaworld/catalog_page.html',
    ).readAsStringSync(),
    '/archive?keyword=mad': File(
      'fixtures/mangaworld/search_results.html',
    ).readAsStringSync(),
    '/manga/3693/mad': File(
      'fixtures/mangaworld/manga_detail_ongoing.html',
    ).readAsStringSync(),
    '/animes': File('fixtures/animeworld/catalog_page.html').readAsStringSync(),
  };
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
