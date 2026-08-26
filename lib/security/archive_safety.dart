import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

class ArchiveSafetyLimits {
  const ArchiveSafetyLimits({
    required this.maximumInputBytes,
    required this.maximumExpandedBytes,
    required this.maximumEntryBytes,
    required this.maximumEntries,
  });

  final int maximumInputBytes;
  final int maximumExpandedBytes;
  final int maximumEntryBytes;
  final int maximumEntries;

  static const cbz = ArchiveSafetyLimits(
    maximumInputBytes: 512 * 1024 * 1024,
    maximumExpandedBytes: 1024 * 1024 * 1024,
    maximumEntryBytes: 64 * 1024 * 1024,
    maximumEntries: 10000,
  );

  static const backup = ArchiveSafetyLimits(
    maximumInputBytes: 32 * 1024 * 1024,
    maximumExpandedBytes: 64 * 1024 * 1024,
    maximumEntryBytes: 48 * 1024 * 1024,
    maximumEntries: 128,
  );
}

class UnsafeArchiveException implements FormatException {
  const UnsafeArchiveException(this.message);
  @override
  final String message;
  @override
  int? get offset => null;
  @override
  dynamic get source => null;
  @override
  String toString() => 'FormatException: $message';
}

Future<Archive> decodeArchiveFileSafely(
  File file,
  ArchiveSafetyLimits limits,
) async {
  if (!await file.exists()) {
    throw const UnsafeArchiveException('Archive file is missing.');
  }
  if (await file.length() > limits.maximumInputBytes) {
    throw const UnsafeArchiveException('Archive exceeds the safe input limit.');
  }
  final input = InputFileStream(file.path);
  try {
    final archive = ZipDecoder().decodeStream(input, verify: true);
    validateArchive(archive, limits);
    return archive;
  } finally {
    await input.close();
  }
}

void validateArchive(Archive archive, ArchiveSafetyLimits limits) {
  if (archive.files.isEmpty) {
    throw const UnsafeArchiveException('Archive contains no readable entries.');
  }
  if (archive.files.length > limits.maximumEntries) {
    throw const UnsafeArchiveException('Archive contains too many entries.');
  }
  var expanded = 0;
  final names = <String>{};
  for (final entry in archive.files) {
    _validateName(entry.name);
    if (!names.add(entry.name)) {
      throw const UnsafeArchiveException('Archive contains duplicate paths.');
    }
    if (!entry.isFile) continue;
    if (entry.size < 0 || entry.size > limits.maximumEntryBytes) {
      throw const UnsafeArchiveException(
        'Archive entry exceeds the safe limit.',
      );
    }
    expanded += entry.size;
    if (expanded > limits.maximumExpandedBytes) {
      throw const UnsafeArchiveException(
        'Archive expanded content exceeds the safe limit.',
      );
    }
  }
}

void _validateName(String value) {
  if (value.isEmpty || value.contains('\u0000')) {
    throw const UnsafeArchiveException('Archive contains an invalid path.');
  }
  final normalized = value.replaceAll('\\', '/');
  if (normalized.startsWith('/') ||
      normalized.startsWith('~/') ||
      RegExp(r'^[A-Za-z]:/').hasMatch(normalized) ||
      p.posix.normalize(normalized).split('/').contains('..') ||
      normalized.split('/').contains('..')) {
    throw const UnsafeArchiveException('Archive path traversal was rejected.');
  }
}
