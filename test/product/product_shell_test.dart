import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/matching.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/main.dart';
import 'package:zanka_no_tachi/app/presentation_mode.dart';
import 'package:zanka_no_tachi/reader/ui/manga_reader_screen.dart';

void main() {
  testWidgets('semantic TV mode composes the 10-foot shell', (tester) async {
    final repository = _repository(CanonicalDatabase(NativeDatabase.memory()));
    await tester.pumpWidget(
      ZankaApp(repository: repository, presentationMode: PresentationMode.tv),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tv-product-shell')), findsOneWidget);
    expect(find.text('Your TV home is ready'), findsOneWidget);
    expect(find.byKey(const Key('tv-empty-browse')), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  for (final layout in [
    (name: 'phone', size: const Size(360, 780), mode: PresentationMode.mobile),
    (
      name: 'tablet',
      size: const Size(1100, 800),
      mode: PresentationMode.tablet,
    ),
  ]) {
    testWidgets('${layout.name} navigation and Settings routes stay usable', (
      tester,
    ) async {
      tester.view.reset();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = layout.size;
      addTearDown(tester.view.reset);
      final repository = _repository(
        CanonicalDatabase(NativeDatabase.memory()),
      );
      await tester.pumpWidget(
        ZankaApp(repository: repository, presentationMode: layout.mode),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('product-primary-navigation')),
        findsOneWidget,
      );
      for (final destination in ['home', 'search', 'library', 'settings']) {
        expect(
          find.byKey(Key('nav-$destination')).hitTestable(),
          findsOneWidget,
        );
      }
      await tester.tap(find.byKey(const Key('nav-search')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('product-search-field')),
        'saved query',
      );
      await tester.tap(find.byKey(const Key('nav-library')));
      await tester.pumpAndSettle();
      expect(find.text('Nothing here yet'), findsOneWidget);
      await tester.tap(find.byKey(const Key('nav-settings')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('settings-sources')));
      await tester.tap(find.byKey(const Key('settings-sources')));
      await tester.pumpAndSettle();

      const providerKey = Key('setting-provider-mangaworld');
      expect(tester.widget<Switch>(find.byKey(providerKey)).value, isTrue);
      await tester.tap(find.byKey(providerKey));
      await tester.pumpAndSettle();
      expect(
        repository.registry.require(const ProviderId('mangaworld')).enabled,
        isFalse,
      );
      expect(tester.widget<Switch>(find.byKey(providerKey)).value, isFalse);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        find.byKey(const PageStorageKey('settings-scroll')),
        findsOneWidget,
      );
      expect(find.byKey(providerKey), findsNothing);
      await tester.tap(find.byKey(const Key('nav-search')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SearchBar>(find.byKey(const Key('product-search-field')))
            .controller
            ?.text,
        'saved query',
      );
      await tester.tap(find.byKey(const Key('nav-home')));
      await tester.pumpAndSettle();
      expect(find.byKey(const PageStorageKey('home-scroll')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repository.dispose();
    });
  }

  testWidgets('TV shell destinations activate with D-pad focus', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 800);
    addTearDown(tester.view.reset);
    final repository = _repository(CanonicalDatabase(NativeDatabase.memory()));
    await tester.pumpWidget(
      ZankaApp(repository: repository, presentationMode: PresentationMode.tv),
    );
    await tester.pumpAndSettle();

    const homeKey = Key('nav-home');
    for (var attempt = 0; attempt < 12 && !_focusWithin(homeKey); attempt++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    expect(_focusWithin(homeKey), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(_focusWithin(const Key('nav-search')), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tv-search-field')), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(_focusWithin(const Key('nav-library')), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.text('Your Library is empty'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets(
    'launches Home with discover sections and Developer is intentional',
    (tester) async {
      final repository = _repository(
        CanonicalDatabase(NativeDatabase.memory()),
      );
      await tester.pumpWidget(ZankaApp(repository: repository));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Discover Manga'), findsOneWidget);
      await tester.drag(
        find.byKey(const PageStorageKey('home-scroll')),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();
      expect(find.text('Discover Anime'), findsOneWidget);
      expect(find.text('Developer Sources'), findsNothing);

      await tester.tap(find.byKey(const Key('nav-settings')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('open-local-media')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-local-media')));
      await tester.pumpAndSettle();
      expect(find.text('Import CBZ'), findsOneWidget);
      expect(find.text('Import image folder'), findsOneWidget);
      expect(find.text('Import video'), findsOneWidget);
      expect(find.text('Create data-only backup'), findsOneWidget);
      expect(find.text('Restore backup'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('open-developer-tools')), findsNothing);
      await tester.ensureVisible(find.byKey(const Key('open-about')));
      await tester.pumpAndSettle();
      await tester.longPress(find.byKey(const Key('open-about')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('open-developer-tools')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-developer-tools')));
      await tester.pumpAndSettle();
      expect(find.text('Developer Sources'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await repository.dispose();
    },
  );

  testWidgets('partial search opens details and add/remove updates Library', (
    tester,
  ) async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    final repository = _repository(database, animeSearchFails: true);
    await tester.pumpWidget(ZankaApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nav-search')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('product-search-field')),
      'mad',
    );
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('MAD'), findsOneWidget);
    expect(
      find.textContaining('Some sources could not be searched'),
      findsOneWidget,
    );

    await tester.tap(find.text('MAD'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('media-details')), findsOneWidget);
    expect(find.text('Chapters'), findsOneWidget);
    await tester.tap(find.byKey(const Key('toggle-library')));
    await tester.pumpAndSettle();
    expect(
      (await database.libraryEntry(
        (await database.allMedia()).single.id,
      ))?.isSaved,
      isTrue,
    );
    await tester.drag(
      find.byKey(const Key('media-details')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Sources:'), findsWidgets);
    await tester.tap(find.text('Capitolo 46.5'));
    await tester.pumpAndSettle();
    expect(find.byType(MangaReaderScreen), findsOneWidget);
    expect(find.text('Retry reader'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-library')));
    await tester.pumpAndSettle();
    expect(find.text('MAD'), findsOneWidget);
    await tester.tap(find.text('MAD'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('toggle-library')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Nothing here yet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets(
    'merged media renders once with both sources and preference persists',
    (tester) async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      final repository = _repository(database);
      await repository.seedSyntheticReconciliationScenarios();
      await repository.reconciliation.mergeCanonicalMedia(
        sourceId: const CanonicalMediaId('m3-berserk-b'),
        targetId: const CanonicalMediaId('m3-berserk-a'),
        reason: MergeReason.reviewedUserDecision,
      );
      final now = DateTime.utc(2026, 8, 25);
      await database.saveLibraryEntry(
        CanonicalLibraryEntry(
          mediaId: const CanonicalMediaId('m3-berserk-a'),
          isSaved: true,
          isFavorite: false,
          status: CanonicalLibraryStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await tester.pumpWidget(ZankaApp(repository: repository));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-library')));
      await tester.pumpAndSettle();
      expect(find.text('Berserk (M3 synthetic)'), findsOneWidget);
      await tester.tap(find.text('Berserk (M3 synthetic)'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('source-synthetic-manga-a')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('source-synthetic-manga-b')),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('source-synthetic-manga-b')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('source-synthetic-manga-b')));
      await tester.pumpAndSettle();
      expect(
        await database.preferredProvider(
          const CanonicalMediaId('m3-berserk-a'),
        ),
        const ProviderId('synthetic-manga-b'),
      );
      await tester.drag(
        find.byKey(const Key('media-details')),
        const Offset(0, -800),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Sources: Synthetic Manga A, Synthetic Manga B'),
        findsWidgets,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await repository.dispose();
    },
  );

  testWidgets('persisted progress appears in Continue during provider outage', (
    tester,
  ) async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    final repository = _repository(database, allRequestsFail: true);
    await repository.seedSyntheticReconciliationScenarios();
    final now = DateTime.utc(2026, 8, 25);
    await database.saveLibraryEntry(
      CanonicalLibraryEntry(
        mediaId: const CanonicalMediaId('m3-berserk-a'),
        isSaved: true,
        isFavorite: true,
        status: CanonicalLibraryStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.saveMangaProgress(
      CanonicalMangaProgress(
        mediaId: const CanonicalMediaId('m3-berserk-a'),
        chapterId: const CanonicalChapterId('m3-berserk-a-chapter-140'),
        pageIndex: 7,
        updatedAt: now,
      ),
    );
    await tester.pumpWidget(ZankaApp(repository: repository));
    await tester.pumpAndSettle();
    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('Page 8'), findsOneWidget);
    expect(find.text('Berserk (M3 synthetic)'), findsWidgets);
    await tester.drag(
      find.byKey(const PageStorageKey('home-scroll')),
      const Offset(0, -1600),
    );
    await tester.pumpAndSettle();
    expect(find.text('Some sources are unavailable'), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav-library')));
    await tester.pumpAndSettle();
    expect(find.text('Berserk (M3 synthetic)'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });

  testWidgets('anime details expose episodes without invoking a player', (
    tester,
  ) async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    final repository = _repository(database);
    await repository.seedSyntheticReconciliationScenarios();
    final now = DateTime.utc(2026, 8, 25);
    await database.saveLibraryEntry(
      CanonicalLibraryEntry(
        mediaId: const CanonicalMediaId('m3-anime-a'),
        isSaved: true,
        isFavorite: false,
        status: CanonicalLibraryStatus.planned,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await tester.pumpWidget(ZankaApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-library')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Example Anime (M3 synthetic)'));
    await tester.pumpAndSettle();
    expect(find.text('Episodes'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('media-details')),
      const Offset(0, -800),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Episode 1'));
    await tester.pumpAndSettle();
    expect(
      find.text('This installment can’t be opened right now.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('approximate across different encodes'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await repository.dispose();
  });
}

bool _focusWithin(Key key) {
  var found = false;
  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((element) {
    if (element.widget.key == key) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

LiveProviderRepository _repository(
  CanonicalDatabase database, {
  bool animeSearchFails = false,
  bool allRequestsFail = false,
}) => LiveProviderRepository(
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
  transport: _ProductTransport(
    animeSearchFails: animeSearchFails,
    allRequestsFail: allRequestsFail,
  ),
);

class _ProductTransport implements ProviderTransport {
  _ProductTransport({
    required this.animeSearchFails,
    required this.allRequestsFail,
  });
  final bool animeSearchFails;
  final bool allRequestsFail;
  @override
  Future<ProviderResponse> get(Uri uri) async {
    if (allRequestsFail || animeSearchFails && uri.path == '/search') {
      throw const SocketException('offline');
    }
    final key = uri.hasQuery ? '${uri.path}?${uri.query}' : uri.path;
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
      '/animes': File(
        'fixtures/animeworld/catalog_page.html',
      ).readAsStringSync(),
      '/search?keyword=mad': File(
        'fixtures/animeworld/search_results.html',
      ).readAsStringSync(),
    };
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
