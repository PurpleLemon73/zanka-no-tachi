import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/reader/local_reader_sources.dart';
import 'package:zanka_no_tachi/reader/reader_domain.dart';
import 'package:zanka_no_tachi/reader/reader_page_cache.dart';
import 'package:zanka_no_tachi/reader/reader_preferences_store.dart';
import 'package:zanka_no_tachi/reader/reader_repository.dart';
import 'package:zanka_no_tachi/reader/reader_source.dart';
import 'package:zanka_no_tachi/reader/sample_manga_installer.dart';
import 'package:zanka_no_tachi/product_maturity/maturity_domain.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late CanonicalDatabase database;
  late ReaderRepository repository;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('zanka-reader-');
    database = CanonicalDatabase(
      NativeDatabase(File('${temp.path}/db.sqlite')),
    );
    repository = _repository(database, temp);
    await SampleMangaInstaller(
      database,
      root: Directory('${temp.path}/sample'),
    ).install();
  });

  tearDown(() async {
    await database.close();
    await temp.delete(recursive: true);
  });

  test(
    'folder and CBZ manifests use deterministic natural page ordering',
    () async {
      final folder = Directory('${temp.path}/order')..createSync();
      for (final name in ['10.png', '2.jpg', '1.webp', 'notes.txt']) {
        File('${folder.path}/$name').writeAsBytesSync([1, 2, 3]);
      }
      const binding = ChapterSourceBinding(
        canonicalId: sampleChapterOneId,
        providerId: localFolderProviderId,
        externalId: 'order',
      );
      final manifest = await const LocalFolderReaderSource().resolve(
        ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterOneId,
          binding: ChapterSourceBinding(
            canonicalId: binding.canonicalId,
            providerId: binding.providerId,
            externalId: binding.externalId,
            relativeLocator: folder.path,
          ),
        ),
      );
      expect(
        manifest.pages.map((page) => page.displayLocator.split('/').last),
        ['1.webp', '2.jpg', '10.png'],
      );

      final cbz = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterTwoId,
        ),
      );
      expect(cbz.manifest.pages.map((page) => page.index), [0, 1, 2]);
      final bytes = await cbz.manifest.pages.first.loadBytes();
      expect(bytes, isNotEmpty);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1024);
      expect(frame.image.height, 1536);
      frame.image.dispose();
      codec.dispose();
    },
  );

  test(
    'corrupt and unsupported CBZ files produce typed reader errors',
    () async {
      final corrupt = File('${temp.path}/corrupt.cbz')
        ..writeAsStringSync('bad zip');
      final unsupportedArchive = Archive()
        ..add(ArchiveFile.string('notes.txt', 'not an image'));
      final unsupported = File('${temp.path}/unsupported.cbz')
        ..writeAsBytesSync(ZipEncoder().encode(unsupportedArchive));
      for (final value in [
        (corrupt, ReaderErrorKind.manifestInvalid),
        (unsupported, ReaderErrorKind.unsupportedFormat),
      ]) {
        final source = const LocalCbzReaderSource();
        expect(
          () => source.resolve(
            ReaderSessionRequest(
              mediaId: sampleMangaId,
              chapterId: sampleChapterTwoId,
              binding: ChapterSourceBinding(
                canonicalId: sampleChapterTwoId,
                providerId: localCbzProviderId,
                externalId: value.$1.path,
                relativeLocator: value.$1.path,
              ),
            ),
          ),
          throwsA(
            isA<ReaderException>().having(
              (error) => error.kind,
              'kind',
              value.$2,
            ),
          ),
        );
      }
    },
  );

  test('metadata-only bindings are not exposed as readable', () async {
    await database.saveChapterBinding(
      const ChapterSourceBinding(
        canonicalId: sampleChapterTwoId,
        providerId: ProviderId('mangaworld'),
        externalId: 'metadata-only',
      ),
    );
    final chapter = (await repository.chapters(
      sampleMangaId,
    )).firstWhere((item) => item.chapter.id == sampleChapterTwoId);
    expect(
      chapter.capabilities[const ProviderId('mangaworld')],
      ReaderSourceCapability.metadataOnly,
    );
    expect(
      chapter.readableBindings.any(
        (binding) => binding.providerId == const ProviderId('mangaworld'),
      ),
      isFalse,
    );
  });

  test(
    'same source resumes exactly and different source starts at page one',
    () async {
      var session = await repository.open(
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
      await repository.savePosition(session, 3);
      session = await repository.open(
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
      expect(session.startPage, 3);
      final alternate = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterOneId,
          binding: ChapterSourceBinding(
            canonicalId: sampleChapterOneId,
            providerId: localFolderAlternateProviderId,
            externalId: 'sample-folder-alternate-chapter-1',
          ),
        ),
      );
      expect(alternate.startPage, 0);
      expect(alternate.manifest.pages.length, 2);
      expect(
        await database.preferredProvider(sampleMangaId),
        localFolderAlternateProviderId,
      );
      expect(
        (await database.mangaProgress(sampleMangaId))?.chapterId,
        sampleChapterOneId,
      );
      expect(
        await database.mangaSourcePageResume(
          localFolderAlternateProviderId,
          'sample-folder-alternate-chapter-1',
        ),
        isNull,
      );
    },
  );

  test(
    'manual forward navigation starts at page one without consuming exact resume',
    () async {
      final resumed = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterTwoId,
        ),
      );
      await repository.savePosition(resumed, 1);

      final manualNext = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterTwoId,
          startAtBeginning: true,
        ),
      );
      expect(manualNext.startPage, 0);
      expect(
        (await database.mangaSourcePageResume(
          manualNext.manifest.binding.providerId,
          manualNext.manifest.binding.externalId,
        ))?.pageIndex,
        1,
      );

      final ordinaryReopen = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterTwoId,
        ),
      );
      expect(ordinaryReopen.startPage, 1);
    },
  );

  test('fresh live retry is bounded and preserves exact resume', () async {
    final original = await repository.open(
      const ReaderSessionRequest(
        mediaId: sampleMangaId,
        chapterId: sampleChapterOneId,
      ),
    );
    await repository.savePosition(original, 2);
    final resolver = _FlakyReaderResolver();
    final retrying = ReaderRepository(
      database: database,
      sources: ReaderSourceRegistry([resolver]),
      preferencesStore: ReaderPreferencesStore(
        file: File('${temp.path}/retry-preferences.json'),
      ),
    );
    final reopened = await retrying.open(
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
    expect(resolver.calls, 2);
    expect(reopened.startPage, 2);
    expect((await database.mangaProgress(sampleMangaId))?.pageIndex, 2);
  });

  test(
    'preferred reader source is selected only when chapter-capable',
    () async {
      await database.setPreferredProvider(
        sampleMangaId,
        localFolderAlternateProviderId,
      );
      final preferred = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterOneId,
        ),
      );
      expect(
        preferred.manifest.binding.providerId,
        localFolderAlternateProviderId,
      );
      await database.setPreferredProvider(
        sampleMangaId,
        const ProviderId('mangaworld'),
      );
      final fallback = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterOneId,
        ),
      );
      expect(fallback.manifest.binding.providerId, localFolderProviderId);
    },
  );

  test(
    'last rendered page marks read while manual unread retains resume',
    () async {
      final session = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterOneId,
        ),
      );
      await repository.savePosition(session, session.manifest.pages.length - 1);
      expect(await database.chapterCompletionsFor(sampleMangaId), hasLength(1));
      await repository.markUnread(sampleChapterOneId);
      expect(await database.chapterCompletionsFor(sampleMangaId), isEmpty);
      expect(
        (await database.mangaSourcePageResume(
          session.manifest.binding.providerId,
          session.manifest.binding.externalId,
        ))!.pageIndex,
        session.manifest.pages.length - 1,
      );
    },
  );

  test(
    'bounded page cache evicts distant pages and retry replaces failures',
    () async {
      var attempts = 0;
      final failing = ReaderPage(
        id: 'failure',
        index: 0,
        displayLocator: 'memory:failure',
        loadBytes: () async {
          attempts++;
          if (attempts == 1) throw StateError('temporary page error');
          return Uint8List.fromList([1]);
        },
      );
      final cache = ReaderPageCache(maximumPages: 2);
      await expectLater(cache.load(failing), throwsStateError);
      cache.retry(failing);
      expect(await cache.load(failing), [1]);
      for (var index = 1; index < 4; index++) {
        await cache.load(
          ReaderPage(
            id: '$index',
            index: index,
            displayLocator: 'memory:$index',
            loadBytes: () async => Uint8List.fromList([index]),
          ),
        );
      }
      expect(cache.length, 2);
    },
  );

  test(
    'resume, canonical progress and preferences survive database reopen offline',
    () async {
      final session = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterOneId,
        ),
      );
      await repository.savePosition(session, 2);
      await repository.savePreferences(
        const ReaderPreferences(
          mode: ReaderMode.paged,
          direction: ReaderDirection.rightToLeft,
          fit: ReaderFit.contain,
        ),
      );
      await database.close();
      database = CanonicalDatabase(
        NativeDatabase(File('${temp.path}/db.sqlite')),
      );
      repository = _repository(database, temp);
      final reopened = await repository.open(
        ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterOneId,
          binding: session.manifest.binding,
        ),
      );
      expect(reopened.startPage, 2);
      expect(reopened.preferences.mode, ReaderMode.paged);
      expect(reopened.preferences.direction, ReaderDirection.rightToLeft);
      expect((await database.mangaProgress(sampleMangaId))?.pageIndex, 2);
    },
  );

  test(
    'canonical navigation orders decimal chapters then specials deterministically',
    () async {
      for (final value in [
        ('decimal', '1.5'),
        ('special-b', 'Special B'),
        ('special-a', 'Special A'),
      ]) {
        await database.saveChapter(
          CanonicalChapter(
            id: CanonicalChapterId(value.$1),
            mediaId: sampleMangaId,
            number: ChapterNumber.parse(value.$2),
          ),
        );
      }
      final chapters = await repository.chapters(sampleMangaId);
      expect(chapters.map((item) => item.chapter.number.rawLabel), [
        'Chapter 1',
        '1.5',
        'Chapter 2',
        'Special A',
        'Special B',
      ]);
      final chapterOne = await repository.open(
        const ReaderSessionRequest(
          mediaId: sampleMangaId,
          chapterId: sampleChapterOneId,
        ),
      );
      expect(
        (await repository.adjacent(chapterOne, 1))?.chapter.number.rawLabel,
        '1.5',
      );
    },
  );

  test(
    'user order and genuine edited volume labels drive reader navigation',
    () async {
      const volumeTen = CanonicalChapterId('volume-ten-chapter');
      const volumeTwo = CanonicalChapterId('volume-two-chapter');
      for (final value in [
        (volumeTen, '10', 'Volume 10'),
        (volumeTwo, '2', 'Volume 2'),
      ]) {
        await database.saveChapter(
          CanonicalChapter(
            id: value.$1,
            mediaId: sampleMangaId,
            number: ChapterNumber.parse(value.$2),
            volumeLabel: value.$3,
          ),
        );
      }
      await database.saveChapterUserEdit(
        ChapterUserEdit(
          chapterId: sampleChapterTwoId,
          rawLabel: 'The edited finale',
          kind: MangaInstallmentKind.standard,
          volumeLabel: 'Volume 20',
          explicitOrder: -1,
          updatedAt: DateTime.utc(2026),
        ),
      );

      final values = await repository.chapters(sampleMangaId);
      expect(values.first.chapter.id, sampleChapterTwoId);
      expect(values.first.displayLabel, 'The edited finale');
      expect(values.first.volumeLabel, 'Volume 20');
      expect(
        values
            .where((value) => {volumeTwo, volumeTen}.contains(value.chapter.id))
            .map((value) => value.chapter.id),
        [volumeTwo, volumeTen],
      );
    },
  );
}

class _FlakyReaderResolver
    implements ReaderSourceResolver, FreshReaderManifestRetry {
  int calls = 0;
  @override
  ProviderId get providerId => localFolderProviderId;

  @override
  ReaderSourceCapability capability(ChapterSourceBinding binding) =>
      ReaderSourceCapability.readerCapable;

  @override
  Future<ReaderManifest> resolve(ReaderSessionRequest request) async {
    calls++;
    if (calls == 1) {
      throw const ReaderException(
        ReaderErrorKind.sourceUnavailable,
        'temporary',
      );
    }
    return ReaderManifest(
      sourceName: 'Recovered',
      binding: request.binding!,
      pages: [
        for (var index = 0; index < 4; index++)
          ReaderPage(
            id: 'page-$index',
            index: index,
            displayLocator: 'Page ${index + 1}',
            loadBytes: () async => Uint8List.fromList([index]),
          ),
      ],
    );
  }
}

ReaderRepository _repository(CanonicalDatabase database, Directory temp) =>
    ReaderRepository(
      database: database,
      sources: ReaderSourceRegistry(const [
        LocalFolderReaderSource(),
        LocalFolderReaderSource(
          id: localFolderAlternateProviderId,
          displayName: 'Local folder alternate',
        ),
        LocalCbzReaderSource(),
      ]),
      preferencesStore: ReaderPreferencesStore(
        file: File('${temp.path}/settings.json'),
      ),
    );
