import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/local_library/backup_service.dart';
import 'package:zanka_no_tachi/local_library/local_asset.dart';
import 'package:zanka_no_tachi/local_library/local_library_service.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/player/video_display_mode.dart';
import 'package:zanka_no_tachi/reader/reader_domain.dart';
import 'package:zanka_no_tachi/reader/reader_preferences_store.dart';

void main() {
  late Directory temp;
  setUp(
    () async => temp = await Directory.systemTemp.createTemp('zanka-backup'),
  );
  tearDown(() async => temp.delete(recursive: true));

  test(
    'beta.1 data-only backup restores into beta.2 with IDs and resumes intact',
    () async {
      final sourceDb = CanonicalDatabase(NativeDatabase.memory());
      final sourceService = LocalLibraryService(
        sourceDb,
        root: Directory('${temp.path}/source-assets'),
      );
      final video = File('${temp.path}/video.mp4')..writeAsBytesSync([1, 2, 3]);
      final mediaId = await sourceService.importVideo(
        LocalImportRequest(
          sourcePath: video.path,
          title: 'Portable anime',
          installmentLabel: 'Episode 1',
        ),
      );
      final episode = (await sourceDb.episodesFor(mediaId)).single;
      final episodeBinding = (await sourceDb.episodeBindingsFor(
        episode.id,
      )).single;
      await sourceDb.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: mediaId,
          episodeId: episode.id,
          position: const Duration(seconds: 2),
          duration: const Duration(seconds: 10),
          updatedAt: DateTime.utc(2026, 1, 2),
        ),
      );
      await sourceDb.saveAnimeSourcePlaybackResume(
        AnimeSourcePlaybackResume(
          mediaId: mediaId,
          episodeId: episode.id,
          providerId: episodeBinding.providerId,
          episodeExternalId: episodeBinding.externalId,
          position: const Duration(seconds: 2),
          duration: const Duration(seconds: 10),
          updatedAt: DateTime.utc(2026, 1, 2),
        ),
      );
      final sourceBackup = _backup(sourceDb, temp, 'source');
      await sourceBackup.readerPreferences.save(
        const ReaderPreferences(mode: ReaderMode.paged),
      );
      await sourceBackup.playerPreferences.save(
        const PlaybackPreferences(
          speed: 1.5,
          videoDisplayMode: VideoDisplayMode(
            fit: VideoDisplayFit.fillCrop,
            aspectPreset: VideoAspectPreset.twentyOneNine,
          ),
        ),
      );
      final backup = await sourceBackup.service.exportDataOnly(
        File('${temp.path}/state.zanka-backup.zip'),
      );
      final encoded = ZipDecoder().decodeBytes(await backup.readAsBytes());
      final manifest =
          jsonDecode(
                utf8.decode(
                  encoded.findFile('manifest.json')!.content as List<int>,
                ),
              )
              as Map<String, dynamic>;
      expect(manifest['version'], zankaBackupVersion);
      final state =
          jsonDecode(
                utf8.decode(
                  encoded.findFile('state.json')!.content as List<int>,
                ),
              )
              as Map<String, dynamic>;
      expect(
        state['playerPreferences'] as Map<String, dynamic>,
        isNot(contains('videoDisplayMode')),
      );

      final targetDb = CanonicalDatabase(
        NativeDatabase(File('${temp.path}/restored.sqlite')),
      );
      final targetBackup = _backup(targetDb, temp, 'target');
      await targetBackup.playerPreferences.save(
        const PlaybackPreferences(
          videoDisplayMode: VideoDisplayMode(
            fit: VideoDisplayFit.fitHeight,
            aspectPreset: VideoAspectPreset.square,
          ),
        ),
      );
      final result = await targetBackup.service.restore(backup);
      expect(result.conflicts, isEmpty);
      expect((await targetDb.media(mediaId))?.id, mediaId);
      expect(
        (await targetDb.animeProgress(mediaId))?.position,
        const Duration(seconds: 2),
      );
      expect(
        (await targetDb.animeSourcePlaybackResume(
          episodeBinding.providerId,
          episodeBinding.externalId,
        ))?.position,
        const Duration(seconds: 2),
      );
      expect(
        (await targetDb.allLocalAssets()).single.state,
        LocalAssetState.missing,
      );
      expect(
        (await targetBackup.readerPreferences.load()).mode,
        ReaderMode.paged,
      );
      expect((await targetBackup.playerPreferences.load()).speed, 1.5);
      expect(
        (await targetBackup.playerPreferences.load())
            .videoDisplayMode
            .aspectPreset,
        VideoAspectPreset.square,
      );
      await targetDb.close();

      final reopened = CanonicalDatabase(
        NativeDatabase(File('${temp.path}/restored.sqlite')),
      );
      expect((await reopened.media(mediaId))?.id, mediaId);
      expect((await reopened.libraryEntry(mediaId))?.isSaved, isTrue);
      await reopened.close();
      await sourceDb.close();
    },
  );

  test(
    'restore into existing library keeps newer progress and unions saved state',
    () async {
      final sourceDb = CanonicalDatabase(NativeDatabase.memory());
      final local = LocalLibraryService(
        sourceDb,
        root: Directory('${temp.path}/assets'),
      );
      final video = File('${temp.path}/v.mp4')..writeAsBytesSync([1]);
      final mediaId = await local.importVideo(
        LocalImportRequest(
          sourcePath: video.path,
          title: 'Conflict anime',
          installmentLabel: 'Episode 1',
        ),
      );
      final episode = (await sourceDb.episodesFor(mediaId)).single;
      await sourceDb.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: mediaId,
          episodeId: episode.id,
          position: const Duration(seconds: 3),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
      );
      final backup = await _backup(
        sourceDb,
        temp,
        'a',
      ).service.exportDataOnly(File('${temp.path}/conflict.zip'));

      final targetDb = CanonicalDatabase(NativeDatabase.memory());
      await _backup(targetDb, temp, 'b').service.restore(backup);
      await targetDb.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: mediaId,
          episodeId: episode.id,
          position: const Duration(seconds: 9),
          updatedAt: DateTime.utc(2026, 2, 1),
        ),
      );
      await _backup(targetDb, temp, 'b').service.restore(backup);
      expect(
        (await targetDb.animeProgress(mediaId))?.position,
        const Duration(seconds: 9),
      );
      expect((await targetDb.libraryEntry(mediaId))?.isSaved, isTrue);
      await sourceDb.close();
      await targetDb.close();
    },
  );

  test('corrupt and future backups are rejected without mutation', () async {
    final db = CanonicalDatabase(NativeDatabase.memory());
    final service = _backup(db, temp, 'invalid').service;
    final corrupt = File('${temp.path}/corrupt.zip')..writeAsStringSync('bad');
    await expectLater(
      service.restore(corrupt),
      throwsA(isA<FormatException>()),
    );
    final archive = Archive()
      ..add(
        ArchiveFile.string(
          'manifest.json',
          jsonEncode({'format': 'zanka-backup', 'version': 999}),
        ),
      )
      ..add(ArchiveFile.string('state.json', jsonEncode({'media': []})));
    final future = File('${temp.path}/future.zip')
      ..writeAsBytesSync(ZipEncoder().encode(archive));
    await expectLater(
      service.restore(future),
      throwsA(isA<UnsupportedError>()),
    );
    expect(await db.allMedia(), isEmpty);
    await db.close();
  });

  test('version 1 backup fixture remains supported and portable', () async {
    final sourceDb = CanonicalDatabase(NativeDatabase.memory());
    final local = LocalLibraryService(
      sourceDb,
      root: Directory('${temp.path}/v1-assets'),
    );
    final video = File('${temp.path}/legacy.mp4')..writeAsBytesSync([1]);
    final mediaId = await local.importVideo(
      LocalImportRequest(
        sourcePath: video.path,
        title: 'Legacy portable title',
        installmentLabel: 'Episode 1',
      ),
    );
    final latest = await _backup(
      sourceDb,
      temp,
      'legacy-source',
    ).service.exportDataOnly(File('${temp.path}/latest.zip'));
    final decoded = ZipDecoder().decodeBytes(await latest.readAsBytes());
    final state = decoded.findFile('state.json')!.content as List<int>;
    final legacyArchive = Archive()
      ..add(
        ArchiveFile.string(
          'manifest.json',
          jsonEncode({'format': 'zanka-backup', 'version': 1}),
        ),
      )
      ..add(ArchiveFile.bytes('state.json', state));
    final legacy = File('${temp.path}/v1-fixture.zip')
      ..writeAsBytesSync(ZipEncoder().encode(legacyArchive));

    final targetDb = CanonicalDatabase(NativeDatabase.memory());
    await _backup(targetDb, temp, 'legacy-target').service.restore(legacy);
    expect(
      (await targetDb.media(mediaId))?.title.value,
      'Legacy portable title',
    );
    expect(
      (await targetDb.allLocalAssets()).single.state,
      LocalAssetState.missing,
    );
    final archiveText = utf8.decode(state);
    expect(archiveText, isNot(contains(temp.path)));
    await sourceDb.close();
    await targetDb.close();
  });
}

({
  ZankaBackupService service,
  ReaderPreferencesStore readerPreferences,
  PlaybackPreferencesStore playerPreferences,
})
_backup(CanonicalDatabase db, Directory root, String name) {
  final reader = ReaderPreferencesStore(
    file: File('${root.path}/$name-reader.json'),
  );
  final player = PlaybackPreferencesStore(
    file: File('${root.path}/$name-player.json'),
  );
  return (
    service: ZankaBackupService(
      database: db,
      readerPreferences: reader,
      playerPreferences: player,
    ),
    readerPreferences: reader,
    playerPreferences: player,
  );
}
