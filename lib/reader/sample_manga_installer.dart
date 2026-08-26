import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
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
    final colors = [
      _solidPng(220, 72, 72),
      _solidPng(61, 166, 91),
      _solidPng(70, 114, 220),
      _solidPng(226, 183, 54),
    ];
    for (var index = 0; index < colors.length; index++) {
      await File(
        '${chapter1.path}/page-${index + 1}.png',
      ).writeAsBytes(colors[index], flush: true);
    }
    final cbzPath = '${root.path}/chapter-2.cbz';
    final archive = Archive();
    for (var index = 0; index < 3; index++) {
      archive.add(
        ArchiveFile.bytes(
          'page-${index + 1}.png',
          colors.reversed.elementAt(index),
        ),
      );
    }
    await File(cbzPath).writeAsBytes(ZipEncoder().encode(archive), flush: true);
    final secondFolder = Directory('${root.path}/chapter-1-alt');
    await secondFolder.create(recursive: true);
    for (var index = 0; index < 2; index++) {
      await File(
        '${secondFolder.path}/${index + 1}.png',
      ).writeAsBytes(colors.reversed.elementAt(index), flush: true);
    }

    final source = FieldProvenance(providerId: localFolderProviderId);
    await database.transaction(() async {
      await database.saveMedia(
        CanonicalManga(
          id: sampleMangaId,
          title: SourcedValue(
            value: 'Zanka Local Reader Sample',
            provenance: source,
          ),
          description: SourcedValue(
            value:
                'A lawful, generated offline sample for validating the manga reader.',
            provenance: source,
          ),
          status: CanonicalMediaStatus.completed,
        ),
      );
      await database.saveChapter(
        CanonicalChapter(
          id: sampleChapterOneId,
          mediaId: sampleMangaId,
          number: ChapterNumber.parse('Chapter 1'),
          title: 'Folder pages',
        ),
      );
      await database.saveChapter(
        CanonicalChapter(
          id: sampleChapterTwoId,
          mediaId: sampleMangaId,
          number: ChapterNumber.parse('Chapter 2'),
          title: 'CBZ pages',
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

Uint8List _solidPng(int red, int green, int blue) {
  const width = 320;
  const height = 480;
  final scanlines = BytesBuilder(copy: false);
  for (var y = 0; y < height; y++) {
    scanlines.addByte(0);
    for (var x = 0; x < width; x++) {
      final shade = ((x ~/ 32 + y ~/ 48) % 2) * 18;
      scanlines.add([
        (red + shade).clamp(0, 255),
        (green + shade).clamp(0, 255),
        (blue + shade).clamp(0, 255),
      ]);
    }
  }
  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8)
    ..setUint8(9, 2);
  final result = BytesBuilder(copy: false)
    ..add(const [137, 80, 78, 71, 13, 10, 26, 10])
    ..add(_pngChunk('IHDR', header.buffer.asUint8List()))
    ..add(
      _pngChunk('IDAT', Uint8List.fromList(zlib.encode(scanlines.takeBytes()))),
    )
    ..add(_pngChunk('IEND', Uint8List(0)));
  return result.takeBytes();
}

Uint8List _pngChunk(String type, Uint8List data) {
  final typeBytes = type.codeUnits;
  final result = BytesBuilder(copy: false);
  final size = ByteData(4)..setUint32(0, data.length);
  result
    ..add(size.buffer.asUint8List())
    ..add(typeBytes)
    ..add(data);
  final crcBytes = ByteData(4)..setUint32(0, _crc32([...typeBytes, ...data]));
  result.add(crcBytes.buffer.asUint8List());
  return result.takeBytes();
}

int _crc32(List<int> bytes) {
  var crc = 0xffffffff;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) == 1 ? 0xedb88320 ^ (crc >>> 1) : crc >>> 1;
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}
