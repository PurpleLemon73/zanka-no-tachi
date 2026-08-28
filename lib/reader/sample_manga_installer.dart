import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/media.dart';
import '../canonical/domain/user_state.dart';
import '../canonical/persistence/canonical_database.dart';
import 'local_reader_sources.dart';

const sampleMangaId = CanonicalMediaId('local-sample-manga');
const sampleChapterOneId = CanonicalChapterId('local-sample-chapter-1');
const sampleChapterTwoId = CanonicalChapterId('local-sample-chapter-2');

class SampleMangaInstaller {
  SampleMangaInstaller(this.database, {Directory? root}) : _root = root;
  final CanonicalDatabase database;
  final Directory? _root;

  Future<CanonicalMediaId> install() async {
    final root =
        _root ??
        Directory(
          '${(await getApplicationSupportDirectory()).path}/sample-manga',
        );
    final chapter1 = Directory('${root.path}/chapter-1');
    await chapter1.create(recursive: true);
    final showcasePages = [
      await _assetBytes('assets/showcase/ashen_blade/cover.png'),
      await _assetBytes('assets/showcase/ashen_blade/page-01.png'),
      await _assetBytes('assets/showcase/ashen_blade/page-02.png'),
      await _assetBytes('assets/showcase/ashen_blade/page-03.png'),
    ];
    for (var index = 0; index < showcasePages.length; index++) {
      await File(
        '${chapter1.path}/page-${index + 1}.png',
      ).writeAsBytes(showcasePages[index], flush: true);
    }
    final cover = File('${root.path}/ashen-blade-cover.png');
    await cover.writeAsBytes(showcasePages.first, flush: true);
    final cbzPath = '${root.path}/chapter-2.cbz';
    final archive = Archive();
    for (var index = 0; index < 3; index++) {
      archive.add(
        ArchiveFile.bytes('page-${index + 1}.png', showcasePages[index + 1]),
      );
    }
    await File(cbzPath).writeAsBytes(ZipEncoder().encode(archive), flush: true);
    final secondFolder = Directory('${root.path}/chapter-1-alt');
    await secondFolder.create(recursive: true);
    for (var index = 0; index < 2; index++) {
      await File(
        '${secondFolder.path}/${index + 1}.png',
      ).writeAsBytes(showcasePages[index + 2], flush: true);
    }

    final source = FieldProvenance(providerId: localFolderProviderId);
    await database.transaction(() async {
      await database.saveMedia(
        CanonicalManga(
          id: sampleMangaId,
          title: SourcedValue(value: 'Ashen Blade', provenance: source),
          description: SourcedValue(
            value:
                'An elderly one-armed ronin carries a blade of living embers across a realm where every victory leaves another scar in the sky.',
            provenance: source,
          ),
          status: CanonicalMediaStatus.ongoing,
          coverLocator: cover.path,
        ),
      );
      await database.saveChapter(
        CanonicalChapter(
          id: sampleChapterOneId,
          mediaId: sampleMangaId,
          number: ChapterNumber.parse('Chapter 1'),
          title: 'The Cinder Road',
        ),
      );
      await database.saveChapter(
        CanonicalChapter(
          id: sampleChapterTwoId,
          mediaId: sampleMangaId,
          number: ChapterNumber.parse('Chapter 2'),
          title: 'A Cut Across the Sky',
        ),
      );
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: sampleMangaId,
          providerId: localFolderProviderId,
          externalId: 'zanka-sample-folder',
        ),
      );
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: sampleMangaId,
          providerId: localFolderAlternateProviderId,
          externalId: 'zanka-sample-alternate',
        ),
      );
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: sampleMangaId,
          providerId: localCbzProviderId,
          externalId: 'zanka-sample-cbz',
        ),
      );
      await database.saveChapterBinding(
        ChapterSourceBinding(
          canonicalId: sampleChapterOneId,
          providerId: localFolderProviderId,
          externalId: 'sample-folder-chapter-1',
          relativeLocator: chapter1.path,
        ),
      );
      await database.saveChapterBinding(
        ChapterSourceBinding(
          canonicalId: sampleChapterOneId,
          providerId: localFolderAlternateProviderId,
          externalId: 'sample-folder-alternate-chapter-1',
          relativeLocator: secondFolder.path,
        ),
      );
      await database.saveChapterBinding(
        ChapterSourceBinding(
          canonicalId: sampleChapterTwoId,
          providerId: localCbzProviderId,
          externalId: 'sample-cbz-chapter-2',
          relativeLocator: cbzPath,
        ),
      );
      final now = DateTime.now().toUtc();
      await database.saveLibraryEntry(
        CanonicalLibraryEntry(
          mediaId: sampleMangaId,
          isSaved: true,
          isFavorite: false,
          status: CanonicalLibraryStatus.inProgress,
          createdAt:
              (await database.libraryEntry(sampleMangaId))?.createdAt ?? now,
          updatedAt: now,
        ),
      );
    });
    return sampleMangaId;
  }
}

Future<List<int>> _assetBytes(String path) async {
  final data = await rootBundle.load(path);
  return data.buffer.asUint8List();
}
