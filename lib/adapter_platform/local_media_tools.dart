import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:video_player/video_player.dart';

import '../canonical/domain/identifiers.dart';
import '../local_library/local_library_service.dart';
import '../security/archive_safety.dart';

class LocalMediaProbe {
  const LocalMediaProbe({
    required this.path,
    required this.container,
    required this.sizeBytes,
    this.pageCount,
    this.imageFormats = const {},
    this.duration,
    this.width,
    this.height,
    this.codec,
  });

  final String path;
  final String container;
  final int sizeBytes;
  final int? pageCount;
  final Set<String> imageFormats;
  final Duration? duration;
  final int? width;
  final int? height;
  final String? codec;
}

class LocalMediaProbeService {
  const LocalMediaProbeService();

  Future<LocalMediaProbe> probe(String path) async {
    final file = File(path);
    if (!await file.exists()) throw const FormatException('File is missing.');
    final extension = p.extension(path).toLowerCase();
    if (extension == '.cbz') {
      final archive = await decodeArchiveFileSafely(
        file,
        ArchiveSafetyLimits.cbz,
      );
      final images = archive
          .where((entry) => entry.isFile && _isImage(entry.name))
          .toList();
      if (images.isEmpty) {
        throw const FormatException('The CBZ contains no supported images.');
      }
      return LocalMediaProbe(
        path: path,
        container: 'cbz',
        sizeBytes: await file.length(),
        pageCount: images.length,
        imageFormats: images
            .map((entry) => p.extension(entry.name).toLowerCase().substring(1))
            .toSet(),
      );
    }
    if (!const {'.mp4', '.webm', '.mkv', '.mov'}.contains(extension)) {
      throw const FormatException('Unsupported local media format.');
    }
    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.file(file);
      await controller.initialize();
      final value = controller.value;
      return LocalMediaProbe(
        path: path,
        container: extension.substring(1),
        sizeBytes: await file.length(),
        duration: value.duration,
        width: value.size.width.round(),
        height: value.size.height.round(),
      );
    } on Object {
      // Probe metadata is optional: a platform decoder/probe failure must not
      // reject an otherwise supported lawful import.
    } finally {
      await controller?.dispose();
    }
    return LocalMediaProbe(
      path: path,
      container: extension.substring(1),
      sizeBytes: await file.length(),
    );
  }
}

class LocalThumbnailService {
  LocalThumbnailService(this.cacheRoot, {this.maximumEntries = 64});

  final Directory cacheRoot;
  final int maximumEntries;

  Future<File> cbzThumbnail(String cbzPath, String cacheKey) async {
    await cacheRoot.create(recursive: true);
    final safeKey = cacheKey.replaceAll(RegExp('[^a-zA-Z0-9._-]'), '_');
    final existing = (await cacheRoot.list().toList())
        .whereType<File>()
        .where((entry) => p.basename(entry.path).startsWith('$safeKey.'))
        .firstOrNull;
    if (existing != null) {
      await existing.setLastModified(DateTime.now());
      return existing;
    }
    final archive = await decodeArchiveFileSafely(
      File(cbzPath),
      ArchiveSafetyLimits.cbz,
    );
    final pages =
        archive.where((entry) => entry.isFile && _isImage(entry.name)).toList()
          ..sort((a, b) => _naturalCompare(a.name, b.name));
    if (pages.isEmpty) {
      throw const FormatException('The CBZ contains no supported images.');
    }
    final extension = p.extension(pages.first.name).toLowerCase();
    final output = File('${cacheRoot.path}/$safeKey$extension');
    await output.writeAsBytes(pages.first.content, flush: true);
    await _trim();
    return output;
  }

  Future<void> clear() async {
    if (await cacheRoot.exists()) await cacheRoot.delete(recursive: true);
  }

  Future<void> _trim() async {
    final files = (await cacheRoot.list().toList()).whereType<File>().toList();
    if (files.length <= maximumEntries) return;
    final dated = <(File, DateTime)>[];
    for (final file in files) {
      dated.add((file, await file.lastModified()));
    }
    dated.sort((a, b) => a.$2.compareTo(b.$2));
    for (final value in dated.take(files.length - maximumEntries)) {
      await value.$1.delete();
    }
  }
}

class BatchImportItem {
  const BatchImportItem({
    required this.sourcePath,
    required this.label,
    required this.probe,
    this.warning,
  });

  final String sourcePath;
  final String label;
  final LocalMediaProbe probe;
  final String? warning;

  BatchImportItem copyWith({String? label}) => BatchImportItem(
    sourcePath: sourcePath,
    label: label ?? this.label,
    probe: probe,
    warning: warning,
  );
}

class LocalBatchImportService {
  const LocalBatchImportService(this.library, this.probes);

  final LocalLibraryService library;
  final LocalMediaProbeService probes;

  Future<List<BatchImportItem>> preview(Iterable<String> paths) async {
    final sorted = paths.toSet().toList()
      ..sort((a, b) => _naturalCompare(p.basename(a), p.basename(b)));
    final result = <BatchImportItem>[];
    final existingNames = (await library.database.allLocalAssets())
        .map((asset) => asset.originalName.toLowerCase())
        .toSet();
    final seenNames = <String>{};
    for (var index = 0; index < sorted.length; index++) {
      final name = p.basename(sorted[index]).toLowerCase();
      final warning = existingNames.contains(name)
          ? 'A file with this name is already imported; review before adding another copy.'
          : !seenNames.add(name)
          ? 'Duplicate filename in this batch.'
          : null;
      result.add(
        BatchImportItem(
          sourcePath: sorted[index],
          label: '${index + 1}',
          probe: await probes.probe(sorted[index]),
          warning: warning,
        ),
      );
    }
    return result;
  }

  Future<CanonicalMediaId> importManga({
    required String reviewedTitle,
    required List<BatchImportItem> items,
    CanonicalMediaId? attachTo,
  }) => _commit(reviewedTitle, items, attachTo, manga: true);

  Future<CanonicalMediaId> importVideos({
    required String reviewedTitle,
    required List<BatchImportItem> items,
    CanonicalMediaId? attachTo,
  }) => _commit(reviewedTitle, items, attachTo, manga: false);

  Future<CanonicalMediaId> _commit(
    String title,
    List<BatchImportItem> items,
    CanonicalMediaId? attachTo, {
    required bool manga,
  }) async {
    if (title.trim().isEmpty || items.isEmpty) {
      throw const FormatException('Review a title and at least one file.');
    }
    CanonicalMediaId? mediaId = attachTo;
    for (final item in items) {
      final request = LocalImportRequest(
        sourcePath: item.sourcePath,
        title: title.trim(),
        installmentLabel: item.label.trim(),
        attachToMediaId: mediaId,
      );
      mediaId = manga
          ? await library.importManga(request)
          : await library.importVideo(request);
    }
    return mediaId!;
  }
}

bool _isImage(String path) => const {
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
}.contains(p.extension(path).toLowerCase());

int _naturalCompare(String left, String right) {
  final pattern = RegExp(r'(\d+)|(\D+)');
  final a = pattern.allMatches(left.toLowerCase()).map((m) => m[0]!).toList();
  final b = pattern.allMatches(right.toLowerCase()).map((m) => m[0]!).toList();
  for (var i = 0; i < a.length && i < b.length; i++) {
    final ai = int.tryParse(a[i]);
    final bi = int.tryParse(b[i]);
    final comparison = ai != null && bi != null
        ? ai.compareTo(bi)
        : a[i].compareTo(b[i]);
    if (comparison != 0) return comparison;
  }
  return a.length.compareTo(b.length);
}
