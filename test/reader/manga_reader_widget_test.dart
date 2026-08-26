import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
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
}
