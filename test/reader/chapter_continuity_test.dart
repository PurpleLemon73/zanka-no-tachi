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
      'natural backward ${direction.name} enters the previous final page without resume bleed',
      (tester) async {
        final fixture = await _fixture(
          tester,
          direction: direction,
          chapterCount: 3,
        );
        await tester.runAsync(() async {
          await fixture.seedResume(1, 2);
          await fixture.seedResume(2, 1);
          await fixture.seedResume(2, 2, provider: _alternate);
        });
        await fixture.pump(tester, chapter: 3);
        final viewport = find.byKey(const Key('paged-reader'));
        final controller = tester.widget<PageView>(viewport).controller!;
        expect(find.text('1 / 4 · Test source'), findsOneWidget);
        expect(fixture.source.calls, {_chapter(3): 1, _chapter(2): 1});
        await tester.runAsync(() async {
          expect(await fixture.database.mangaProgress(_media), isNull);
          expect(await fixture.repository.completedChapters(_media), isEmpty);
          expect(await fixture.resumePage(2), 1);
          expect(await fixture.resumePage(2, provider: _alternate), 2);
        });

        await _turnBackward(tester, direction);
        expect(find.text('Chapter 2'), findsWidgets);
        expect(find.text('4 / 4 · Test source'), findsOneWidget);
        expect(tester.widget<PageView>(viewport).controller, same(controller));
        expect(find.byType(MangaReaderScreen), findsOneWidget);
        await tester.runAsync(() async {
          expect(
            (await fixture.database.mangaProgress(_media))?.chapterId,
            _chapter(2),
          );
          expect(await fixture.resumePage(2), 3);
          expect(await fixture.resumePage(2, provider: _alternate), 2);
          expect(await fixture.resumePage(1), 2);
          expect(await fixture.repository.completedChapters(_media), {
            _chapter(2),
          });
        });
        await _turnForward(tester, direction);
        expect(find.text('Chapter 3'), findsWidgets);
        expect(find.text('1 / 4 · Test source'), findsOneWidget);
        await _turnBackward(tester, direction);
        expect(find.text('4 / 4 · Test source'), findsOneWidget);
        expect(fixture.source.calls, {_chapter(3): 1, _chapter(2): 1});
      },
    );

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
    'vertical previous preparation keeps its anchor and crosses upward naturally',
    (tester) async {
      final fixture = await _fixture(
        tester,
        mode: ReaderMode.vertical,
        chapterCount: 3,
      );
      final held = Completer<void>();
      fixture.source.holds[_chapter(1)] = held.future;
      await tester.runAsync(() => fixture.seedResume(1, 1));
      await fixture.pump(tester, chapter: 2);
      final viewport = find.byKey(const Key('vertical-reader'));
      final controller = tester.widget<ScrollView>(viewport).controller!;
      final firstPage = find.byKey(ValueKey((_chapter(2), 0)));
      final originalTop = tester.getTopLeft(firstPage).dy;
      held.complete();
      await _settle(tester);
      expect(tester.getTopLeft(firstPage).dy, closeTo(originalTop, 1));
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
      await tester.runAsync(() async {
        expect(await fixture.database.mangaProgress(_media), isNull);
        expect(await fixture.repository.completedChapters(_media), isEmpty);
        expect(await fixture.resumePage(1), 1);
      });
      await tester.drag(viewport, const Offset(0, 420));
      await _settle(tester);
      expect(find.text('Chapter 1'), findsWidgets);
      expect(find.text('4 / 4 · Test source'), findsOneWidget);
      expect(tester.widget<ScrollView>(viewport).controller, same(controller));
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
      await tester.drag(viewport, const Offset(0, -420));
      await _settle(tester);
      expect(find.text('Chapter 2'), findsWidgets);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
      expect(fixture.source.calls, {_chapter(2): 1, _chapter(1): 1});
    },
  );

  testWidgets(
    'failed previous preparation is non-destructive and explicitly retryable',
    (tester) async {
      final fixture = await _fixture(tester);
      fixture.source.failures[_chapter(1)] = 1;
      await fixture.pump(tester, chapter: 2);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
      await _turnBackward(tester, ReaderDirection.leftToRight);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
      expect(fixture.source.calls[_chapter(1)], 1);
      await tester.runAsync(() async {
        expect(await fixture.resumePage(1), isNull);
        expect(await fixture.repository.completedChapters(_media), isEmpty);
      });
      await tester.tap(
        find.byKey(const Key('reader-previous-continuation-retry')),
      );
      await _settle(tester);
      await _turnBackward(tester, ReaderDirection.leftToRight);
      expect(find.text('Chapter 1'), findsWidgets);
      expect(find.text('4 / 4 · Test source'), findsOneWidget);
      expect(fixture.source.calls[_chapter(1)], 2);
    },
  );

  testWidgets(
    'stale previous preparation cannot enter a newer picker session',
    (tester) async {
      final fixture = await _fixture(tester, chapterCount: 4);
      final held = Completer<void>();
      fixture.source.holds[_chapter(1)] = held.future;
      await fixture.pump(tester, chapter: 2);
      await tester.tap(find.byKey(const Key('chapter-picker')));
      await _settle(tester);
      await tester.tap(find.byKey(Key('chapter-picker-${_chapter(4).value}')));
      await _settle(tester);
      held.complete();
      await _settle(tester);
      expect(find.text('Chapter 4'), findsWidgets);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
      await _turnBackward(tester, ReaderDirection.leftToRight);
      expect(find.text('Chapter 3'), findsWidgets);
      expect(find.text('4 / 4 · Test source'), findsOneWidget);
      await tester.runAsync(() async {
        expect(await fixture.resumePage(1), isNull);
        expect(
          await fixture.repository.completedChapters(_media),
          isNot(contains(_chapter(1))),
        );
      });
    },
  );

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

      // Move the previous chapter wholly offscreen. It remains a lazy neighbor
      // for backward continuity; neither its retention nor trimming may move
      // the visible anchor.
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
      expect(tester.widget<CustomScrollView>(viewport).slivers.length, 4);
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
      expect(
        find.text('Chapter $chapter'),
        findsWidgets,
        reason:
            'turn $turn, absolute ${controller.page}, counter ${tester.widget<Text>(find.byKey(const Key('reader-counter'))).data}',
      );
      expect(find.text('${page + 1} / 4 · Test source'), findsOneWidget);
      expect(tester.widget<PageView>(viewport).controller, same(controller));
      // Absolute indices now include the retained previous chapter. The
      // visible counter must still be chapter-local, with at most 3 manifests.
      expect(
        controller.page,
        closeTo((page + (chapter > 1 ? 4 : 0)).toDouble(), 0.001),
      );
      expect(
        tester.widget<PageView>(viewport).childrenDelegate.estimatedChildCount,
        lessThanOrEqualTo(12),
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
    'paged window rolls backward and forward without accumulating chapters',
    (tester) async {
      final fixture = await _fixture(
        tester,
        chapterCount: 6,
        direction: ReaderDirection.rightToLeft,
      );
      await fixture.pump(tester, chapter: 5);
      final viewport = find.byKey(const Key('paged-reader'));
      final controller = tester.widget<PageView>(viewport).controller!;
      for (var step = 1; step <= 16; step++) {
        await _turnBackward(tester, ReaderDirection.rightToLeft);
        final position = 16 - step;
        expect(find.text('Chapter ${position ~/ 4 + 1}'), findsWidgets);
        expect(
          find.text('${position % 4 + 1} / 4 · Test source'),
          findsOneWidget,
        );
        expect(tester.widget<PageView>(viewport).controller, same(controller));
        expect(
          tester
              .widget<PageView>(viewport)
              .childrenDelegate
              .estimatedChildCount,
          lessThanOrEqualTo(12),
        );
        expect(find.byType(Image).evaluate().length, lessThan(8));
      }
      await _turnBackward(tester, ReaderDirection.rightToLeft);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
      for (var step = 1; step <= 16; step++) {
        await _turnForward(tester, ReaderDirection.rightToLeft);
        expect(find.text('Chapter ${step ~/ 4 + 1}'), findsWidgets);
        expect(find.text('${step % 4 + 1} / 4 · Test source'), findsOneWidget);
        expect(
          tester
              .widget<PageView>(viewport)
              .childrenDelegate
              .estimatedChildCount,
          lessThanOrEqualTo(12),
        );
      }
      expect(fixture.source.calls.containsKey(_chapter(6)), isFalse);
      await tester.runAsync(() async {
        expect(
          (await fixture.database.mangaProgress(_media))?.chapterId,
          _chapter(5),
        );
        expect(await fixture.resumePage(5), 0);
      });
    },
  );

  testWidgets(
    'vertical window rolls its origin in both directions without moving the reading anchor',
    (tester) async {
      final fixture = await _fixture(
        tester,
        mode: ReaderMode.vertical,
        chapterCount: 5,
      );
      await fixture.pump(tester, chapter: 4);
      final viewport = find.byKey(const Key('vertical-reader'));
      final controller = tester.widget<ScrollView>(viewport).controller!;
      var active = 4;
      for (var step = 0; step < 60 && active > 1; step++) {
        await tester.drag(viewport, const Offset(0, 420));
        await tester.pump();
        // The warmed last page is a stable anchor during a chapter transition,
        // even when the old origin falls outside the three-chapter window.
        final previousLast = find.byKey(ValueKey((_chapter(active - 1), 3)));
        final before = previousLast.evaluate().isEmpty
            ? null
            : tester.getTopLeft(previousLast).dy;
        await _settle(tester, attempts: 4);
        expect(
          tester.widget<ScrollView>(viewport).controller,
          same(controller),
        );
        expect(
          tester.widget<CustomScrollView>(viewport).slivers.length,
          lessThanOrEqualTo(6),
        );
        final progress = await tester.runAsync(
          () => fixture.database.mangaProgress(_media),
        );
        if (progress?.chapterId == _chapter(active - 1)) {
          if (before != null && previousLast.evaluate().isNotEmpty) {
            expect(tester.getTopLeft(previousLast).dy, closeTo(before, 1));
          }
          active--;
          expect(find.text('4 / 4 · Test source'), findsOneWidget);
        }
      }
      expect(active, 1);
      for (var step = 0; step < 65 && active < 4; step++) {
        await tester.drag(viewport, const Offset(0, -420));
        await _settle(tester, attempts: 4);
        expect(
          tester.widget<ScrollView>(viewport).controller,
          same(controller),
        );
        expect(
          tester.widget<CustomScrollView>(viewport).slivers.length,
          lessThanOrEqualTo(6),
        );
        final progress = await tester.runAsync(
          () => fixture.database.mangaProgress(_media),
        );
        if (progress?.chapterId == _chapter(active + 1)) {
          active++;
          expect(find.text('1 / 4 · Test source'), findsOneWidget);
        }
      }
      expect(active, 4);
      expect(fixture.source.calls.containsKey(_chapter(5)), isFalse);
    },
  );

  testWidgets(
    '1002 chapters opened in the middle prepare only immediate neighbors',
    (tester) async {
      final fixture = await _fixture(tester, chapterCount: 1002);
      await tester.runAsync(() async {
        await fixture.seedResume(500, 1);
        await fixture.seedResume(502, 2);
      });
      await fixture.pump(tester, chapter: 501, attempts: 30);
      expect(fixture.source.calls, {_chapter(501): 1, _chapter(500): 1});
      expect(
        fixture.source.loadedPages.where(
          (page) => page.startsWith('${_chapter(500).value}-'),
        ),
        ['${_chapter(500).value}-3'],
        reason:
            'Only the previous chapter entry image is warmed, not all pages.',
      );
      await tester.runAsync(() async {
        expect(await fixture.database.mangaProgress(_media), isNull);
        expect(await fixture.resumePage(500), 1);
      });
      final controller = tester
          .widget<PageView>(find.byKey(const Key('paged-reader')))
          .controller!;
      controller.jumpToPage(
        6,
      ); // Previous chapter's four pages + active page 3.
      await _settle(tester, attempts: 20);
      expect(fixture.source.calls, {
        _chapter(501): 1,
        _chapter(500): 1,
        _chapter(502): 1,
      });
      expect(fixture.source.loadedPages.length, lessThanOrEqualTo(8));
      expect(
        tester
            .widget<PageView>(find.byKey(const Key('paged-reader')))
            .childrenDelegate
            .estimatedChildCount,
        12,
      );
      expect(find.byType(Image).evaluate().length, lessThan(8));
      await tester.runAsync(() async {
        expect(await fixture.resumePage(500), 1);
        expect(await fixture.resumePage(502), 2);
        expect(await fixture.repository.completedChapters(_media), isEmpty);
      });
    },
  );

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

  testWidgets(
    'unreadable previous chapter is not skipped and late preparation is harmless after disposal',
    (tester) async {
      final fixture = await _fixture(tester, chapterCount: 4, unavailable: {2});
      await fixture.pump(tester, chapter: 3);
      await _turnBackward(tester, ReaderDirection.leftToRight);
      expect(find.text('Chapter 3'), findsWidgets);
      expect(find.text('1 / 4 · Test source'), findsOneWidget);
      expect(fixture.source.calls, {_chapter(3): 1});

      // Open chapter 4 normally, holding its readable previous manifest until
      // after the route is disposed. Only active positions may be flushed.
      final held = Completer<void>();
      fixture.source.holds[_chapter(3)] = held.future;
      await tester.tap(find.byKey(const Key('chapter-picker')));
      await _settle(tester);
      await tester.tap(find.byKey(Key('chapter-picker-${_chapter(4).value}')));
      await _settle(tester);
      expect(fixture.source.calls[_chapter(3)], 2);
      await tester.pumpWidget(const SizedBox.shrink());
      await _settle(tester);
      held.complete();
      await _settle(tester);
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        expect(
          (await fixture.database.mangaProgress(_media))?.chapterId,
          _chapter(4),
        );
        expect(await fixture.resumePage(3), 0);
        expect(await fixture.resumePage(2), isNull);
        expect(await fixture.repository.completedChapters(_media), isEmpty);
      });
    },
  );

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

Future<void> _turnBackward(
  WidgetTester tester,
  ReaderDirection direction,
) async {
  await tester.fling(
    find.byKey(const Key('paged-reader')),
    Offset(direction == ReaderDirection.leftToRight ? 600 : -600, 0),
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

  Future<void> pump(
    WidgetTester tester, {
    int attempts = 10,
    int chapter = 1,
  }) async {
    final request = ReaderSessionRequest(
      mediaId: _media,
      chapterId: _chapter(chapter),
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
