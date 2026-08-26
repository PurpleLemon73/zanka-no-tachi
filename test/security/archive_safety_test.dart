import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/local_library/backup_service.dart';
import 'package:zanka_no_tachi/local_library/local_library_service.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/reader/reader_preferences_store.dart';
import 'package:zanka_no_tachi/security/archive_safety.dart';

void main() {
  late Directory temporary;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('zanka-security-');
  });
  tearDown(() async {
    await temporary.delete(recursive: true);
  });

  test('archive traversal and absolute paths are rejected', () {
    for (final name in [
      '../escape',
      'safe/../../escape',
      '/absolute',
      r'C:\escape',
    ]) {
      final archive = Archive()..add(ArchiveFile.bytes(name, [1]));
      expect(
        () => validateArchive(archive, ArchiveSafetyLimits.backup),
        throwsA(isA<UnsafeArchiveException>()),
        reason: name,
      );
    }
  });

  test('entry count and decompression limits are rejected', () {
    final crowded = Archive()
      ..add(ArchiveFile.bytes('one', [1]))
      ..add(ArchiveFile.bytes('two', [2]));
    expect(
      () => validateArchive(
        crowded,
        const ArchiveSafetyLimits(
          maximumInputBytes: 100,
          maximumExpandedBytes: 100,
          maximumEntryBytes: 10,
          maximumEntries: 1,
        ),
      ),
      throwsA(isA<UnsafeArchiveException>()),
    );
    final expanded = Archive()
      ..add(ArchiveFile.bytes('large', List.filled(5, 1)));
    expect(
      () => validateArchive(
        expanded,
        const ArchiveSafetyLimits(
          maximumInputBytes: 100,
          maximumExpandedBytes: 4,
          maximumEntryBytes: 10,
          maximumEntries: 2,
        ),
      ),
      throwsA(isA<UnsafeArchiveException>()),
    );
  });

  test('CBZ import rejects traversal even when it contains an image', () async {
    final file = File('${temporary.path}/unsafe.cbz');
    final archive = Archive()..add(ArchiveFile.bytes('../page.png', [1, 2, 3]));
    await file.writeAsBytes(ZipEncoder().encode(archive));
    final database = CanonicalDatabase(NativeDatabase.memory());
    final service = LocalLibraryService(
      database,
      root: Directory('${temporary.path}/library'),
    );
    await expectLater(
      service.importManga(
        LocalImportRequest(
          sourcePath: file.path,
          title: 'Unsafe',
          installmentLabel: '1',
        ),
      ),
      throwsA(isA<FormatException>()),
    );
    expect(await database.allMedia(), isEmpty);
    await database.close();
  });

  test('backup rejects traversal entries before state mutation', () async {
    final file = File('${temporary.path}/unsafe-backup.zip');
    final archive = Archive()
      ..add(
        ArchiveFile.string(
          'manifest.json',
          jsonEncode({'format': 'zanka-backup', 'version': 1}),
        ),
      )
      ..add(ArchiveFile.string('state.json', jsonEncode({'media': []})))
      ..add(ArchiveFile.string('../escaped.txt', 'no'));
    await file.writeAsBytes(ZipEncoder().encode(archive));
    final database = CanonicalDatabase(NativeDatabase.memory());
    final service = ZankaBackupService(
      database: database,
      readerPreferences: ReaderPreferencesStore(
        file: File('${temporary.path}/reader.json'),
      ),
      playerPreferences: PlaybackPreferencesStore(
        file: File('${temporary.path}/player.json'),
      ),
    );
    await expectLater(service.restore(file), throwsA(isA<FormatException>()));
    expect(await database.allMedia(), isEmpty);
    await database.close();
  });
}
