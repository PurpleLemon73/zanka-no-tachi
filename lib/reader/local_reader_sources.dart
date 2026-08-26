import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import 'reader_domain.dart';
import 'reader_source.dart';
import '../security/archive_safety.dart';

const localFolderProviderId = ProviderId('local-folder');
const localFolderAlternateProviderId = ProviderId('local-folder-alternate');
const localCbzProviderId = ProviderId('local-cbz');

const _imageExtensions = {'.jpg', '.jpeg', '.png', '.webp', '.gif'};

int naturalPathCompare(String left, String right) {
  final parts = RegExp(r'\d+|\D+');
  final a = parts
      .allMatches(left.toLowerCase())
      .map((m) => m.group(0)!)
      .toList();
  final b = parts
      .allMatches(right.toLowerCase())
      .map((m) => m.group(0)!)
      .toList();
  for (var i = 0; i < a.length && i < b.length; i++) {
    final an = int.tryParse(a[i]);
    final bn = int.tryParse(b[i]);
    final comparison = an != null && bn != null
        ? an.compareTo(bn)
        : a[i].compareTo(b[i]);
    if (comparison != 0) return comparison;
  }
  return a.length.compareTo(b.length);
}

class LocalFolderReaderSource implements ReaderSourceResolver {
  const LocalFolderReaderSource({
    this.id = localFolderProviderId,
    this.displayName = 'Local folder',
  });
  final ProviderId id;
  final String displayName;
  @override
  ProviderId get providerId => id;

  @override
  ReaderSourceCapability capability(ChapterSourceBinding binding) =>
      binding.relativeLocator == null ||
          !Directory(binding.relativeLocator!).existsSync()
      ? ReaderSourceCapability.temporarilyUnavailable
      : ReaderSourceCapability.readerCapable;

  @override
  Future<ReaderManifest> resolve(ReaderSessionRequest request) async {
    final binding = request.binding;
    if (binding == null || binding.providerId != providerId) {
      throw const ReaderException(
        ReaderErrorKind.sourceUnavailable,
        'The selected local folder source is unavailable.',
      );
    }
    final path = binding.relativeLocator;
    final directory = path == null ? null : Directory(path);
    if (directory == null || !await directory.exists()) {
      throw const ReaderException(
        ReaderErrorKind.localFileMissing,
        'The local chapter folder is missing.',
      );
    }
    final files = await directory
        .list(followLinks: false)
        .where((entry) => entry is File && _isImage(entry.path))
        .cast<File>()
        .toList();
    files.sort((a, b) => naturalPathCompare(a.path, b.path));
    if (files.isEmpty) {
      throw const ReaderException(
        ReaderErrorKind.manifestInvalid,
        'The folder contains no supported image pages.',
      );
    }
    return ReaderManifest(
      sourceName: displayName,
      binding: binding,
      pages: [
        for (var index = 0; index < files.length; index++)
          ReaderPage(
            id: '${binding.externalId}:$index',
            index: index,
            displayLocator: files[index].path,
            loadBytes: files[index].readAsBytes,
          ),
      ],
    );
  }
}

class LocalCbzReaderSource implements ReaderSourceResolver {
  const LocalCbzReaderSource({
    this.id = localCbzProviderId,
    this.displayName = 'Local CBZ',
  });
  final ProviderId id;
  final String displayName;
  @override
  ProviderId get providerId => id;

  @override
  ReaderSourceCapability capability(ChapterSourceBinding binding) =>
      binding.relativeLocator == null ||
          !File(binding.relativeLocator!).existsSync()
      ? ReaderSourceCapability.temporarilyUnavailable
      : ReaderSourceCapability.readerCapable;

  @override
  Future<ReaderManifest> resolve(ReaderSessionRequest request) async {
    final binding = request.binding;
    if (binding == null || binding.providerId != providerId) {
      throw const ReaderException(
        ReaderErrorKind.sourceUnavailable,
        'The selected CBZ source is unavailable.',
      );
    }
    final path = binding.relativeLocator;
    final file = path == null ? null : File(path);
    if (file == null || !await file.exists()) {
      throw const ReaderException(
        ReaderErrorKind.localFileMissing,
        'The local CBZ file is missing.',
      );
    }
    Archive archive;
    try {
      archive = await decodeArchiveFileSafely(file, ArchiveSafetyLimits.cbz);
    } on Object catch (error) {
      throw ReaderException(
        ReaderErrorKind.manifestInvalid,
        'The CBZ archive could not be read.',
        error,
      );
    }
    final entryNames =
        archive.files
            .where((entry) => entry.isFile && _isImage(entry.name))
            .map((entry) => entry.name)
            .toList()
          ..sort(naturalPathCompare);
    if (entryNames.isEmpty) {
      throw ReaderException(
        archive.files.isEmpty
            ? ReaderErrorKind.manifestInvalid
            : ReaderErrorKind.unsupportedFormat,
        archive.files.isEmpty
            ? 'The CBZ archive has no readable directory.'
            : 'The CBZ contains no supported image pages.',
      );
    }
    return ReaderManifest(
      sourceName: displayName,
      binding: binding,
      pages: [
        for (var index = 0; index < entryNames.length; index++)
          ReaderPage(
            id: '${binding.externalId}:$index',
            index: index,
            displayLocator: '${file.path}#${entryNames[index]}',
            loadBytes: () async {
              final input = InputFileStream(file.path);
              try {
                final pageArchive = ZipDecoder().decodeStream(input);
                final bytes = pageArchive.find(entryNames[index])?.readBytes();
                if (bytes != null) return Uint8List.fromList(bytes);
                throw const ReaderException(
                  ReaderErrorKind.pageUnavailable,
                  'This archive page could not be decoded.',
                );
              } finally {
                await input.close();
              }
            },
          ),
      ],
    );
  }
}

bool _isImage(String path) =>
    _imageExtensions.contains(p.extension(path).toLowerCase());
