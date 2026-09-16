import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/adapter_platform/adapter_sdk.dart';
import 'package:zanka_no_tachi/app/app_preferences.dart';
import 'package:zanka_no_tachi/app/presentation_mode.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_adapter.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/product/product_controller.dart';
import 'package:zanka_no_tachi/product/product_models.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';
import 'package:zanka_no_tachi/product/smart_resume.dart';
import 'package:zanka_no_tachi/product/ui/content_visuals.dart';
import 'package:zanka_no_tachi/product/ui/design_system.dart';
import 'package:zanka_no_tachi/product/ui/product_shell.dart';
import 'package:zanka_no_tachi/tv/tv_design_system.dart';

void main() {
  setUpAll(() async {
    const font = String.fromEnvironment('ZANKA_VISUAL_FONT');
    if (font.isEmpty) return;
    await (FontLoader(
      'Roboto',
    )..addFont(File(font).readAsBytes().then(ByteData.sublistView))).load();
    await (FontLoader(
      'serif',
    )..addFont(File(font).readAsBytes().then(ByteData.sublistView))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final layout in [
    (name: 'narrow', size: const Size(320, 720), scale: 2.0, tv: false),
    (name: 'phone', size: const Size(390, 844), scale: 1.0, tv: false),
    (
      name: 'phone-landscape',
      size: const Size(844, 390),
      scale: 1.5,
      tv: false,
    ),
    (name: 'large-phone', size: const Size(480, 960), scale: 1.3, tv: false),
    (
      name: 'portrait-tablet',
      size: const Size(800, 1100),
      scale: 1.5,
      tv: false,
    ),
    (name: 'wide-tablet', size: const Size(1280, 800), scale: 1.0, tv: false),
    (name: 'compact-tv', size: const Size(960, 540), scale: 1.3, tv: true),
    (name: 'tv', size: const Size(1280, 720), scale: 1.0, tv: true),
    (
      name: 'tv-1080-large-text',
      size: const Size(1920, 1080),
      scale: 1.5,
      tv: true,
    ),
  ]) {
    testWidgets('${layout.name} content layouts tolerate titles and text scale', (
      tester,
    ) async {
      final controller = _fixture(tester, size: layout.size);
      controller.searchQuery = 'stories';
      controller.searchResults = controller.persisted.map(_result).toList();
      await tester.pumpWidget(
        _app(controller, tv: layout.tv, scale: layout.scale),
      );
      await tester.pumpAndSettle();
      for (final (tab, name) in [(0, 'home'), (2, 'library'), (1, 'search')]) {
        controller.selectTab(tab);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${layout.name} $name');
        final scroll = find
            .descendant(
              of: find.byType(CustomScrollView).first,
              matching: find.byType(Scrollable),
            )
            .first;
        await _capture(tester, '${layout.name}-$name');
        if (name == 'home') {
          await tester.scrollUntilVisible(
            find.byWidgetPredicate(
              (widget) =>
                  widget is StoryFeature &&
                  widget.item.media.id.value == 'story-${layout.tv ? 1 : 0}',
            ),
            160,
            scrollable: scroll,
          );
          expect(find.byType(StoryFeature), findsWidgets);
        } else {
          await tester.scrollUntilVisible(
            find.byKey(
              Key(
                name == 'library'
                    ? (layout.tv ? 'tv-library-story-0' : 'media-card-story-11')
                    : '${layout.tv ? 'tv-search' : 'search-result'}-local-story-0',
              ),
            ),
            160,
            scrollable: scroll,
          );
          expect(find.byType(StoryTile), findsWidgets);
          final built = tester.widgetList<StoryTile>(find.byType(StoryTile));
          expect(built.length, lessThan(20));
        }
        // Lay out another lazy viewport, including missing-art and long titles.
        await tester.drag(scroll, const Offset(0, -600));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${layout.name} $name scrolled',
        );
      }
      expect(
        (controller.repository as _VisualRepository).requests,
        isEmpty,
        reason: 'Painting selection surfaces must not request more metadata.',
      );
    });
  }

  testWidgets(
    'Home continue actions and Library shortcut preserve destinations and Back',
    (tester) async {
      final controller = _fixture(tester);
      final repository = controller.repository as _VisualRepository;
      await tester.pumpWidget(_app(controller));
      await tester.pumpAndSettle();
      expect(find.text('Continue reading'), findsOneWidget);
      expect(find.textContaining('Page 4'), findsOneWidget);
      for (final index in [0, 1]) {
        final action = find.byKey(Key('home-story-$index')).first;
        await tester.ensureVisible(action);
        await tester.pumpAndSettle();
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(repository.opened.last, CanonicalMediaId('story-$index'));
        expect(find.byKey(const Key('media-details')), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(find.text('View all'));
      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();
      expect(controller.selectedTab, 2);
      expect(
        find.byKey(const PageStorageKey('library-scroll')),
        findsOneWidget,
      );
      expect(controller.persisted.first.mangaProgress?.pageIndex, 3);
      expect(
        controller.persisted[1].animeProgress?.position,
        const Duration(minutes: 2),
      );
    },
  );

  testWidgets('Library filter, sort, state and selection remain functional', (
    tester,
  ) async {
    final controller = _fixture(tester);
    controller.selectedTab = 2;
    await tester.pumpWidget(_app(controller));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Favorites'));
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<StoryTile>(find.byType(StoryTile)).map((w) => w.title),
      ['Ashen Blade'],
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Anime'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<StoryTile>(find.byType(StoryTile))
          .every((w) => w.kind == CanonicalMediaKind.anime),
      isTrue,
    );
    await tester.tap(find.byTooltip('Sort library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title').last);
    await tester.pumpAndSettle();
    final titles = tester
        .widgetList<StoryTile>(find.byType(StoryTile))
        .map((w) => w.title)
        .toList();
    expect(titles.first, 'Nova Pulse');
    expect(find.text('Needs repair'), findsOneWidget);
    await tester.tap(find.byKey(const Key('media-card-story-1')));
    await tester.pumpAndSettle();
    expect(
      (controller.repository as _VisualRepository).opened.last,
      const CanonicalMediaId('story-1'),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Anime'))
          .selected,
      isTrue,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filter library status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('completed').last);
    await tester.pumpAndSettle();
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(
      controller.library.length,
      12,
      reason: 'Filtering never edits the saved collection.',
    );
  });

  for (final tv in [false, true]) {
    testWidgets(
      '${tv ? 'TV' : 'touch'} search loading, failure, retry, pagination and selections',
      (tester) async {
        final controller = _fixture(tester);
        final repository = controller.repository as _VisualRepository;
        controller.selectedTab = 1;
        await tester.pumpWidget(_app(controller, tv: tv));
        await tester.pumpAndSettle();
        expect(find.text('A title. A new beginning.'), findsOneWidget);
        final input = find.byKey(
          Key(tv ? 'tv-search-field' : 'product-search-field'),
        );
        await tester.enterText(input, 'stories');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pump();
        expect(repository.requests, hasLength(1));
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        expect(find.text('No results'), findsNothing);
        repository.requests.last.complete(
          ProductSearchResponse(
            results: [],
            failures: {const ProviderId('local'): 'Source offline'},
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(find.text('Source offline'), findsOneWidget);
        expect(find.text('No results'), findsNothing);
        await tester.ensureVisible(find.text('Retry search'));
        await tester.tap(find.text('Retry search'));
        await tester.pump();
        expect(repository.requests, hasLength(2));
        repository.requests.last.complete(
          const ProductSearchResponse(results: [], failures: {}),
        );
        await tester.pumpAndSettle();
        expect(find.text('No results'), findsOneWidget);

        final search = controller.submitSearch('stories');
        repository.requests.last.complete(
          ProductSearchResponse(
            results: controller.persisted.take(2).map(_result).toList(),
            failures: const {},
            nextCursors: {
              const ProviderId('local'): const PaginationCursor('next'),
            },
          ),
        );
        await search;
        await tester.pumpAndSettle();
        expect(find.text('No results'), findsNothing);
        for (final index in [0, 1]) {
          final tile = find.byKey(
            Key('${tv ? 'tv-search' : 'search-result'}-local-story-$index'),
          );
          await tester.ensureVisible(tile);
          await tester.pumpAndSettle();
          await tester.tap(tile);
          await tester.pumpAndSettle();
          expect(repository.opened.last, CanonicalMediaId('story-$index'));
          expect(
            find.byKey(Key(tv ? 'tv-media-details' : 'media-details')),
            findsOneWidget,
          );
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
        }
        final before = repository.requests.length;
        await tester.ensureVisible(find.text('Load more results'));
        await tester.pumpAndSettle();
        expect(
          repository.requests.length,
          before,
          reason: 'Scrolling does not fetch another page.',
        );
        await tester.tap(find.text('Load more results'));
        await tester.pump();
        expect(repository.requestCursors.last, {
          const ProviderId('local'): const PaginationCursor('next'),
        });
        repository.requests.last.complete(
          ProductSearchResponse(
            results: [_result(controller.persisted[2])],
            failures: const {},
          ),
        );
        await tester.pumpAndSettle();
        expect(controller.searchResults, hasLength(3));
        expect(find.text('Load more results'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'TV search grid traverses, activates and returns focus with D-pad',
    (tester) async {
      final controller = _fixture(tester);
      final repository = controller.repository as _VisualRepository;
      controller.selectedTab = 1;
      await tester.pumpWidget(_app(controller, tv: true));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('tv-search-field')),
        'stories',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      repository.requests.single.complete(
        ProductSearchResponse(
          results: controller.persisted.map(_result).toList(),
          failures: const {},
        ),
      );
      await tester.pumpAndSettle();
      expect(_focusKey(), const Key('tv-search-local-story-0'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(_focusKey(), const Key('tv-search-local-story-1'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      final destination = _focusKey();
      expect(destination, isNot(const Key('tv-search-local-story-1')));
      expect(destination, isNotNull);
      await _capture(tester, 'tv-search-focus');
      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tv-media-details')), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(_focusKey(), destination);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('TV Home and Library preserve activation and focus after Back', (
    tester,
  ) async {
    final controller = _fixture(tester);
    final repository = controller.repository as _VisualRepository;
    await tester.pumpWidget(_app(controller, tv: true));
    await tester.pumpAndSettle();
    expect(_focusKey(), const Key('tv-hero-action'));
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(repository.opened.last, const CanonicalMediaId('story-1'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_focusKey(), const Key('tv-hero-action'));
    controller.selectTab(2);
    await tester.pumpAndSettle();
    // Enter the first collection tile through the existing traversal policy.
    for (
      var index = 0;
      index < 16 && _focusKey() != const Key('tv-library-story-0');
      index++
    ) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
    }
    expect(_focusKey(), const Key('tv-library-story-0'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(_focusKey(), const Key('tv-library-story-1'));
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(repository.opened.last, const CanonicalMediaId('story-1'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_focusKey(), const Key('tv-library-story-1'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(_focusKey(), const Key('tv-library-story-0'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'empty Home action reaches Search without fetching extra metadata',
    (tester) async {
      final controller = _fixture(tester)..persisted = [];
      await tester.pumpWidget(_app(controller));
      await tester.pumpAndSettle();
      expect(find.text('Your library starts here'), findsOneWidget);
      await tester.tap(find.text('Find media'));
      await tester.pumpAndSettle();
      expect(controller.selectedTab, 1);
      expect(
        find.byKey(const Key('product-search-field')).hitTestable(),
        findsOneWidget,
      );
      expect((controller.repository as _VisualRepository).requests, isEmpty);
    },
  );

  for (final tv in [false, true]) {
    testWidgets(
      '${tv ? 'TV' : 'touch'} 1000-item collection builds only visible tiles',
      (tester) async {
        final controller = _fixture(tester, count: 1000);
        controller.selectedTab = 2;
        await tester.pumpWidget(_app(controller, tv: tv));
        await tester.pumpAndSettle();
        expect(find.text('1000 titles in this view'), findsOneWidget);
        expect(
          tester.widgetList<StoryTile>(find.byType(StoryTile)).length,
          lessThan(30),
        );
        final list = find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first;
        final scroll = tester.state<ScrollableState>(list).position;
        scroll.jumpTo(scroll.maxScrollExtent);
        await tester.pumpAndSettle();
        final lastId = tv ? 'story-999' : 'story-0';
        expect(
          find.byKey(Key('${tv ? 'tv-library' : 'media-card'}-$lastId')),
          findsOneWidget,
        );
        expect(
          tester.widgetList<StoryTile>(find.byType(StoryTile)).length,
          lessThan(30),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

const _captureKey = Key('content-capture');

Widget _app(
  ProductController controller, {
  bool tv = false,
  double scale = 1,
}) => RepaintBoundary(
  key: _captureKey,
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: zankaTheme(Brightness.dark),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: ProductShell(
      controller: controller,
      presentationMode: tv ? PresentationMode.tv : PresentationMode.mobile,
      developerBuilder: (_) => const SizedBox.shrink(),
      aboutBuilder: (_) => const SizedBox.shrink(),
      appearance: const AppPreferences(),
      onAppearanceChanged: (_, _) async {},
    ),
  ),
);

ProductController _fixture(
  WidgetTester tester, {
  Size size = const Size(1280, 900),
  int count = 12,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final live = LiveProviderRepository(
    database: CanonicalDatabase(NativeDatabase.memory()),
    registry: ProviderRegistry([]),
    transport: _NoNetwork(),
  );
  final repository = _VisualRepository(live, List.generate(count, _summary));
  final controller = ProductController(repository)
    ..persisted = repository.summaries
    ..loadingLocal = false
    ..loadingDiscover = false
    ..smartResumeTargets = {
      const CanonicalMediaId('story-0'): const SmartResumeTarget(
        action: SmartResumeAction.resumeReading,
      ),
      const CanonicalMediaId('story-1'): const SmartResumeTarget(
        action: SmartResumeAction.resumeEpisode,
      ),
    }
    ..discoverManga = repository.summaries
        .where((s) => s.media.kind == CanonicalMediaKind.manga)
        .take(6)
        .map(_result)
        .toList()
    ..discoverAnime = repository.summaries
        .where((s) => s.media.kind == CanonicalMediaKind.anime)
        .take(6)
        .map(_result)
        .toList();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await live.dispose();
  });
  return controller;
}

ProductMediaSummary _summary(int index) {
  final id = CanonicalMediaId('story-$index');
  final anime = index.isOdd;
  final now = DateTime.utc(2026, 9, 1).add(Duration(minutes: index));
  final title = SourcedValue(
    value: switch (index) {
      0 => 'Ashen Blade',
      1 => 'Nova Pulse',
      _ =>
        'Story ${index.toString().padLeft(4, '0')} — A very long title from a quiet world beyond the stars',
    },
    provenance: const FieldProvenance(providerId: ProviderId('local')),
  );
  final capture = const String.fromEnvironment(
    'ZANKA_VISUAL_CAPTURE_DIR',
  ).isNotEmpty;
  final cover = capture && index % 3 != 2
      ? File(
          'assets/showcase/${anime ? 'nova_pulse/poster' : 'ashen_blade/cover'}.png',
        ).absolute.path
      : null;
  return ProductMediaSummary(
    media: anime
        ? CanonicalAnime(
            id: id,
            title: title,
            format: AnimeFormat.ona,
            status: CanonicalMediaStatus.ongoing,
            coverLocator: cover,
          )
        : CanonicalManga(
            id: id,
            title: title,
            status: CanonicalMediaStatus.ongoing,
            coverLocator: cover,
          ),
    bindings: [
      MediaSourceBinding(
        canonicalId: id,
        providerId: const ProviderId('local'),
        externalId: id.value,
      ),
    ],
    library: CanonicalLibraryEntry(
      mediaId: id,
      isSaved: true,
      isFavorite: index == 0,
      status: index < 2
          ? CanonicalLibraryStatus.inProgress
          : CanonicalLibraryStatus.planned,
      createdAt: now,
      updatedAt: now,
    ),
    hasMissingLocalSource: index == 3,
    mangaProgress: index == 0
        ? CanonicalMangaProgress(
            mediaId: id,
            chapterId: const CanonicalChapterId('chapter'),
            pageIndex: 3,
            totalPages: 12,
            updatedAt: now,
          )
        : null,
    animeProgress: index == 1
        ? CanonicalAnimeProgress(
            mediaId: id,
            episodeId: const CanonicalEpisodeId('episode'),
            position: const Duration(minutes: 2),
            updatedAt: now,
          )
        : null,
    progressLabel: index == 0
        ? 'Chapter 1'
        : index == 1
        ? 'Episode 1'
        : null,
  );
}

ProductSearchResult _result(ProductMediaSummary s) => ProductSearchResult(
  title: s.media.title.value,
  kind: s.media.kind,
  canonicalId: s.media.id,
  persisted: s,
  coverUrl: s.media.coverLocator == null
      ? null
      : Uri.file(s.media.coverLocator!),
  sources: [
    ProviderListingItem(
      providerId: const ProviderId('local'),
      externalId: s.media.id.value,
      title: s.media.title.value,
      relativeLocator: '/metadata',
      mediaKind: s.media.kind,
    ),
  ],
);

class _VisualRepository extends ProductRepository {
  _VisualRepository(super.live, this.summaries);
  final List<ProductMediaSummary> summaries;
  final requests = <Completer<ProductSearchResponse>>[];
  final requestCursors = <Map<ProviderId, PaginationCursor>>[];
  final opened = <CanonicalMediaId>[];
  @override
  Future<List<ProductMediaSummary>> persisted() async => summaries;
  @override
  Future<SmartResumeTarget?> smartResume(CanonicalMediaId id) async =>
      id.value == 'story-0'
      ? const SmartResumeTarget(action: SmartResumeAction.resumeReading)
      : const SmartResumeTarget(action: SmartResumeAction.resumeEpisode);
  @override
  Future<ProductMediaDetails?> details(CanonicalMediaId id) async {
    opened.add(id);
    return ProductMediaDetails(
      summary: summaries.firstWhere((s) => s.media.id == id),
      chapters: const [],
      episodes: const [],
    );
  }

  @override
  Future<ProductMediaDetails> openSearchResult(
    ProductSearchResult result,
  ) async => (await details(result.canonicalId!))!;
  @override
  Future<ProductSearchResponse> search(
    String query, {
    Set<CanonicalMediaKind> kinds = const {
      CanonicalMediaKind.manga,
      CanonicalMediaKind.anime,
    },
    Map<ProviderId, PaginationCursor> cursors = const {},
  }) {
    requestCursors.add(cursors);
    final request = Completer<ProductSearchResponse>();
    requests.add(request);
    return request.future;
  }
}

class _NoNetwork implements ProviderTransport {
  @override
  Future<ProviderResponse> get(Uri uri) =>
      throw StateError('Selection UI must not fetch providers.');
  @override
  void close() {}
}

Key? _focusKey() {
  Key? key;
  FocusManager.instance.primaryFocus?.context?.visitAncestorElements((element) {
    if (element.widget is TvFocusable) {
      key = element.widget.key;
      return false;
    }
    return true;
  });
  return key;
}

// Opt-in render evidence uses only the project's original showcase artwork.
// No goldens, provider screenshots or machine-specific paths enter Git.
Future<void> _capture(WidgetTester tester, String name) async {
  const directory = String.fromEnvironment('ZANKA_VISUAL_CAPTURE_DIR');
  if (directory.isEmpty) return;
  // Let local-file decoding finish outside the test's fake clock, then paint.
  for (var pass = 0; pass < 12; pass++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();
  }
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_captureKey),
  );
  boundary.markNeedsPaint();
  await tester.pump();
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        '$directory/$name.png',
      ).writeAsBytes(data!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}
