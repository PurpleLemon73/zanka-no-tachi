import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/product_maturity/maturity_domain.dart';
import 'package:zanka_no_tachi/reader/local_reader_sources.dart';
import 'package:zanka_no_tachi/reader/reader_domain.dart';
import 'package:zanka_no_tachi/reader/reader_preferences_store.dart';
import 'package:zanka_no_tachi/reader/reader_repository.dart';
import 'package:zanka_no_tachi/reader/reader_source.dart';
import 'package:zanka_no_tachi/reader/sample_manga_installer.dart';
import 'package:zanka_no_tachi/reader/ui/manga_reader_screen.dart';

void main() {
  testWidgets(
    'reader pages, persists, switches modes and never maps position to another scan',
    (tester) async {
      late Directory temp;
      late CanonicalDatabase database;
      late ReaderPreferencesStore preferences;
      await tester.runAsync(() async {
        temp = await Directory.systemTemp.createTemp('zanka-reader-widget-');
        database = CanonicalDatabase(NativeDatabase.memory());
        await SampleMangaInstaller(
          database,
          root: Directory('${temp.path}/sample'),
        ).install();
        preferences = ReaderPreferencesStore(
          file: File('${temp.path}/settings.json'),
        );
        await preferences.save(const ReaderPreferences(mode: ReaderMode.paged));
      });
      final repository = ReaderRepository(
        database: database,
        sources: ReaderSourceRegistry(const [
          LocalFolderReaderSource(),
          LocalFolderReaderSource(
            id: localFolderAlternateProviderId,
            displayName: 'Local folder alternate',
          ),
          LocalCbzReaderSource(),
        ]),
        preferencesStore: preferences,
      );
      late ReaderSession initialSession;
      await tester.runAsync(() async {
        initialSession = await repository.open(
          const ReaderSessionRequest(
            mediaId: sampleMangaId,
            chapterId: sampleChapterOneId,
            binding: ChapterSourceBinding(
              canonicalId: sampleChapterOneId,
              providerId: localFolderProviderId,
              externalId: 'sample-folder-chapter-1',
            ),
          ),
        );
      });
      Future<void> settleIo() async {
        for (var index = 0; index < 5; index++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 100)),
          );
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      await tester.pumpWidget(
        MaterialApp(
          home: MangaReaderScreen(
            repository: repository,
            initialSession: initialSession,
            request: const ReaderSessionRequest(
              mediaId: sampleMangaId,
              chapterId: sampleChapterOneId,
              binding: ChapterSourceBinding(
                canonicalId: sampleChapterOneId,
                providerId: localFolderProviderId,
                externalId: 'sample-folder-chapter-1',
              ),
            ),
          ),
        ),
      );
      await settleIo();
      expect(find.byKey(const Key('paged-reader')), findsOneWidget);
      expect(find.text('1 / 4 · Local folder'), findsOneWidget);

      final zoomSurface = find.byKey(const Key('paged-zoom-surface')).first;
      final center = tester.getCenter(zoomSurface);
      final firstFinger = await tester.startGesture(
        center - const Offset(24, 0),
        pointer: 1,
      );
      final secondFinger = await tester.startGesture(
        center + const Offset(24, 0),
        pointer: 2,
      );
      await firstFinger.moveBy(const Offset(-80, 0));
      await secondFinger.moveBy(const Offset(80, 0));
      await firstFinger.up();
      await secondFinger.up();
      await tester.pump();
      await tester.fling(
        find.byKey(const Key('paged-reader')),
        const Offset(-500, 0),
        1200,
      );
      await tester.pumpAndSettle();
      expect(find.text('1 / 4 · Local folder'), findsOneWidget);
      await tester.tap(find.byKey(const Key('reset-page-zoom')));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byKey(const Key('paged-reader')),
        const Offset(-500, 0),
        1200,
      );
      await settleIo();
      expect(find.text('2 / 4 · Local folder'), findsOneWidget);

      await tester.tap(find.byKey(const Key('reader-settings')));
      await settleIo();
      await tester.tap(find.text('Vertical'));
      await tester.ensureVisible(find.byKey(const Key('save-reader-settings')));
      await tester.tap(find.byKey(const Key('save-reader-settings')));
      await settleIo();
      expect(find.byKey(const Key('vertical-reader')), findsOneWidget);

      await tester.tap(find.byKey(const Key('reader-source')));
      await settleIo();
      expect(
        find.textContaining('exact page equivalence is not assumed'),
        findsOneWidget,
      );
      expect(find.text('Local Folder Alternate'), findsOneWidget);
      expect(
        await database.mangaSourcePageResume(
          localFolderAlternateProviderId,
          'sample-folder-alternate-chapter-1',
        ),
        isNull,
      );

      Navigator.of(tester.element(find.text('Reading source'))).pop();
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());
      await settleIo();
      await tester.runAsync(() async {
        expect(
          (await database.mangaProgress(sampleMangaId))?.chapterId,
          sampleChapterOneId,
        );
        expect(
          (await database.mangaSourcePageResume(
            localFolderProviderId,
            'sample-folder-chapter-1',
          ))?.pageIndex,
          1,
        );
        await database.close();
        await temp.delete(recursive: true);
      });
    },
  );

  testWidgets(
    'reader UI v2 uses canonical navigation, completion and isolated exact resumes',
    (tester) async {
      final fixture = (await tester.runAsync(_ReaderWidgetFixture.create))!;
      _disposeReaderFixtureAfterScreen(tester, fixture);
      late ReaderSession chapterTwo;
      late ReaderSession chapterOne;
      await tester.runAsync(() async {
        chapterTwo = await fixture.repository.open(
          const ReaderSessionRequest(
            mediaId: sampleMangaId,
            chapterId: sampleChapterTwoId,
          ),
        );
        await fixture.repository.savePosition(chapterTwo, 1);
        chapterOne = await fixture.repository.open(
          const ReaderSessionRequest(
            mediaId: sampleMangaId,
            chapterId: sampleChapterOneId,
          ),
        );
      });

      await _pumpReader(tester, fixture, chapterOne);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('previous-chapter')))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('next-chapter')))
            .onPressed,
        isNotNull,
      );

      await tester.tap(find.byKey(const Key('chapter-picker')));
      await _settleReaderIo(tester);
      expect(find.byKey(const Key('chapter-picker-list')), findsOneWidget);
      expect(find.textContaining('Page 1 of 4'), findsOneWidget);
      await tester.tap(find.text('Chapter 2').last);
      await _settleReaderIo(tester);
      expect(find.text('2 / 3 · Local CBZ'), findsOneWidget);

      await tester.tap(find.byKey(const Key('previous-chapter')));
      await _settleReaderIo(tester);
      expect(find.text('1 / 4 · Local folder'), findsOneWidget);

      tester
          .widget<PageView>(find.byKey(const Key('paged-reader')))
          .controller!
          .jumpToPage(2);
      await tester.pump();
      await tester.tap(find.byKey(const Key('chapter-picker')));
      await _settleReaderIo(tester);
      expect(find.textContaining('Page 3 of 4'), findsOneWidget);
      await tester.tap(find.text('Chapter 1').last);
      await _settleReaderIo(tester);

      tester
          .widget<PageView>(find.byKey(const Key('paged-reader')))
          .controller!
          .jumpToPage(3);
      await _settleReaderIo(tester);
      expect(find.text('Chapter complete'), findsOneWidget);
      expect(find.text('Next Chapter'), findsOneWidget);
      expect(
        find.byKey(const Key('completion-previous-chapter')),
        findsNothing,
      );

      await tester.tap(find.byKey(const Key('completion-next-chapter')));
      await _settleReaderIo(tester);
      expect(find.text('1 / 3 · Local CBZ'), findsOneWidget);
      await tester.runAsync(() async {
        expect(
          (await fixture.database.mangaSourcePageResume(
            chapterTwo.manifest.binding.providerId,
            chapterTwo.manifest.binding.externalId,
          ))?.pageIndex,
          1,
        );
      });
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('previous-chapter')))
            .onPressed,
        isNotNull,
      );
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('next-chapter')))
            .onPressed,
        isNull,
      );

      final zoomSurface = find.byKey(const Key('paged-zoom-surface')).first;
      final center = tester.getCenter(zoomSurface);
      final firstFinger = await tester.startGesture(
        center - const Offset(24, 0),
        pointer: 11,
      );
      final secondFinger = await tester.startGesture(
        center + const Offset(24, 0),
        pointer: 12,
      );
      await firstFinger.moveBy(const Offset(-80, 0));
      await secondFinger.moveBy(const Offset(80, 0));
      await firstFinger.up();
      await secondFinger.up();
      await tester.pump();
      expect(find.byKey(const Key('reset-page-zoom')), findsOneWidget);

      tester
          .widget<IconButton>(find.byKey(const Key('previous-chapter')))
          .onPressed!();
      await _settleReaderIo(tester);
      expect(find.byKey(const Key('reset-page-zoom')), findsNothing);
      expect(find.text('4 / 4 · Local folder'), findsOneWidget);

      await tester.tap(find.byKey(const Key('completion-next-chapter')));
      await _settleReaderIo(tester);
      tester
          .widget<PageView>(find.byKey(const Key('paged-reader')))
          .controller!
          .jumpToPage(2);
      await _settleReaderIo(tester);
      expect(find.text('End of available chapters'), findsOneWidget);
      expect(
        find.byKey(const Key('completion-previous-chapter')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('completion-next-chapter')), findsNothing);
    },
  );

  testWidgets(
    'unreadable adjacent chapter is truthful and preserves the current reader',
    (tester) async {
      final fixture = (await tester.runAsync(_ReaderWidgetFixture.create))!;
      _disposeReaderFixtureAfterScreen(tester, fixture);
      const unavailableId = CanonicalChapterId('unavailable-chapter-3');
      late ReaderSession chapterTwo;
      await tester.runAsync(() async {
        await fixture.database.saveChapter(
          CanonicalChapter(
            id: unavailableId,
            mediaId: sampleMangaId,
            number: ChapterNumber.parse('Chapter 3'),
          ),
        );
        await fixture.database.saveChapterBinding(
          const ChapterSourceBinding(
            canonicalId: unavailableId,
            providerId: ProviderId('metadata-only-test'),
            externalId: 'chapter-3',
          ),
        );
        chapterTwo = await fixture.repository.open(
          const ReaderSessionRequest(
            mediaId: sampleMangaId,
            chapterId: sampleChapterTwoId,
          ),
        );
      });

      await _pumpReader(tester, fixture, chapterTwo);
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('previous-chapter')))
            .onPressed,
        isNotNull,
      );
      expect(
        tester
            .widget<IconButton>(find.byKey(const Key('next-chapter')))
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(const Key('next-chapter')));
      await _settleReaderIo(tester);
      expect(
        find.text('The adjacent chapter has no readable source configured.'),
        findsOneWidget,
      );
      expect(find.text('1 / 3 · Local CBZ'), findsOneWidget);
    },
  );

  testWidgets('chapter picker stays lazy and exposes only genuine volumes', (
    tester,
  ) async {
    final fixture = (await tester.runAsync(_ReaderWidgetFixture.create))!;
    _disposeReaderFixtureAfterScreen(tester, fixture);
    late ReaderSession chapterOne;
    await tester.runAsync(() async {
      final now = DateTime.utc(2026);
      await fixture.database.saveChapterUserEdit(
        ChapterUserEdit(
          chapterId: sampleChapterOneId,
          rawLabel: 'Chapter 1',
          kind: MangaInstallmentKind.standard,
          volumeLabel: 'Volume 1',
          updatedAt: now,
        ),
      );
      await fixture.database.saveChapterUserEdit(
        ChapterUserEdit(
          chapterId: sampleChapterTwoId,
          rawLabel: 'Chapter 2',
          kind: MangaInstallmentKind.standard,
          volumeLabel: 'Volume 2',
          updatedAt: now,
        ),
      );
      await fixture.database.transaction(() async {
        for (var number = 3; number <= 1002; number++) {
          await fixture.database.saveChapter(
            CanonicalChapter(
              id: CanonicalChapterId('long-chapter-$number'),
              mediaId: sampleMangaId,
              number: ChapterNumber.parse('Chapter $number'),
            ),
          );
        }
      });
      chapterOne = await fixture.repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterOneId,
        ),
      );
    });

    await _pumpReader(tester, fixture, chapterOne, attempts: 40);
    await tester.tap(find.byKey(const Key('chapter-picker')));
    await _settleReaderIo(tester, attempts: 20);
    expect(find.text('Volume 1'), findsWidgets);
    expect(find.text('Volume 2'), findsWidgets);
    expect(find.text('Volume 3'), findsNothing);
    expect(find.text('Chapter 1002'), findsNothing);
    expect(find.byType(ListTile).evaluate().length, lessThan(40));
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('previous-volume')))
          .onPressed,
      isNull,
    );
    expect(
      tester.widget<IconButton>(find.byKey(const Key('next-volume'))).onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('next-volume')));
    await _settleReaderIo(tester, attempts: 20);
    expect(find.text('1 / 3 · Local CBZ'), findsOneWidget);
  });
}

class _ReaderWidgetFixture {
  _ReaderWidgetFixture({
    required this.temp,
    required this.database,
    required this.repository,
  });

  final Directory temp;
  final CanonicalDatabase database;
  final ReaderRepository repository;

  static Future<_ReaderWidgetFixture> create() async {
    final temp = await Directory.systemTemp.createTemp('zanka-reader-v2-');
    final database = CanonicalDatabase(NativeDatabase.memory());
    await SampleMangaInstaller(
      database,
      root: Directory('${temp.path}/sample'),
    ).install();
    final preferences = ReaderPreferencesStore(
      file: File('${temp.path}/settings.json'),
    );
    await preferences.save(const ReaderPreferences(mode: ReaderMode.paged));
    return _ReaderWidgetFixture(
      temp: temp,
      database: database,
      repository: ReaderRepository(
        database: database,
        sources: ReaderSourceRegistry(const [
          LocalFolderReaderSource(),
          LocalFolderReaderSource(
            id: localFolderAlternateProviderId,
            displayName: 'Local folder alternate',
          ),
          LocalCbzReaderSource(),
        ]),
        preferencesStore: preferences,
      ),
    );
  }

  Future<void> dispose() async {
    await database.close();
    await temp.delete(recursive: true);
  }
}

Future<void> _pumpReader(
  WidgetTester tester,
  _ReaderWidgetFixture fixture,
  ReaderSession session, {
  int attempts = 12,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MangaReaderScreen(
        repository: fixture.repository,
        initialSession: session,
        request: ReaderSessionRequest(
          mediaId: session.mediaId,
          chapterId: session.chapter.id,
          binding: session.manifest.binding,
        ),
      ),
    ),
  );
  await _settleReaderIo(tester, attempts: attempts);
}

Future<void> _settleReaderIo(WidgetTester tester, {int attempts = 15}) async {
  for (var index = 0; index < attempts; index++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump(const Duration(milliseconds: 80));
  }
}

void _disposeReaderFixtureAfterScreen(
  WidgetTester tester,
  _ReaderWidgetFixture fixture,
) {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await _settleReaderIo(tester, attempts: 2);
    await tester.runAsync(fixture.dispose);
  });
}
