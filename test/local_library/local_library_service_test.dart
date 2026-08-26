import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/local_library/local_asset.dart';
import 'package:zanka_no_tachi/local_library/local_library_service.dart';
import 'package:zanka_no_tachi/player/local_playback_source.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/reader/local_reader_sources.dart';
import 'package:zanka_no_tachi/reader/reader_domain.dart';

void main() {
  late Directory temp;
  late CanonicalDatabase database;
  late LocalLibraryService service;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('zanka-local-library');
    database = CanonicalDatabase(NativeDatabase.memory());
    service = LocalLibraryService(
      database,
      root: Directory('${temp.path}/owned'),
    );
  });
  tearDown(() async {
    await database.close();
    await temp.delete(recursive: true);
  });

  test(
    'CBZ import uses opaque identities and opens through M5 resolver',
    () async {
      final source = await _cbz('${temp.path}/same-name.cbz');
      final mediaId = await service.importManga(
        LocalImportRequest(
          sourcePath: source.path,
          title: 'Imported manga',
          installmentLabel: 'Chapter 7.5',
        ),
      );
      final asset = (await database.allLocalAssets()).single;
      expect(asset.id.value, isNot(contains('same-name')));
      expect(asset.managedRelativePath, contains(asset.id.value));
      final chapter = (await database.chaptersFor(mediaId)).single;
      final binding = (await database.chapterBindingsFor(chapter.id)).single;
      final manifest = await LocalCbzReaderSource(id: importedMangaProviderId)
          .resolve(
            ReaderSessionRequest(
              mediaId: mediaId,
              chapterId: chapter.id,
              binding: binding,
            ),
          );
      expect(manifest.pages, hasLength(1));
    },
  );

  test(
    'same filename imports without collision and video is M6-capable',
    () async {
      final first = File('${temp.path}/a/video.mp4');
      final second = File('${temp.path}/b/video.mp4');
      await first.parent.create(recursive: true);
      await second.parent.create(recursive: true);
      await first.writeAsBytes([1, 2, 3]);
      await second.writeAsBytes([4, 5, 6]);
      for (final file in [first, second]) {
        await service.importVideo(
          LocalImportRequest(
            sourcePath: file.path,
            title: 'Video ${file.parent.path}',
            installmentLabel: 'Episode 1',
          ),
        );
      }
      final assets = await database.allLocalAssets();
      expect(
        assets.map((item) => item.managedRelativePath).toSet(),
        hasLength(2),
      );
      final episode = (await database.episodesFor(assets.first.mediaId)).single;
      final binding = (await database.episodeBindingsFor(episode.id)).single;
      expect(
        const LocalVideoPlaybackSource(
          importedVideoProviderId,
          'Imported',
        ).capability(binding),
        PlaybackSourceCapability.playbackCapable,
      );
    },
  );

  test('reviewed reattach moves only local binding and exact resume', () async {
    final source = await _cbz('${temp.path}/reattach.cbz');
    final mediaId = await service.importManga(
      LocalImportRequest(
        sourcePath: source.path,
        title: 'Reattach manga',
        installmentLabel: '1',
      ),
    );
    final asset = (await database.allLocalAssets()).single;
    final original = (await database.chaptersFor(mediaId)).single;
    const targetId = CanonicalChapterId('reviewed-target');
    await database.saveChapter(
      CanonicalChapter(
        id: targetId,
        mediaId: mediaId,
        number: ChapterNumber.parse('2'),
      ),
    );
    await database.saveMangaProgress(
      CanonicalMangaProgress(
        mediaId: mediaId,
        chapterId: original.id,
        pageIndex: 0,
        totalPages: 1,
        updatedAt: DateTime.utc(2026),
      ),
    );
    await database.saveMangaSourcePageResume(
      MangaSourcePageResume(
        mediaId: mediaId,
        chapterId: original.id,
        providerId: asset.providerId,
        chapterExternalId: asset.bindingExternalId,
        pageIndex: 0,
        totalPages: 1,
        updatedAt: DateTime.utc(2026),
      ),
    );
    await service.reattach(asset, targetInstallmentId: targetId.value);
    expect(
      await database.chapterBinding(asset.providerId, asset.bindingExternalId),
      targetId,
    );
    expect((await database.mangaProgress(mediaId))!.chapterId, original.id);
    expect(
      (await database.mangaSourcePageResume(
        asset.providerId,
        asset.bindingExternalId,
      ))!.chapterId,
      targetId,
    );
  });

  test(
    'missing repair and source removal preserve Library and progress',
    () async {
      final source = await _cbz('${temp.path}/chapter.cbz');
      final mediaId = await service.importManga(
        LocalImportRequest(
          sourcePath: source.path,
          title: 'Repair manga',
          installmentLabel: 'Chapter 1',
        ),
      );
      var asset = (await database.allLocalAssets()).single;
      final chapter = (await database.chaptersFor(mediaId)).single;
      await database.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: mediaId,
          chapterId: chapter.id,
          pageIndex: 0,
          totalPages: 1,
          updatedAt: DateTime.utc(2026),
        ),
      );
      await File(
        '${(await service.root).path}/${asset.managedRelativePath}',
      ).delete();
      asset = (await service.refreshStates()).single;
      expect(asset.state, LocalAssetState.missing);
      final replacement = await _cbz('${temp.path}/replacement.cbz');
      await service.repair(asset, replacement.path);
      expect(
        (await database.allLocalAssets()).single.state,
        LocalAssetState.available,
      );
      final ownedPath = File(
        '${(await service.root).path}/${asset.managedRelativePath}',
      );
      expect(await ownedPath.exists(), isTrue);
      await service.removeSource(asset, deletePhysical: true);
      expect(await ownedPath.exists(), isFalse);
      expect(await database.mediaBindingsFor(mediaId), isEmpty);
      expect((await database.libraryEntry(mediaId))?.isSaved, isTrue);
      expect(await database.mangaProgress(mediaId), isNotNull);
      expect(await database.allLocalAssets(), isEmpty);
    },
  );

  test('storage accounts tracked assets only', () async {
    final source = await _cbz('${temp.path}/chapter.cbz');
    await service.importManga(
      LocalImportRequest(
        sourcePath: source.path,
        title: 'Storage manga',
        installmentLabel: 'Chapter 1',
      ),
    );
    final summary = await service.storageSummary();
    expect(summary.assetCount, 1);
    expect(summary.mangaBytes, greaterThan(0));
    expect(summary.videoBytes, 0);
  });

  test(
    'cache cleanup preserves imported media, Library and progress',
    () async {
      final source = await _cbz('${temp.path}/chapter.cbz');
      final mediaId = await service.importManga(
        LocalImportRequest(
          sourcePath: source.path,
          title: 'Durable manga',
          installmentLabel: 'Chapter 1',
        ),
      );
      final chapter = (await database.chaptersFor(mediaId)).single;
      await database.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: mediaId,
          chapterId: chapter.id,
          pageIndex: 0,
          updatedAt: DateTime.utc(2026),
        ),
      );
      final root = await service.root;
      final thumbnail = File('${root.path}/thumbnail-cache/generated.jpg');
      await thumbnail.parent.create(recursive: true);
      await thumbnail.writeAsBytes([1, 2, 3]);
      await File('${root.path}/.partial-stale').writeAsBytes([4]);

      final result = await service.clearRegenerableData();

      expect(result.filesRemoved, 2);
      expect(await thumbnail.exists(), isFalse);
      final asset = (await database.allLocalAssets()).single;
      expect(
        await File('${root.path}/${asset.managedRelativePath}').exists(),
        isTrue,
      );
      expect((await database.libraryEntry(mediaId))?.isSaved, isTrue);
      expect(await database.mangaProgress(mediaId), isNotNull);
    },
  );

  test('corrupt managed archive is reported as unreadable', () async {
    final source = await _cbz('${temp.path}/chapter.cbz');
    await service.importManga(
      LocalImportRequest(
        sourcePath: source.path,
        title: 'Damaged manga',
        installmentLabel: 'Chapter 1',
      ),
    );
    final asset = (await database.allLocalAssets()).single;
    await File(
      '${(await service.root).path}/${asset.managedRelativePath}',
    ).writeAsString('not a zip');
    expect(
      (await service.refreshStates()).single.state,
      LocalAssetState.unreadable,
    );
  });

  test('failed preparation leaves no database row or partial copy', () async {
    final blockedRoot = File('${temp.path}/not-a-directory')
      ..writeAsStringSync('blocked');
    final failing = LocalLibraryService(
      database,
      root: Directory(blockedRoot.path),
    );
    final source = await _cbz('${temp.path}/valid.cbz');
    await expectLater(
      failing.importManga(
        LocalImportRequest(
          sourcePath: source.path,
          title: 'Failure',
          installmentLabel: 'Chapter 1',
        ),
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(await database.allLocalAssets(), isEmpty);
    expect(
      temp.listSync().where((entry) => entry.path.contains('.partial-')),
      isEmpty,
    );
  });
}

Future<File> _cbz(String path) async {
  final archive = Archive()..add(ArchiveFile.bytes('1.png', [1, 2, 3]));
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(ZipEncoder().encode(archive));
  return file;
}
