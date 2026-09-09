import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/reader/reader_domain.dart';
import 'package:zanka_no_tachi/reader/reader_preferences_store.dart';
import 'package:zanka_no_tachi/reader/reader_repository.dart';
import 'package:zanka_no_tachi/reader/reader_source.dart';
import 'package:zanka_no_tachi/reader/ui/manga_reader_screen.dart';

const _media = CanonicalMediaId('continuity-manga');
const _primary = ProviderId('continuity-primary');
const _alternate = ProviderId('continuity-alternate');

CanonicalChapterId _chapter(int number) =>
    CanonicalChapterId('continuity-chapter-$number');

void main() {
  for (final direction in ReaderDirection.values) {
    testWidgets(
      'natural paged ${direction.name} continuation preserves isolated resumes and completion',
      (tester) async {
        final fixture = await _fixture(tester, direction: direction);
        await tester.runAsync(() async {
          await fixture.seedResume(2, 2);
          await fixture.seedResume(2, 1, provider: _alternate);
        });
        await fixture.pump(tester);
        final controller = tester
            .widget<PageView>(find.byKey(const Key('paged-reader')))
            .controller!;
        controller.jumpToPage(2);
        await _settle(tester);

        expect(fixture.source.calls[_chapter(2)], 1);
        expect(find.text('3 / 4 · Test source'), findsOneWidget);
        await tester.runAsync(() async {
          expect(await fixture.repository.completedChapters(_media), isEmpty);
          expect(await fixture.resumePage(2), 2);
          expect(await fixture.resumePage(2, provider: _alternate), 1);
        });

        await _turnForward(tester, direction);
        expect(find.text('4 / 4 · Test source'), findsOneWidget);
        await tester.runAsync(() async {
          expect(await fixture.repository.completedChapters(_media), {
            _chapter(1),
          });
          expect(await fixture.resumePage(2), 2);
        });

        await _turnForward(tester, direction);
        expect(find.text('Chapter 2'), findsWidgets);
        expect(find.text('1 / 4 · Test source'), findsOneWidget);
        expect(find.byType(MangaReaderScreen), findsOneWidget);
        await tester.runAsync(() async {
          expect(await fixture.resumePage(1), 3);
          expect(await fixture.resumePage(2, provider: _alternate), 1);
          expect(await fixture.repository.completedChapters(_media), {
            _chapter(1),
          });
        });

        await _turnForward(tester, direction);
        expect(
          tester.widget<Text>(find.byKey(const Key('reader-counter'))).data,
          '2 / 4 · Test source',
          reason:
              'Viewport page after crossing: ${tester.widget<PageView>(find.byKey(const Key('paged-reader'))).controller!.page}',
        );
        await tester.runAsync(() async {
          final progress = await fixture.database.mangaProgress(_media);
          expect(progress?.chapterId, _chapter(2));
          expect(progress?.pageIndex, 1);
          expect(await fixture.resumePage(2), 1);
          expect(await fixture.resumePage(2, provider: _alternate), 1);
        });
      },
    );
  }

  testWidgets(
    'vertical scrolling crosses a genuine chapter boundary without replacing the viewport',
    (tester) async {
      final fixture = await _fixture(tester, mode: ReaderMode.vertical);
      await tester.runAsync(() => fixture.seedResume(2, 2));
      await fixture.pump(tester);
      expect(find.text('Volume 1'), findsOneWidget);
      final viewport = find.byKey(const Key('vertical-reader'));
      final controller = tester.widget<ScrollView>(viewport).controller!;
      var boundarySeen = false;
      for (var step = 0; step < 24; step++) {
        await tester.drag(viewport, const Offset(0, -420));
        await tester.pump();
        final preparedFirstPage = find.byKey(ValueKey((_chapter(2), 0)));
        final beforeIdle = preparedFirstPage.evaluate().isEmpty
            ? null
            : tester.getTopLeft(preparedFirstPage).dy;
        await _settle(tester, attempts: 4);
        expect(find.byType(MangaReaderScreen), findsOneWidget);
        expect(
          tester.widget<ScrollView>(viewport).controller,
          same(controller),
        );
        if (beforeIdle != null && preparedFirstPage.evaluate().isNotEmpty) {
          expect(
            tester.getTopLeft(preparedFirstPage).dy,
            closeTo(beforeIdle, 1),
            reason:
                'Dropping an offscreen chapter must preserve the visible anchor.',
          );
        }
        boundarySeen |= find
            .byKey(const Key('reader-chapter-boundary'))
            .evaluate()
            .isNotEmpty;
        final progress = await tester.runAsync(
          () => fixture.database.mangaProgress(_media),
        );
        if (progress?.chapterId == _chapter(2)) break;
        await tester.runAsync(() async {
          expect(await fixture.resumePage(2), 2);
          expect(
            await fixture.repository.completedChapters(_media),
            isNot(contains(_chapter(2))),
          );
        });
      }
      expect(boundarySeen, isTrue);
      expect(find.text('Chapter 2'), findsWidgets);
      expect(find.text('Volume 2'), findsOneWidget);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
      expect(fixture.source.calls[_chapter(2)], 1);
      await tester.runAsync(() async {
        expect(await fixture.repository.completedChapters(_media), {
          _chapter(1),
        });
        expect(
          (await fixture.database.mangaProgress(_media))?.chapterId,
          _chapter(2),
        );
      });
      expect(find.byKey(const Key('chapter-picker')), findsOneWidget);
      expect(find.byKey(const Key('previous-chapter')), findsOneWidget);

      // Move the previous chapter wholly offscreen, then let the rolling
      // window discard it. The visual anchor, not the rebased raw offset,
      // must stay fixed through the layout correction.
      final firstPage = find.byKey(ValueKey((_chapter(2), 0)));
      controller.jumpTo(
        controller.offset +
            tester.getTopLeft(firstPage).dy -
            tester.getTopLeft(viewport).dy +
            40,
      );
      await tester.pump();
      final anchorBeforeTrim = tester.getTopLeft(firstPage).dy;
      await _settle(tester);
      expect(tester.getTopLeft(firstPage).dy, closeTo(anchorBeforeTrim, 1));
      expect(find.byType(SliverList), findsOneWidget);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
    },
  );

  testWidgets('paged window stays bounded across repeated chapter crossings', (
    tester,
  ) async {
    final fixture = await _fixture(tester, chapterCount: 3);
    await tester.runAsync(() => fixture.seedResume(3, 2));
    await fixture.pump(tester);
    final viewport = find.byKey(const Key('paged-reader'));
    final controller = tester.widget<PageView>(viewport).controller!;
    for (var turn = 1; turn <= 9; turn++) {
      await _turnForward(tester, ReaderDirection.leftToRight);
      final chapter = turn ~/ 4 + 1;
      final page = turn % 4;
      expect(find.text('Chapter $chapter'), findsWidgets);
      expect(find.text('${page + 1} / 4 · Test source'), findsOneWidget);
      expect(tester.widget<PageView>(viewport).controller, same(controller));
      expect(controller.page, closeTo(page.toDouble(), 0.001));
      expect(
        tester.widget<PageView>(viewport).childrenDelegate.estimatedChildCount,
        lessThanOrEqualTo(8),
      );
      if (chapter < 3) {
        await tester.runAsync(() async {
          expect(await fixture.resumePage(3), 2);
        });
      }
    }
    expect(fixture.source.calls, {
      _chapter(1): 1,
      _chapter(2): 1,
      _chapter(3): 1,
    });
    await tester.runAsync(() async {
      expect(await fixture.repository.completedChapters(_media), {
        _chapter(1),
        _chapter(2),
      });
      expect(
        (await fixture.database.mangaProgress(_media))?.chapterId,
        _chapter(3),
      );
      expect(await fixture.resumePage(3), 1);
    });
  });

  testWidgets(
    'vertical boundary can be crossed back before the old chapter leaves view',
    (tester) async {
      final fixture = await _fixture(tester, mode: ReaderMode.vertical);
      await fixture.pump(tester);
      final viewport = find.byKey(const Key('vertical-reader'));
      final controller = tester.widget<ScrollView>(viewport).controller!;
      final destinationFirstPage = find.byKey(ValueKey((_chapter(2), 0)));
      for (
        var step = 0;
        step < 32 && destinationFirstPage.evaluate().isEmpty;
        step++
      ) {
        await tester.drag(viewport, const Offset(0, -220));
        await _settle(tester, attempts: 3);
      }
      expect(destinationFirstPage, findsOneWidget);
      final line = tester.getCenter(viewport).dy;
      final top = tester.getTopLeft(destinationFirstPage).dy;
      controller.jumpTo(controller.offset + top - line + 20);
      await _settle(tester);
      expect(find.text('Chapter 2'), findsWidgets);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);

      await tester.drag(viewport, const Offset(0, 180));
      await _settle(tester);
      expect(find.text('Chapter 1'), findsOneWidget);
      expect(find.text('4 / 4 · Test source'), findsOneWidget);
      expect(fixture.source.calls, {_chapter(1): 1, _chapter(2): 1});
      await tester.runAsync(() async {
        expect(
          (await fixture.database.mangaProgress(_media))?.chapterId,
          _chapter(1),
        );
        expect(await fixture.resumePage(1), 3);
        expect(await fixture.repository.completedChapters(_media), {
          _chapter(1),
        });
      });
    },
  );

  testWidgets('an unreadable canonical neighbor is not skipped or resolved', (
    tester,
  ) async {
    final fixture = await _fixture(tester, chapterCount: 3, unavailable: {2});
    await fixture.pump(tester);
    tester
        .widget<PageView>(find.byKey(const Key('paged-reader')))
        .controller!
        .jumpToPage(3);
    await _settle(tester);
    await _turnForward(tester, ReaderDirection.leftToRight);
    expect(find.text('4 / 4 · Test source'), findsOneWidget);
    expect(fixture.source.calls.keys, [_chapter(1)]);
    expect(find.byKey(const Key('reader-continuation-retry')), findsNothing);
    await tester.tap(find.byKey(const Key('next-chapter')));
    await _settle(tester);
    expect(
      find.text('The adjacent chapter has no readable source configured.'),
      findsOneWidget,
    );
    expect(find.text('4 / 4 · Test source'), findsOneWidget);
    expect(find.byKey(const Key('chapter-picker')), findsOneWidget);
  });

  testWidgets('the last canonical chapter has no phantom continuation', (
    tester,
  ) async {
    final fixture = await _fixture(tester, chapterCount: 1);
    await fixture.pump(tester);
    tester
        .widget<PageView>(find.byKey(const Key('paged-reader')))
        .controller!
        .jumpToPage(3);
    await _settle(tester);
    for (var attempt = 0; attempt < 3; attempt++) {
      await _turnForward(tester, ReaderDirection.leftToRight);
    }
    expect(find.text('4 / 4 · Test source'), findsOneWidget);
    expect(find.text('End of available chapters'), findsWidgets);
    expect(fixture.source.calls, {_chapter(1): 1});
    expect(find.byKey(const Key('reader-continuation-retry')), findsNothing);
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('next-chapter')))
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'failed preparation leaves the current chapter usable and retries only on request',
    (tester) async {
      final fixture = await _fixture(tester);
      fixture.source.failures[_chapter(2)] = 1;
      await fixture.pump(tester);
      final controller = tester
          .widget<PageView>(find.byKey(const Key('paged-reader')))
          .controller!;
      controller.jumpToPage(3);
      await _settle(tester);
      expect(find.text('4 / 4 · Test source'), findsOneWidget);
      expect(fixture.source.calls[_chapter(2)], 1);
      expect(
        find.byKey(const Key('reader-continuation-retry')),
        findsOneWidget,
      );
      await _turnForward(tester, ReaderDirection.leftToRight);
      await _settle(tester, attempts: 20);
      expect(fixture.source.calls[_chapter(2)], 1);
      expect(find.text('4 / 4 · Test source'), findsOneWidget);

      await tester.tap(find.byKey(const Key('reader-continuation-retry')));
      await _settle(tester);
      expect(fixture.source.calls[_chapter(2)], 2);
      await _turnForward(tester, ReaderDirection.leftToRight);
      expect(find.text('Chapter 2'), findsWidgets);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
    },
  );

  testWidgets('late prepared chapter cannot replace a picker destination', (
    tester,
  ) async {
    final fixture = await _fixture(tester, chapterCount: 3);
    final pending = Completer<void>();
    fixture.source.holds[_chapter(2)] = pending.future;
    await fixture.pump(tester);
    tester
        .widget<PageView>(find.byKey(const Key('paged-reader')))
        .controller!
        .jumpToPage(2);
    await _settle(tester);
    expect(fixture.source.calls[_chapter(2)], 1);
    await tester.tap(find.byKey(const Key('chapter-picker')));
    await _settle(tester);
    await tester.tap(find.byKey(Key('chapter-picker-${_chapter(3).value}')));
    await _settle(tester);
    expect(find.text('Chapter 3'), findsWidgets);
    pending.complete();
    await _settle(tester);
    expect(find.text('Chapter 3'), findsWidgets);
    expect(find.text('1 / 4 · Test source'), findsOneWidget);
    await tester.runAsync(() async {
      expect(await fixture.resumePage(2), isNull);
      expect(
        await fixture.repository.completedChapters(_media),
        isNot(contains(_chapter(2))),
      );
    });
  });

  testWidgets(
    '1002 chapters prepare only the next manifest and a small image window',
    (tester) async {
      final fixture = await _fixture(tester, chapterCount: 1002);
      await fixture.pump(tester, attempts: 30);
      tester
          .widget<PageView>(find.byKey(const Key('paged-reader')))
          .controller!
          .jumpToPage(2);
      await _settle(tester, attempts: 20);
      expect(fixture.source.calls, {_chapter(1): 1, _chapter(2): 1});
      expect(fixture.source.loadedPages.length, lessThanOrEqualTo(7));
      expect(find.byType(Image).evaluate().length, lessThan(8));
      expect(find.text('Chapter 1002'), findsNothing);
      await tester.tap(find.byKey(const Key('chapter-picker')));
      await _settle(tester);
      expect(find.text('Chapter 1002'), findsNothing);
      expect(find.byType(ListTile).evaluate().length, lessThan(40));
      expect(fixture.source.calls.length, 2);
    },
  );
}

Future<_ContinuityFixture> _fixture(
  WidgetTester tester, {
  ReaderMode mode = ReaderMode.paged,
  ReaderDirection direction = ReaderDirection.leftToRight,
  int chapterCount = 2,
  Set<int> unavailable = const {},
}) async {
  final fixture = (await tester.runAsync(
    () => _ContinuityFixture.create(
      mode: mode,
      direction: direction,
      chapterCount: chapterCount,
      unavailable: unavailable,
    ),
  ))!;
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await _settle(tester, attempts: 3);
    await tester.runAsync(() async {
      await fixture.database.close();
      await fixture.temp.delete(recursive: true);
    });
  });
  return fixture;
}

Future<void> _settle(WidgetTester tester, {int attempts = 10}) async {
  for (var index = 0; index < attempts; index++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 12)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _turnForward(
  WidgetTester tester,
  ReaderDirection direction,
) async {
  await tester.fling(
    find.byKey(const Key('paged-reader')),
    Offset(direction == ReaderDirection.leftToRight ? -600 : 600, 0),
    1200,
  );
  await _settle(tester);
}

class _ContinuityFixture {
  const _ContinuityFixture(
    this.temp,
    this.database,
    this.repository,
    this.source,
  );
  final Directory temp;
  final CanonicalDatabase database;
  final ReaderRepository repository;
  final _CountingResolver source;

  static Future<_ContinuityFixture> create({
    required ReaderMode mode,
    required ReaderDirection direction,
    required int chapterCount,
    required Set<int> unavailable,
  }) async {
    final temp = await Directory.systemTemp.createTemp('zanka-continuity-');
    final database = CanonicalDatabase(NativeDatabase.memory());
    final source = _CountingResolver(_primary);
    final preferences = ReaderPreferencesStore(
      file: File('${temp.path}/preferences.json'),
    );
    await preferences.save(ReaderPreferences(mode: mode, direction: direction));
    await database.transaction(() async {
      await database.saveMedia(
        const CanonicalManga(
          id: _media,
          title: SourcedValue(
            value: 'Synthetic chapter continuity',
            provenance: FieldProvenance(providerId: _primary),
          ),
        ),
      );
      for (final provider in [_primary, _alternate]) {
        await database.saveMediaBinding(
          MediaSourceBinding(
            canonicalId: _media,
            providerId: provider,
            externalId: 'synthetic-media',
          ),
        );
      }
      for (var number = 1; number <= chapterCount; number++) {
        await database.saveChapter(
          CanonicalChapter(
            id: _chapter(number),
            mediaId: _media,
            number: ChapterNumber.parse('Chapter $number'),
            volumeLabel: number == 1 ? 'Volume 1' : 'Volume 2',
          ),
        );
        await database.saveChapterBinding(
          ChapterSourceBinding(
            canonicalId: _chapter(number),
            providerId: unavailable.contains(number)
                ? const ProviderId('metadata-only')
                : _primary,
            externalId: 'chapter-$number',
          ),
        );
      }
      if (chapterCount >= 2 && !unavailable.contains(2)) {
        await database.saveChapterBinding(
          ChapterSourceBinding(
            canonicalId: _chapter(2),
            providerId: _alternate,
            externalId: 'chapter-2',
          ),
        );
      }
      await database.setPreferredProvider(_media, _primary);
    });
    return _ContinuityFixture(
      temp,
      database,
      ReaderRepository(
        database: database,
        sources: ReaderSourceRegistry([source, _CountingResolver(_alternate)]),
        preferencesStore: preferences,
      ),
      source,
    );
  }

  Future<void> pump(WidgetTester tester, {int attempts = 10}) async {
    final request = ReaderSessionRequest(
      mediaId: _media,
      chapterId: _chapter(1),
    );
    final initial = (await tester.runAsync(() => repository.open(request)))!;
    await tester.pumpWidget(
      MaterialApp(
        home: MangaReaderScreen(
          repository: repository,
          request: request,
          initialSession: initial,
        ),
      ),
    );
    await _settle(tester, attempts: attempts);
  }

  Future<void> seedResume(
    int chapter,
    int page, {
    ProviderId provider = _primary,
  }) => database.saveMangaSourcePageResume(
    MangaSourcePageResume(
      mediaId: _media,
      chapterId: _chapter(chapter),
      providerId: provider,
      chapterExternalId: 'chapter-$chapter',
      pageIndex: page,
      totalPages: 4,
      updatedAt: DateTime.utc(2026),
    ),
  );

  Future<int?> resumePage(
    int chapter, {
    ProviderId provider = _primary,
  }) async => (await database.mangaSourcePageResume(
    provider,
    'chapter-$chapter',
  ))?.pageIndex;
}

class _CountingResolver implements ReaderSourceResolver {
  _CountingResolver(this.providerId);

  @override
  final ProviderId providerId;
  final Map<CanonicalChapterId, int> calls = {};
  final Map<CanonicalChapterId, int> failures = {};
  final Map<CanonicalChapterId, Future<void>> holds = {};
  final Set<String> loadedPages = {};
  final Uint8List image = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

  @override
  ReaderSourceCapability capability(ChapterSourceBinding binding) =>
      ReaderSourceCapability.readerCapable;

  @override
  Future<ReaderManifest> resolve(ReaderSessionRequest request) async {
    calls.update(request.chapterId, (count) => count + 1, ifAbsent: () => 1);
    await holds[request.chapterId];
    final failuresLeft = failures[request.chapterId] ?? 0;
    if (failuresLeft > 0) {
      failures[request.chapterId] = failuresLeft - 1;
      throw const ReaderException(
        ReaderErrorKind.sourceUnavailable,
        'The test chapter is temporarily unavailable.',
      );
    }
    return ReaderManifest(
      sourceName: 'Test source',
      binding: request.binding!,
      pages: [
        for (var page = 0; page < 4; page++)
          ReaderPage(
            id: '${providerId.value}-${request.chapterId.value}-$page',
            index: page,
            displayLocator: 'Synthetic page ${page + 1}',
            width: 400,
            height: 600,
            loadBytes: () async {
              loadedPages.add('${request.chapterId.value}-$page');
              return image;
            },
          ),
      ],
    );
  }
}
