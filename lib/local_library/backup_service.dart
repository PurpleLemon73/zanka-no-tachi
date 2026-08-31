import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/media.dart';
import '../canonical/domain/user_state.dart';
import '../canonical/persistence/canonical_database.dart';
import '../player/playback_preferences_store.dart';
import '../player/playback_domain.dart';
import '../reader/reader_preferences_store.dart';
import '../reader/reader_domain.dart';
import 'local_asset.dart';
import '../adapter_platform/adapter_descriptor.dart';
import '../adapter_platform/adapter_sdk.dart';
import '../adapter_platform/adapter_state.dart';
import '../security/archive_safety.dart';
import '../product_maturity/maturity_domain.dart';

/// Version 2 makes path portability and archive limits explicit. Version 1
/// remains readable because its state shape is a compatible subset.
const zankaBackupVersion = 3;

class BackupPreview {
  const BackupPreview({
    required this.version,
    required this.mediaCount,
    required this.libraryCount,
    required this.localAssetCount,
  });
  final int version;
  final int mediaCount;
  final int libraryCount;
  final int localAssetCount;
}

class RestoreResult {
  const RestoreResult({required this.preview, required this.conflicts});
  final BackupPreview preview;
  final List<String> conflicts;
}

class ZankaBackupService {
  const ZankaBackupService({
    required this.database,
    required this.readerPreferences,
    required this.playerPreferences,
  });
  final CanonicalDatabase database;
  final ReaderPreferencesStore readerPreferences;
  final PlaybackPreferencesStore playerPreferences;

  Future<File> exportDataOnly(File destination) async {
    final state = await _exportState();
    final archive = Archive()
      ..add(
        ArchiveFile.string(
          'manifest.json',
          jsonEncode({
            'format': 'zanka-backup',
            'version': zankaBackupVersion,
            'mode': 'data-only',
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          }),
        ),
      )
      ..add(ArchiveFile.string('state.json', jsonEncode(state)));
    await destination.parent.create(recursive: true);
    final temporary = File('${destination.path}.partial');
    try {
      await temporary.writeAsBytes(ZipEncoder().encode(archive), flush: true);
      if (await destination.exists()) await destination.delete();
      return await temporary.rename(destination.path);
    } on Object {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
  }

  Future<BackupPreview> preview(File file) async {
    final state = await _read(file);
    return _preview(state);
  }

  BackupPreview _preview(Map<String, dynamic> state) => BackupPreview(
    version: zankaBackupVersion,
    mediaCount: (state['media'] as List).length,
    libraryCount: (state['library'] as List).length,
    localAssetCount: (state['localAssets'] as List).length,
  );

  Future<RestoreResult> restore(File file) async {
    final state = await _read(file);
    final previewValue = _preview(state);
    final conflicts = <String>[];
    await database.transaction(() async {
      for (final value
          in (state['media'] as List).cast<Map<String, dynamic>>()) {
        final incoming = _mediaFromJson(value);
        final existing = await database.media(incoming.id);
        if (existing == null) await database.saveMedia(incoming);
      }
      for (final value
          in (state['chapters'] as List).cast<Map<String, dynamic>>()) {
        final id = CanonicalChapterId(value['id'] as String);
        if (await database.chapter(id) == null) {
          await database.saveChapter(
            CanonicalChapter(
              id: id,
              mediaId: CanonicalMediaId(value['mediaId'] as String),
              number: ChapterNumber.parse(value['label'] as String),
              title: value['title'] as String?,
              volumeLabel: value['volume'] as String?,
            ),
          );
        }
      }
      for (final value
          in (state['episodes'] as List).cast<Map<String, dynamic>>()) {
        final id = CanonicalEpisodeId(value['id'] as String);
        if (await database.episode(id) == null) {
          await database.saveEpisode(
            CanonicalEpisode(
              id: id,
              mediaId: CanonicalMediaId(value['mediaId'] as String),
              label: EpisodeLabel(
                rawLabel: value['label'] as String,
                number: (value['number'] as num?)?.toDouble(),
              ),
              title: value['title'] as String?,
              narrativeSeason: value['narrativeSeason'] as int?,
            ),
          );
        }
      }
      await _restoreBindings(state, conflicts);
      for (final value
          in (state['library'] as List).cast<Map<String, dynamic>>()) {
        final id = CanonicalMediaId(value['mediaId'] as String);
        final existing = await database.libraryEntry(id);
        final incomingUpdated = DateTime.parse(value['updatedAt'] as String);
        await database.saveLibraryEntry(
          CanonicalLibraryEntry(
            mediaId: id,
            isSaved: (value['isSaved'] as bool) || (existing?.isSaved ?? false),
            isFavorite:
                (value['isFavorite'] as bool) ||
                (existing?.isFavorite ?? false),
            status:
                existing != null && existing.updatedAt.isAfter(incomingUpdated)
                ? existing.status
                : CanonicalLibraryStatus.values.byName(
                    value['status'] as String,
                  ),
            createdAt:
                existing == null ||
                    DateTime.parse(
                      value['createdAt'] as String,
                    ).isBefore(existing.createdAt)
                ? DateTime.parse(value['createdAt'] as String)
                : existing.createdAt,
            updatedAt:
                existing != null && existing.updatedAt.isAfter(incomingUpdated)
                ? existing.updatedAt
                : incomingUpdated,
          ),
        );
      }
      await _restoreProgress(state);
      for (final value
          in (state['preferences'] as List).cast<Map<String, dynamic>>()) {
        final mediaId = CanonicalMediaId(value['mediaId'] as String);
        if (await database.preferredProvider(mediaId) == null) {
          await database.setPreferredProvider(
            mediaId,
            ProviderId(value['providerId'] as String),
          );
        }
      }
      for (final value
          in (state['mergeAudits'] as List).cast<Map<String, dynamic>>()) {
        final exists =
            await (database.select(database.canonicalMergeAudits)
                  ..where((row) => row.id.equals(value['id'] as String)))
                .getSingleOrNull();
        if (exists == null) {
          await database
              .into(database.canonicalMergeAudits)
              .insert(
                CanonicalMergeAuditsCompanion.insert(
                  id: value['id'] as String,
                  sourceId: value['sourceId'] as String,
                  targetId: value['targetId'] as String,
                  reason: value['reason'] as String,
                  snapshotJson: jsonEncode(value['snapshot']),
                  mergedFingerprint: value['mergedFingerprint'] as String,
                  conflictsJson: Value(jsonEncode(value['conflicts'])),
                  createdAt: DateTime.parse(value['createdAt'] as String),
                  undoneAt: Value(
                    value['undoneAt'] == null
                        ? null
                        : DateTime.parse(value['undoneAt'] as String),
                  ),
                ),
              );
        }
      }
      for (final value
          in (state['aliases'] as List).cast<Map<String, dynamic>>()) {
        final exists =
            await (database.select(database.canonicalMediaAliases)..where(
                  (row) =>
                      row.historicalId.equals(value['historicalId'] as String),
                ))
                .getSingleOrNull();
        if (exists == null) {
          await database
              .into(database.canonicalMediaAliases)
              .insert(
                CanonicalMediaAliasesCompanion.insert(
                  historicalId: value['historicalId'] as String,
                  targetId: value['targetId'] as String,
                  mergeAuditId: value['mergeAuditId'] as String,
                  createdAt: DateTime.parse(value['createdAt'] as String),
                ),
              );
        }
      }
      for (final value
          in (state['localAssets'] as List).cast<Map<String, dynamic>>()) {
        final id = LocalAssetId(value['id'] as String);
        if (await database.localAsset(id) == null) {
          await database.saveLocalAsset(
            LocalAsset(
              id: id,
              kind: LocalAssetKind.values.byName(value['kind'] as String),
              ownership: LocalAssetOwnership.values.byName(
                value['ownership'] as String,
              ),
              state: LocalAssetState.missing,
              providerId: ProviderId(value['providerId'] as String),
              bindingExternalId: value['bindingExternalId'] as String,
              mediaId: CanonicalMediaId(value['mediaId'] as String),
              installmentId: value['installmentId'] as String,
              originalName: value['originalName'] as String,
              sizeBytes: value['sizeBytes'] as int?,
              createdAt: DateTime.parse(value['createdAt'] as String),
              updatedAt: DateTime.now().toUtc(),
            ),
          );
        }
      }
      for (final value
          in ((state['adapterConfigurations'] as List?) ?? const [])
              .cast<Map<String, dynamic>>()) {
        final id = AdapterId(value['adapterId'] as String);
        final current = (await database.allAdapterConfigurations())
            .where((item) => item.adapterId == id)
            .firstOrNull;
        if (current == null) {
          final rawUrl = value['baseUrl'] as String?;
          final url = rawUrl == null ? null : Uri.tryParse(rawUrl);
          if (url == null ||
              (url.hasAuthority &&
                  const {'http', 'https'}.contains(url.scheme))) {
            await database.saveAdapterConfiguration(
              PersistedAdapterConfiguration(
                adapterId: id,
                enabled: value['enabled'] as bool,
                baseUrl: url,
                order: value['order'] as int,
                updatedAt: DateTime.parse(value['updatedAt'] as String),
              ),
            );
          }
        }
      }
      for (final value
          in ((state['enrichments'] as List?) ?? const [])
              .cast<Map<String, dynamic>>()) {
        final mediaId = CanonicalMediaId(value['mediaId'] as String);
        if (await database.media(mediaId) != null) {
          await database.saveEnrichment(
            mediaId,
            MetadataEnrichment(
              adapterId: AdapterId(value['adapterId'] as String),
              title: value['title'] as String?,
              description: value['description'] as String?,
              coverLocator: _portableLocator(value['coverLocator'] as String?),
              alternateTitles: (value['alternateTitles'] as List)
                  .cast<String>(),
              genres: (value['genres'] as List).cast<String>(),
            ),
          );
        }
      }
      for (final value
          in ((state['metadataOverrides'] as List?) ?? const [])
              .cast<Map<String, dynamic>>()) {
        final mediaId = CanonicalMediaId(value['mediaId'] as String);
        if (await database.media(mediaId) != null &&
            await database.metadataOverride(mediaId) == null) {
          await database.saveMetadataOverride(
            MetadataOverride(
              mediaId: mediaId,
              displayTitle: value['displayTitle'] as String?,
              description: value['description'] as String?,
              coverLocator: _portableLocator(value['coverLocator'] as String?),
              alternateTitles: (value['alternateTitles'] as List)
                  .cast<String>(),
              genres: (value['genres'] as List).cast<String>(),
              status: value['status'] == null
                  ? null
                  : CanonicalMediaStatus.values.byName(
                      value['status'] as String,
                    ),
              animeFormat: value['animeFormat'] == null
                  ? null
                  : AnimeFormat.values.byName(value['animeFormat'] as String),
              creatorOrStudio: value['creatorOrStudio'] as String?,
            ),
          );
        }
      }
      for (final value
          in ((state['chapterEdits'] as List?) ?? const [])
              .cast<Map<String, dynamic>>()) {
        final id = CanonicalChapterId(value['chapterId'] as String);
        if (await database.chapter(id) != null) {
          await database.saveChapterUserEdit(
            ChapterUserEdit(
              chapterId: id,
              rawLabel: value['rawLabel'] as String,
              kind: MangaInstallmentKind.values.byName(value['kind'] as String),
              volumeLabel: value['volumeLabel'] as String?,
              explicitOrder: (value['explicitOrder'] as num?)?.toDouble(),
              sourceDisplayLabel: value['sourceDisplayLabel'] as String?,
              updatedAt: DateTime.parse(value['updatedAt'] as String),
            ),
          );
        }
      }
      for (final value
          in ((state['episodeEdits'] as List?) ?? const [])
              .cast<Map<String, dynamic>>()) {
        final id = CanonicalEpisodeId(value['episodeId'] as String);
        if (await database.episode(id) != null) {
          await database.saveEpisodeUserEdit(
            EpisodeUserEdit(
              episodeId: id,
              rawLabel: value['rawLabel'] as String,
              number: (value['number'] as num?)?.toDouble(),
              kind: AnimeInstallmentKind.values.byName(value['kind'] as String),
              narrativeSeason: value['narrativeSeason'] as int?,
              explicitOrder: (value['explicitOrder'] as num?)?.toDouble(),
              sourceDisplayLabel: value['sourceDisplayLabel'] as String?,
              updatedAt: DateTime.parse(value['updatedAt'] as String),
            ),
          );
        }
      }
      for (final value
          in ((state['chapterCompletions'] as List?) ?? const [])
              .cast<Map<String, dynamic>>()) {
        final id = CanonicalChapterId(value['chapterId'] as String);
        if (await database.chapter(id) != null) {
          await database.setChapterCompleted(
            id,
            origin: CompletionOrigin.values.byName(value['origin'] as String),
            at: DateTime.parse(value['completedAt'] as String),
          );
        }
      }
      for (final value
          in ((state['episodeCompletions'] as List?) ?? const [])
              .cast<Map<String, dynamic>>()) {
        final id = CanonicalEpisodeId(value['episodeId'] as String);
        if (await database.episode(id) != null) {
          await database.setEpisodeCompleted(
            id,
            origin: CompletionOrigin.values.byName(value['origin'] as String),
            at: DateTime.parse(value['completedAt'] as String),
          );
        }
      }
    });
    final reader = state['readerPreferences'] as Map<String, dynamic>?;
    if (reader != null) {
      await readerPreferences.save(ReaderPreferences.fromJson(reader));
    }
    final player = state['playerPreferences'] as Map<String, dynamic>?;
    if (player != null) {
      final localDisplayMode =
          (await playerPreferences.load()).videoDisplayMode;
      await playerPreferences.save(
        PlaybackPreferences.fromJson(
          player,
        ).copyWith(videoDisplayMode: localDisplayMode),
      );
    }
    return RestoreResult(preview: previewValue, conflicts: conflicts);
  }

  Future<Map<String, dynamic>> _read(File file) async {
    try {
      final archive = await decodeArchiveFileSafely(
        file,
        ArchiveSafetyLimits.backup,
      );
      final manifestFile = archive.findFile('manifest.json');
      final stateFile = archive.findFile('state.json');
      if (manifestFile == null || stateFile == null) {
        throw const FormatException('Missing backup manifest/state.');
      }
      final manifest =
          jsonDecode(utf8.decode(manifestFile.content as List<int>))
              as Map<String, dynamic>;
      if (manifest['format'] != 'zanka-backup') {
        throw const FormatException('Not a Zanka backup.');
      }
      final version = manifest['version'];
      if (version is! int || version > zankaBackupVersion) {
        throw UnsupportedError('Backup version $version is not supported.');
      }
      if (version < 1) throw const FormatException('Invalid backup version.');
      final state = jsonDecode(utf8.decode(stateFile.content as List<int>));
      const requiredLists = [
        'media',
        'chapters',
        'episodes',
        'mediaBindings',
        'chapterBindings',
        'episodeBindings',
        'library',
        'mangaProgress',
        'animeProgress',
        'mangaResumes',
        'animeResumes',
        'preferences',
        'mergeAudits',
        'aliases',
        'localAssets',
      ];
      if (state is! Map<String, dynamic> ||
          requiredLists.any((key) => state[key] is! List)) {
        throw const FormatException('Malformed backup state.');
      }
      return state;
    } on UnsupportedError {
      rethrow;
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw FormatException('The backup is corrupt: $error');
    }
  }

  Future<Map<String, Object?>> _exportState() async {
    final media = <CanonicalMedia>[];
    for (final row
        in await database.select(database.canonicalMediaRecords).get()) {
      final value = await database.media(CanonicalMediaId(row.id));
      if (value != null) media.add(value);
    }
    final chapters = <CanonicalChapter>[];
    final episodes = <CanonicalEpisode>[];
    for (final item in media) {
      chapters.addAll(await database.chaptersFor(item.id));
      episodes.addAll(await database.episodesFor(item.id));
    }
    return {
      'media': media.map(_mediaToJson).toList(),
      'chapters': chapters
          .map(
            (value) => {
              'id': value.id.value,
              'mediaId': value.mediaId.value,
              'label': value.number.rawLabel,
              'title': value.title,
              'volume': value.volumeLabel,
            },
          )
          .toList(),
      'episodes': episodes
          .map(
            (value) => {
              'id': value.id.value,
              'mediaId': value.mediaId.value,
              'label': value.label.rawLabel,
              'number': value.label.number,
              'title': value.title,
              'narrativeSeason': value.narrativeSeason,
            },
          )
          .toList(),
      'mediaBindings': [
        for (final item in media)
          for (final value in await database.mediaBindingsFor(item.id))
            _bindingJson(value),
      ],
      'chapterBindings': [
        for (final item in chapters)
          for (final value in await database.chapterBindingsFor(item.id))
            _bindingJson(value),
      ],
      'episodeBindings': [
        for (final item in episodes)
          for (final value in await database.episodeBindingsFor(item.id))
            _bindingJson(value),
      ],
      'library': (await database.allLibraryEntries())
          .map(_libraryJson)
          .toList(),
      'mangaProgress': (await database.allMangaProgress())
          .map(
            (value) => {
              'mediaId': value.mediaId.value,
              'chapterId': value.chapterId.value,
              'pageIndex': value.pageIndex,
              'totalPages': value.totalPages,
              'updatedAt': value.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'animeProgress': (await database.allAnimeProgress())
          .map(
            (value) => {
              'mediaId': value.mediaId.value,
              'episodeId': value.episodeId.value,
              'position': value.position.inMilliseconds,
              'duration': value.duration?.inMilliseconds,
              'updatedAt': value.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'mangaResumes':
          (await database.select(database.mangaSourcePageResumes).get())
              .map(
                (value) => {
                  'mediaId': value.mediaId,
                  'chapterId': value.chapterId,
                  'providerId': value.providerId,
                  'chapterExternalId': value.chapterExternalId,
                  'pageIndex': value.pageIndex,
                  'totalPages': value.totalPages,
                  'updatedAt': value.updatedAt.toIso8601String(),
                },
              )
              .toList(),
      'animeResumes':
          (await database.select(database.animeSourcePlaybackResumes).get())
              .map(
                (value) => {
                  'mediaId': value.mediaId,
                  'episodeId': value.episodeId,
                  'providerId': value.providerId,
                  'episodeExternalId': value.episodeExternalId,
                  'positionMilliseconds': value.positionMilliseconds,
                  'durationMilliseconds': value.durationMilliseconds,
                  'updatedAt': value.updatedAt.toIso8601String(),
                },
              )
              .toList(),
      'preferences':
          (await database.select(database.preferredMediaSources).get())
              .map(
                (value) => {
                  'mediaId': value.mediaId,
                  'providerId': value.providerId,
                },
              )
              .toList(),
      'aliases': (await database.select(database.canonicalMediaAliases).get())
          .map(
            (value) => {
              'historicalId': value.historicalId,
              'targetId': value.targetId,
              'mergeAuditId': value.mergeAuditId,
              'createdAt': value.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'mergeAudits':
          (await database.select(database.canonicalMergeAudits).get())
              .map(
                (value) => {
                  'id': value.id,
                  'sourceId': value.sourceId,
                  'targetId': value.targetId,
                  'reason': value.reason,
                  'snapshot': _sanitizeSnapshot(jsonDecode(value.snapshotJson)),
                  'mergedFingerprint': value.mergedFingerprint,
                  'conflicts': jsonDecode(value.conflictsJson),
                  'createdAt': value.createdAt.toIso8601String(),
                  'undoneAt': value.undoneAt?.toIso8601String(),
                },
              )
              .toList(),
      'localAssets': (await database.allLocalAssets())
          .map(
            (value) => {
              'id': value.id.value,
              'kind': value.kind.name,
              'ownership': value.ownership.name,
              'providerId': value.providerId.value,
              'bindingExternalId': value.bindingExternalId,
              'mediaId': value.mediaId.value,
              'installmentId': value.installmentId,
              'originalName': value.originalName,
              'sizeBytes': value.sizeBytes,
              'createdAt': value.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'adapterConfigurations': (await database.allAdapterConfigurations())
          .map(
            (value) => {
              'adapterId': value.adapterId.value,
              'enabled': value.enabled,
              'baseUrl': value.baseUrl?.toString(),
              'order': value.order,
              'updatedAt': value.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'enrichments': [
        for (final item in media)
          for (final value in await database.enrichmentsFor(item.id))
            {
              'mediaId': item.id.value,
              'adapterId': value.adapterId.value,
              'title': value.title,
              'description': value.description,
              'coverLocator': _portableLocator(value.coverLocator),
              'alternateTitles': value.alternateTitles,
              'genres': value.genres,
            },
      ],
      'metadataOverrides': [
        for (final item in media)
          if (await database.metadataOverride(item.id) case final value?)
            {
              'mediaId': item.id.value,
              'displayTitle': value.displayTitle,
              'description': value.description,
              'coverLocator': _portableLocator(value.coverLocator),
              'alternateTitles': value.alternateTitles,
              'genres': value.genres,
              'status': value.status?.name,
              'animeFormat': value.animeFormat?.name,
              'creatorOrStudio': value.creatorOrStudio,
            },
      ],
      'chapterEdits':
          (await database.select(database.chapterUserEditRecords).get())
              .map(
                (value) => {
                  'chapterId': value.chapterId,
                  'rawLabel': value.rawLabel,
                  'kind': value.kind,
                  'volumeLabel': value.volumeLabel,
                  'explicitOrder': value.explicitOrder,
                  'sourceDisplayLabel': value.sourceDisplayLabel,
                  'updatedAt': value.updatedAt.toIso8601String(),
                },
              )
              .toList(),
      'episodeEdits':
          (await database.select(database.episodeUserEditRecords).get())
              .map(
                (value) => {
                  'episodeId': value.episodeId,
                  'rawLabel': value.rawLabel,
                  'number': value.number,
                  'kind': value.kind,
                  'narrativeSeason': value.narrativeSeason,
                  'explicitOrder': value.explicitOrder,
                  'sourceDisplayLabel': value.sourceDisplayLabel,
                  'updatedAt': value.updatedAt.toIso8601String(),
                },
              )
              .toList(),
      'chapterCompletions':
          (await database.select(database.chapterCompletionRecords).get())
              .map(
                (value) => {
                  'chapterId': value.chapterId,
                  'completedAt': value.completedAt.toIso8601String(),
                  'origin': value.origin,
                },
              )
              .toList(),
      'episodeCompletions':
          (await database.select(database.episodeCompletionRecords).get())
              .map(
                (value) => {
                  'episodeId': value.episodeId,
                  'completedAt': value.completedAt.toIso8601String(),
                  'origin': value.origin,
                },
              )
              .toList(),
      'readerPreferences': (await readerPreferences.load()).toJson(),
      'playerPreferences': (await playerPreferences.load()).toBackupJson(),
    };
  }

  Future<void> _restoreBindings(
    Map<String, dynamic> state,
    List<String> conflicts,
  ) async {
    for (final value
        in (state['mediaBindings'] as List).cast<Map<String, dynamic>>()) {
      final provider = ProviderId(value['providerId'] as String);
      final existing = await database.mediaBinding(
        provider,
        value['externalId'] as String,
      );
      final canonical = CanonicalMediaId(value['canonicalId'] as String);
      if (existing != null && existing != canonical) {
        conflicts.add(
          'Media binding ${provider.value}/${value['externalId']} already belongs to another item.',
        );
      } else if (existing == null) {
        await database.saveMediaBinding(
          MediaSourceBinding(
            canonicalId: canonical,
            providerId: provider,
            externalId: value['externalId'] as String,
            relativeLocator: value['locator'] as String?,
          ),
        );
      }
    }
    for (final value
        in (state['chapterBindings'] as List).cast<Map<String, dynamic>>()) {
      final provider = ProviderId(value['providerId'] as String);
      final external = value['externalId'] as String;
      final canonical = CanonicalChapterId(value['canonicalId'] as String);
      final existing = await database.chapterBinding(provider, external);
      if (existing != null && existing != canonical) {
        conflicts.add(
          'Chapter binding ${provider.value}/$external conflicted.',
        );
      } else if (existing == null) {
        await database.saveChapterBinding(
          ChapterSourceBinding(
            canonicalId: canonical,
            providerId: provider,
            externalId: external,
            relativeLocator: value['locator'] as String?,
          ),
        );
      }
    }
    for (final value
        in (state['episodeBindings'] as List).cast<Map<String, dynamic>>()) {
      final provider = ProviderId(value['providerId'] as String);
      final external = value['externalId'] as String;
      final canonical = CanonicalEpisodeId(value['canonicalId'] as String);
      final existing = await database.episodeBinding(provider, external);
      if (existing != null && existing != canonical) {
        conflicts.add(
          'Episode binding ${provider.value}/$external conflicted.',
        );
      } else if (existing == null) {
        await database.saveEpisodeBinding(
          EpisodeSourceBinding(
            canonicalId: canonical,
            providerId: provider,
            externalId: external,
            relativeLocator: value['locator'] as String?,
          ),
        );
      }
    }
  }

  Future<void> _restoreProgress(Map<String, dynamic> state) async {
    for (final value
        in (state['mangaProgress'] as List).cast<Map<String, dynamic>>()) {
      final id = CanonicalMediaId(value['mediaId'] as String);
      final incoming = DateTime.parse(value['updatedAt'] as String);
      final existing = await database.mangaProgress(id);
      if (existing == null || incoming.isAfter(existing.updatedAt)) {
        await database.saveMangaProgress(
          CanonicalMangaProgress(
            mediaId: id,
            chapterId: CanonicalChapterId(value['chapterId'] as String),
            pageIndex: value['pageIndex'] as int,
            totalPages: value['totalPages'] as int?,
            updatedAt: incoming,
          ),
        );
      }
    }
    for (final value
        in (state['animeProgress'] as List).cast<Map<String, dynamic>>()) {
      final id = CanonicalMediaId(value['mediaId'] as String);
      final incoming = DateTime.parse(value['updatedAt'] as String);
      final existing = await database.animeProgress(id);
      if (existing == null || incoming.isAfter(existing.updatedAt)) {
        await database.saveAnimeProgress(
          CanonicalAnimeProgress(
            mediaId: id,
            episodeId: CanonicalEpisodeId(value['episodeId'] as String),
            position: Duration(milliseconds: value['position'] as int),
            duration: value['duration'] == null
                ? null
                : Duration(milliseconds: value['duration'] as int),
            updatedAt: incoming,
          ),
        );
      }
    }
    for (final value
        in (state['mangaResumes'] as List).cast<Map<String, dynamic>>()) {
      final provider = ProviderId(value['providerId'] as String);
      final external = value['chapterExternalId'] as String;
      if (await database.chapterBinding(provider, external) != null) {
        final existing = await database.mangaSourcePageResume(
          provider,
          external,
        );
        final incoming = DateTime.parse(value['updatedAt'] as String);
        if (existing == null || incoming.isAfter(existing.updatedAt)) {
          await database.saveMangaSourcePageResume(
            MangaSourcePageResume(
              mediaId: CanonicalMediaId(value['mediaId'] as String),
              chapterId: CanonicalChapterId(value['chapterId'] as String),
              providerId: provider,
              chapterExternalId: external,
              pageIndex: value['pageIndex'] as int,
              totalPages: value['totalPages'] as int?,
              updatedAt: incoming,
            ),
          );
        }
      }
    }
    for (final value
        in (state['animeResumes'] as List).cast<Map<String, dynamic>>()) {
      final provider = ProviderId(value['providerId'] as String);
      final external = value['episodeExternalId'] as String;
      if (await database.episodeBinding(provider, external) != null) {
        final existing = await database.animeSourcePlaybackResume(
          provider,
          external,
        );
        final incoming = DateTime.parse(value['updatedAt'] as String);
        if (existing == null || incoming.isAfter(existing.updatedAt)) {
          await database.saveAnimeSourcePlaybackResume(
            AnimeSourcePlaybackResume(
              mediaId: CanonicalMediaId(value['mediaId'] as String),
              episodeId: CanonicalEpisodeId(value['episodeId'] as String),
              providerId: provider,
              episodeExternalId: external,
              position: Duration(
                milliseconds: value['positionMilliseconds'] as int,
              ),
              duration: value['durationMilliseconds'] == null
                  ? null
                  : Duration(
                      milliseconds: value['durationMilliseconds'] as int,
                    ),
              updatedAt: incoming,
            ),
          );
        }
      }
    }
  }
}

bool _local(ProviderId id) => id.value.startsWith('local-');
Map<String, Object?> _bindingJson(SourceBinding<CanonicalId> value) => {
  'canonicalId': value.canonicalId.value,
  'providerId': value.providerId.value,
  'externalId': value.externalId,
  'locator': _local(value.providerId) ? null : value.relativeLocator,
};

Object? _sanitizeSnapshot(Object? value, [String? key]) {
  if (key == 'relativeLocator' && value is String && _absolutePath(value)) {
    return null;
  }
  if (value is Map) {
    return value.map(
      (entryKey, entryValue) => MapEntry(
        entryKey.toString(),
        _sanitizeSnapshot(entryValue, entryKey.toString()),
      ),
    );
  }
  if (value is List) return value.map(_sanitizeSnapshot).toList();
  return value;
}

bool _absolutePath(String value) =>
    value.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value);
String? _portableLocator(String? value) =>
    value != null && _absolutePath(value) ? null : value;
Map<String, Object?> _libraryJson(CanonicalLibraryEntry value) => {
  'mediaId': value.mediaId.value,
  'isSaved': value.isSaved,
  'isFavorite': value.isFavorite,
  'status': value.status.name,
  'createdAt': value.createdAt.toIso8601String(),
  'updatedAt': value.updatedAt.toIso8601String(),
};
Map<String, Object?> _mediaToJson(CanonicalMedia value) => {
  'id': value.id.value,
  'kind': value.kind.name,
  'title': _sourcedJson(value.title),
  'alternateTitles': value.alternateTitles.map(_sourcedJson).toList(),
  'status': value.status.name,
  'description': value.description == null
      ? null
      : _sourcedJson(value.description!),
  'genres': value.genres.map(_sourcedJson).toList(),
  'coverLocator': _portableLocator(value.coverLocator),
  if (value is CanonicalAnime) ...{
    'format': value.format.name,
    'airingSeason': value.airingWindow?.season.name,
    'airingYear': value.airingWindow?.year,
    'airingRawLabel': value.airingWindow?.rawLabel,
    'narrativeSeason': value.narrativeSeason?.value,
    'knownEpisodeTotal': value.knownEpisodeTotal,
    'rawEpisodeTotal': value.rawEpisodeTotal,
  },
};
CanonicalMedia _mediaFromJson(Map<String, dynamic> value) {
  final id = CanonicalMediaId(value['id'] as String);
  final title = _sourcedFrom(value['title'] as Map<String, dynamic>);
  final description = value['description'] == null
      ? null
      : _sourcedFrom(value['description'] as Map<String, dynamic>);
  final alternate = (value['alternateTitles'] as List)
      .cast<Map<String, dynamic>>()
      .map(_sourcedFrom)
      .toList();
  final genres = (value['genres'] as List)
      .cast<Map<String, dynamic>>()
      .map(_sourcedFrom)
      .toList();
  final status = CanonicalMediaStatus.values.byName(value['status'] as String);
  final airingYear = value['airingYear'] as int?;
  return value['kind'] == CanonicalMediaKind.anime.name
      ? CanonicalAnime(
          id: id,
          title: title,
          alternateTitles: alternate,
          description: description,
          status: status,
          genres: genres,
          coverLocator: value['coverLocator'] as String?,
          format: AnimeFormat.values.byName(value['format'] as String),
          airingWindow: airingYear == null
              ? null
              : AiringWindow(
                  season: AiringSeason.values.byName(
                    value['airingSeason'] as String,
                  ),
                  year: airingYear,
                  rawLabel: value['airingRawLabel'] as String,
                ),
          narrativeSeason: value['narrativeSeason'] == null
              ? null
              : NarrativeSeasonNumber(value['narrativeSeason'] as int),
          knownEpisodeTotal: value['knownEpisodeTotal'] as int?,
          rawEpisodeTotal: value['rawEpisodeTotal'] as String?,
        )
      : CanonicalManga(
          id: id,
          title: title,
          alternateTitles: alternate,
          description: description,
          status: status,
          genres: genres,
          coverLocator: value['coverLocator'] as String?,
        );
}

Map<String, Object?> _sourcedJson(SourcedValue<String> value) => {
  'value': value.value,
  'providerId': value.provenance.providerId.value,
  'rawValue': value.rawValue,
};
SourcedValue<String> _sourcedFrom(Map<String, dynamic> value) => SourcedValue(
  value: value['value'] as String,
  provenance: FieldProvenance(
    providerId: ProviderId(value['providerId'] as String),
  ),
  rawValue: value['rawValue'] as String?,
);
