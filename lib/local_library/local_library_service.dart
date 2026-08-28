import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/media.dart';
import '../canonical/domain/user_state.dart';
import '../canonical/persistence/canonical_database.dart';
import 'local_asset.dart';
import '../security/archive_safety.dart';

const importedMangaProviderId = ProviderId('local-import-manga');
const importedVideoProviderId = ProviderId('local-import-video');

class LocalStorageSummary {
  const LocalStorageSummary({
    required this.mangaBytes,
    required this.videoBytes,
    required this.assetCount,
    required this.missingCount,
  });
  final int mangaBytes;
  final int videoBytes;
  final int assetCount;
  final int missingCount;
}

class LocalCleanupResult {
  const LocalCleanupResult({
    required this.filesRemoved,
    required this.bytesFreed,
  });
  final int filesRemoved;
  final int bytesFreed;
}

class LocalImportRequest {
  const LocalImportRequest({
    required this.sourcePath,
    required this.title,
    required this.installmentLabel,
    this.attachToMediaId,
    this.volumeLabel,
  });
  final String sourcePath;
  final String title;
  final String installmentLabel;
  final CanonicalMediaId? attachToMediaId;
  final String? volumeLabel;
}

class LocalLibraryService {
  LocalLibraryService(this.database, {Directory? root})
    : _configuredRoot = root;
  final CanonicalDatabase database;
  final Directory? _configuredRoot;
  static int _counter = 0;

  Future<Directory> get root async =>
      _configuredRoot ??
      Directory(
        '${(await getApplicationSupportDirectory()).path}/local-library',
      );

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${++_counter}';

  Future<CanonicalMediaId> importManga(LocalImportRequest request) async {
    final source = File(request.sourcePath);
    if (!await source.exists() ||
        p.extension(source.path).toLowerCase() != '.cbz') {
      throw const FormatException('Choose a readable CBZ archive.');
    }
    try {
      final archive = await decodeArchiveFileSafely(
        source,
        ArchiveSafetyLimits.cbz,
      );
      if (!archive.any((entry) => entry.isFile && _isImage(entry.name))) {
        throw const FormatException('The CBZ contains no supported images.');
      }
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw FormatException('The CBZ archive is corrupt: $error');
    }
    return _importFile(request, source, LocalAssetKind.mangaArchive);
  }

  Future<CanonicalMediaId> importMangaFolder(LocalImportRequest request) async {
    final directory = Directory(request.sourcePath);
    if (!await directory.exists()) {
      throw const FormatException('Choose a readable image folder.');
    }
    final files = await directory
        .list(recursive: false, followLinks: false)
        .where((entry) => entry is File && _isImage(entry.path))
        .cast<File>()
        .toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    if (files.isEmpty) {
      throw const FormatException('The folder contains no supported images.');
    }
    final base = await root;
    await base.create(recursive: true);
    final prepared = File('${base.path}/.folder-import-${_id('prepare')}.cbz');
    try {
      final archive = Archive();
      for (final file in files) {
        archive.add(
          ArchiveFile.bytes(p.basename(file.path), await file.readAsBytes()),
        );
      }
      await prepared.writeAsBytes(ZipEncoder().encode(archive), flush: true);
      return await importManga(
        LocalImportRequest(
          sourcePath: prepared.path,
          title: request.title,
          installmentLabel: request.installmentLabel,
          attachToMediaId: request.attachToMediaId,
          volumeLabel: request.volumeLabel,
        ),
      );
    } finally {
      if (await prepared.exists()) await prepared.delete();
    }
  }

  Future<CanonicalMediaId> importVideo(LocalImportRequest request) async {
    final source = File(request.sourcePath);
    final extension = p.extension(source.path).toLowerCase();
    if (!await source.exists() ||
        !const {'.mp4', '.webm', '.mkv', '.mov'}.contains(extension)) {
      throw const FormatException('Choose a supported readable video file.');
    }
    if (await source.length() == 0) {
      throw const FormatException('The selected video is empty.');
    }
    return _importFile(request, source, LocalAssetKind.video);
  }

  Future<CanonicalMediaId> _importFile(
    LocalImportRequest request,
    File source,
    LocalAssetKind kind,
  ) async {
    final assetId = LocalAssetId(_id('asset'));
    final mediaId = request.attachToMediaId ?? CanonicalMediaId(_id('media'));
    final installmentId = kind == LocalAssetKind.video
        ? CanonicalEpisodeId(_id('episode'))
        : CanonicalChapterId(_id('chapter'));
    final provider = kind == LocalAssetKind.video
        ? importedVideoProviderId
        : importedMangaProviderId;
    final externalId = _id('binding');
    final base = await root;
    await base.create(recursive: true);
    final relative = 'assets/${assetId.value}/${p.basename(source.path)}';
    final destination = File('${base.path}/$relative');
    final staging = File('${base.path}/.partial-${assetId.value}');
    try {
      await source.openRead().pipe(staging.openWrite());
      await destination.parent.create(recursive: true);
      await staging.rename(destination.path);
      final now = DateTime.now().toUtc();
      await database.transaction(() async {
        if (request.attachToMediaId == null) {
          final provenance = FieldProvenance(providerId: provider);
          await database.saveMedia(
            kind == LocalAssetKind.video
                ? CanonicalAnime(
                    id: mediaId,
                    title: SourcedValue(
                      value: request.title,
                      provenance: provenance,
                    ),
                    status: CanonicalMediaStatus.unknown,
                    format: AnimeFormat.unknown,
                  )
                : CanonicalManga(
                    id: mediaId,
                    title: SourcedValue(
                      value: request.title,
                      provenance: provenance,
                    ),
                    status: CanonicalMediaStatus.unknown,
                  ),
          );
        } else {
          final attached = await database.media(mediaId);
          if (attached == null) {
            throw StateError('The selected canonical media no longer exists.');
          }
          final expectedKind = kind == LocalAssetKind.video
              ? CanonicalMediaKind.anime
              : CanonicalMediaKind.manga;
          if (attached.kind != expectedKind) {
            throw StateError(
              'The imported installment has the wrong media kind.',
            );
          }
        }
        final existingMediaBinding = (await database.mediaBindingsFor(
          mediaId,
        )).where((binding) => binding.providerId == provider).firstOrNull;
        if (existingMediaBinding == null) {
          await database.saveMediaBinding(
            MediaSourceBinding(
              canonicalId: mediaId,
              providerId: provider,
              externalId: _id('local-media'),
            ),
          );
        }
        if (kind == LocalAssetKind.video) {
          await database.saveEpisode(
            CanonicalEpisode(
              id: installmentId as CanonicalEpisodeId,
              mediaId: mediaId,
              label: EpisodeLabel.parse(request.installmentLabel),
            ),
          );
          await database.saveEpisodeBinding(
            EpisodeSourceBinding(
              canonicalId: installmentId,
              providerId: provider,
              externalId: externalId,
              relativeLocator: destination.path,
            ),
          );
        } else {
          await database.saveChapter(
            CanonicalChapter(
              id: installmentId as CanonicalChapterId,
              mediaId: mediaId,
              number: ChapterNumber.parse(request.installmentLabel),
              volumeLabel: request.volumeLabel,
            ),
          );
          await database.saveChapterBinding(
            ChapterSourceBinding(
              canonicalId: installmentId,
              providerId: provider,
              externalId: externalId,
              relativeLocator: destination.path,
            ),
          );
        }
        await database.saveLocalAsset(
          LocalAsset(
            id: assetId,
            kind: kind,
            ownership: LocalAssetOwnership.appOwnedCopy,
            state: LocalAssetState.available,
            providerId: provider,
            bindingExternalId: externalId,
            mediaId: mediaId,
            installmentId: installmentId.value,
            originalName: p.basename(source.path),
            managedRelativePath: relative,
            sizeBytes: await destination.length(),
            createdAt: now,
            updatedAt: now,
          ),
        );
        final current = await database.libraryEntry(mediaId);
        await database.saveLibraryEntry(
          CanonicalLibraryEntry(
            mediaId: mediaId,
            isSaved: true,
            isFavorite: current?.isFavorite ?? false,
            status: current?.status ?? CanonicalLibraryStatus.inProgress,
            createdAt: current?.createdAt ?? now,
            updatedAt: now,
          ),
        );
      });
      return mediaId;
    } on Object {
      if (await staging.exists()) await staging.delete();
      if (await destination.exists()) await destination.delete();
      rethrow;
    }
  }

  Future<List<LocalAsset>> refreshStates() async {
    final base = await root;
    final values = await database.allLocalAssets();
    for (final asset in values) {
      final relative = asset.managedRelativePath;
      final file = relative == null ? null : File('${base.path}/$relative');
      final state = await _assetState(asset, file);
      final available = state == LocalAssetState.available;
      if (state != asset.state) {
        await database.saveLocalAsset(
          LocalAsset(
            id: asset.id,
            kind: asset.kind,
            ownership: asset.ownership,
            state: state,
            providerId: asset.providerId,
            bindingExternalId: asset.bindingExternalId,
            mediaId: asset.mediaId,
            installmentId: asset.installmentId,
            originalName: asset.originalName,
            managedRelativePath: asset.managedRelativePath,
            sizeBytes: available
                ? await File('${base.path}/$relative').length()
                : asset.sizeBytes,
            createdAt: asset.createdAt,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }
    }
    return database.allLocalAssets();
  }

  Future<void> repair(LocalAsset asset, String replacementPath) async {
    final replacement = File(replacementPath);
    if (!await replacement.exists()) {
      throw const FormatException('Replacement file is missing.');
    }
    if (asset.kind == LocalAssetKind.video) {
      final extension = p.extension(replacement.path).toLowerCase();
      if (!const {'.mp4', '.webm', '.mkv', '.mov'}.contains(extension) ||
          await replacement.length() == 0) {
        throw const FormatException('The replacement video is unsupported.');
      }
    } else {
      try {
        final archive = await decodeArchiveFileSafely(
          replacement,
          ArchiveSafetyLimits.cbz,
        );
        if (!archive.any((entry) => entry.isFile && _isImage(entry.name))) {
          throw const FormatException(
            'The replacement CBZ has no supported images.',
          );
        }
      } on FormatException {
        rethrow;
      } on Object catch (error) {
        throw FormatException('The replacement CBZ is corrupt: $error');
      }
    }
    final base = await root;
    final relative =
        asset.managedRelativePath ??
        'assets/${asset.id.value}/${p.basename(replacement.path)}';
    final destination = File('${base.path}/$relative');
    final staging = File('${destination.path}.partial');
    try {
      await replacement.openRead().pipe(staging.openWrite());
      if (await destination.exists()) await destination.delete();
      await staging.rename(destination.path);
      final now = DateTime.now().toUtc();
      await database.transaction(() async {
        if (asset.kind == LocalAssetKind.video) {
          await (database.update(database.canonicalEpisodeBindings)..where(
                (row) =>
                    row.providerId.equals(asset.providerId.value) &
                    row.externalId.equals(asset.bindingExternalId),
              ))
              .write(
                CanonicalEpisodeBindingsCompanion(
                  relativeLocator: Value(destination.path),
                ),
              );
        } else {
          await (database.update(database.canonicalChapterBindings)..where(
                (row) =>
                    row.providerId.equals(asset.providerId.value) &
                    row.externalId.equals(asset.bindingExternalId),
              ))
              .write(
                CanonicalChapterBindingsCompanion(
                  relativeLocator: Value(destination.path),
                ),
              );
        }
        await database.saveLocalAsset(
          LocalAsset(
            id: asset.id,
            kind: asset.kind,
            ownership: asset.ownership,
            state: LocalAssetState.available,
            providerId: asset.providerId,
            bindingExternalId: asset.bindingExternalId,
            mediaId: asset.mediaId,
            installmentId: asset.installmentId,
            originalName: asset.originalName,
            managedRelativePath: relative,
            sizeBytes: await destination.length(),
            createdAt: asset.createdAt,
            updatedAt: now,
          ),
        );
      });
    } on Object {
      if (await staging.exists()) await staging.delete();
      rethrow;
    }
  }

  Future<void> removeSource(
    LocalAsset asset, {
    required bool deletePhysical,
  }) async {
    if (deletePhysical && asset.ownership == LocalAssetOwnership.appOwnedCopy) {
      final relative = asset.managedRelativePath;
      if (relative != null) {
        final file = File('${(await root).path}/$relative');
        if (await file.exists()) await file.delete();
      }
    }
    await database.transaction(() async {
      if (asset.kind == LocalAssetKind.video) {
        await database.deleteEpisodeBindingExact(
          asset.providerId,
          asset.bindingExternalId,
        );
      } else {
        await database.deleteChapterBindingExact(
          asset.providerId,
          asset.bindingExternalId,
        );
      }
      await database.deleteLocalAssetRecord(asset.id);
      final remaining = (await database.allLocalAssets()).any(
        (value) =>
            value.mediaId == asset.mediaId &&
            value.providerId == asset.providerId,
      );
      if (!remaining) {
        final mediaBindings = await database.mediaBindingsFor(asset.mediaId);
        for (final binding in mediaBindings.where(
          (value) => value.providerId == asset.providerId,
        )) {
          await database.deleteMediaBindingExact(
            binding.providerId,
            binding.externalId,
          );
        }
      }
    });
  }

  Future<void> reattach(
    LocalAsset asset, {
    required String targetInstallmentId,
  }) async {
    if (targetInstallmentId == asset.installmentId) return;
    await database.transaction(() async {
      if (asset.kind == LocalAssetKind.video) {
        final target = await database.episode(
          CanonicalEpisodeId(targetInstallmentId),
        );
        if (target == null || target.mediaId != asset.mediaId) {
          throw StateError('Choose an episode from the same anime.');
        }
        final occupied = (await database.episodeBindingsFor(
          target.id,
        )).any((binding) => binding.providerId == asset.providerId);
        if (occupied) {
          throw StateError('That episode already has this local source.');
        }
        await (database.update(database.canonicalEpisodeBindings)..where(
              (row) =>
                  row.providerId.equals(asset.providerId.value) &
                  row.externalId.equals(asset.bindingExternalId),
            ))
            .write(
              CanonicalEpisodeBindingsCompanion(
                canonicalId: Value(target.id.value),
              ),
            );
        await (database.update(database.animeSourcePlaybackResumes)..where(
              (row) =>
                  row.providerId.equals(asset.providerId.value) &
                  row.episodeExternalId.equals(asset.bindingExternalId),
            ))
            .write(
              AnimeSourcePlaybackResumesCompanion(
                episodeId: Value(target.id.value),
              ),
            );
      } else {
        final target = await database.chapter(
          CanonicalChapterId(targetInstallmentId),
        );
        if (target == null || target.mediaId != asset.mediaId) {
          throw StateError('Choose a chapter from the same manga.');
        }
        final occupied = (await database.chapterBindingsFor(
          target.id,
        )).any((binding) => binding.providerId == asset.providerId);
        if (occupied) {
          throw StateError('That chapter already has this local source.');
        }
        await (database.update(database.canonicalChapterBindings)..where(
              (row) =>
                  row.providerId.equals(asset.providerId.value) &
                  row.externalId.equals(asset.bindingExternalId),
            ))
            .write(
              CanonicalChapterBindingsCompanion(
                canonicalId: Value(target.id.value),
              ),
            );
        await (database.update(database.mangaSourcePageResumes)..where(
              (row) =>
                  row.providerId.equals(asset.providerId.value) &
                  row.chapterExternalId.equals(asset.bindingExternalId),
            ))
            .write(
              MangaSourcePageResumesCompanion(
                chapterId: Value(target.id.value),
              ),
            );
      }
      await database.saveLocalAsset(
        LocalAsset(
          id: asset.id,
          kind: asset.kind,
          ownership: asset.ownership,
          state: asset.state,
          providerId: asset.providerId,
          bindingExternalId: asset.bindingExternalId,
          mediaId: asset.mediaId,
          installmentId: targetInstallmentId,
          originalName: asset.originalName,
          managedRelativePath: asset.managedRelativePath,
          sizeBytes: asset.sizeBytes,
          createdAt: asset.createdAt,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    });
  }

  Future<LocalStorageSummary> storageSummary() async {
    final assets = await refreshStates();
    var manga = 0;
    var video = 0;
    for (final item in assets.where(
      (item) => item.ownership == LocalAssetOwnership.appOwnedCopy,
    )) {
      if (item.kind == LocalAssetKind.video) {
        video += item.sizeBytes ?? 0;
      } else {
        manga += item.sizeBytes ?? 0;
      }
    }
    return LocalStorageSummary(
      mangaBytes: manga,
      videoBytes: video,
      assetCount: assets.length,
      missingCount: assets
          .where((item) => item.state == LocalAssetState.missing)
          .length,
    );
  }

  Future<LocalCleanupResult> clearRegenerableData() async {
    final base = await root;
    if (!await base.exists()) {
      return const LocalCleanupResult(filesRemoved: 0, bytesFreed: 0);
    }
    var removed = 0;
    var bytes = 0;
    final cache = Directory('${base.path}/thumbnail-cache');
    if (await cache.exists()) {
      for (final entry
          in (await cache.list(recursive: true).toList()).whereType<File>()) {
        bytes += await entry.length();
        removed++;
      }
      await cache.delete(recursive: true);
    }
    for (final entry
        in (await base.list(followLinks: false).toList()).whereType<File>()) {
      final name = p.basename(entry.path);
      if (!name.startsWith('.partial-') &&
          !name.startsWith('.folder-import-')) {
        continue;
      }
      bytes += await entry.length();
      removed++;
      await entry.delete();
    }
    return LocalCleanupResult(filesRemoved: removed, bytesFreed: bytes);
  }
}

Future<LocalAssetState> _assetState(LocalAsset asset, File? file) async {
  if (file == null || !await file.exists()) return LocalAssetState.missing;
  try {
    if (await file.length() == 0) return LocalAssetState.unreadable;
    if (asset.kind != LocalAssetKind.video) {
      final archive = await decodeArchiveFileSafely(
        file,
        ArchiveSafetyLimits.cbz,
      );
      if (!archive.any((entry) => entry.isFile && _isImage(entry.name))) {
        return LocalAssetState.unsupported;
      }
    }
    return LocalAssetState.available;
  } on Object {
    return LocalAssetState.unreadable;
  }
}

bool _isImage(String name) => const {
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
}.contains(p.extension(name).toLowerCase());
