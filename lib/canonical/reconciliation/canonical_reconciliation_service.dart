import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/bindings.dart';
import '../domain/identifiers.dart';
import '../domain/installments.dart';
import '../domain/matching.dart';
import '../domain/media.dart';
import '../domain/user_state.dart';
import '../persistence/canonical_database.dart';

class ReconciliationException implements Exception {
  const ReconciliationException(this.message, {this.conflicts = const []});
  final String message;
  final List<MergeConflict> conflicts;
  @override
  String toString() => 'ReconciliationException: $message';
}

class CanonicalReconciliationService {
  CanonicalReconciliationService(
    this.database, {
    MatchingPolicy? matchingPolicy,
  }) : matchingPolicy = matchingPolicy ?? const MatchingPolicy();

  final CanonicalDatabase database;
  final MatchingPolicy matchingPolicy;
  int _auditCounter = 0;

  Future<List<MatchCandidate>> candidatesFor(CanonicalMediaId mediaId) async {
    final media = await database.media(mediaId);
    if (media == null) return const [];
    final candidates = <MatchCandidate>[];
    for (final other in await database.allMedia()) {
      if (other.id == mediaId) continue;
      final candidate = matchingPolicy.evaluate(media, other);
      if (candidate.confidence != MatchConfidence.notAMatch) {
        candidates.add(candidate);
      }
    }
    return candidates;
  }

  Future<MergeResult> mergeCanonicalMedia({
    required CanonicalMediaId sourceId,
    required CanonicalMediaId targetId,
    required MergeReason reason,
  }) => database.transaction(() async {
    final resolvedSource = await database.resolveCanonicalId(sourceId);
    final resolvedTarget = await database.resolveCanonicalId(targetId);
    if (resolvedSource != sourceId || resolvedTarget != targetId) {
      throw const ReconciliationException(
        'Merge inputs must be active canonical IDs, not aliases',
      );
    }
    if (sourceId == targetId) {
      throw const ReconciliationException(
        'Cannot merge a media item into itself',
      );
    }
    final source = await database.media(sourceId);
    final target = await database.media(targetId);
    if (source == null || target == null) {
      throw const ReconciliationException('Both canonical media must exist');
    }
    final evaluation = matchingPolicy.evaluate(source, target);
    if (source.kind != target.kind ||
        evaluation.confidence == MatchConfidence.notAMatch &&
            evaluation.evidence.any(
              (item) => !item.supportsMatch && item.strong,
            )) {
      throw const ReconciliationException(
        'Strong canonical metadata is incompatible',
      );
    }

    final sourceMediaBindings = await database.mediaBindingsFor(sourceId);
    final targetMediaBindings = await database.mediaBindingsFor(targetId);
    final duplicateProviders = sourceMediaBindings
        .map((binding) => binding.providerId)
        .toSet()
        .intersection(
          targetMediaBindings.map((binding) => binding.providerId).toSet(),
        );
    if (duplicateProviders.isNotEmpty) {
      final conflicts = duplicateProviders
          .map(
            (provider) => MergeConflict(
              kind: MergeConflictKind.duplicateProviderBinding,
              description: 'Both media have a ${provider.value} media binding',
            ),
          )
          .toList();
      throw ReconciliationException(
        'Duplicate provider media bindings require manual resolution',
        conflicts: conflicts,
      );
    }

    final auditId = _nextAuditId();
    final conflicts = <MergeConflict>[];
    final snapshot = <String, Object?>{
      'targetMedia': _mediaToJson(target),
      'targetLibrary': _libraryToJson(await database.libraryEntry(targetId)),
      'targetMangaProgress': _mangaProgressToJson(
        await database.mangaProgress(targetId),
      ),
      'targetAnimeProgress': _animeProgressToJson(
        await database.animeProgress(targetId),
      ),
      'targetPreferredProvider': (await database.preferredProvider(
        targetId,
      ))?.value,
      'sourceMediaBindings': sourceMediaBindings.map(_bindingToJson).toList(),
    };

    final mergedMedia = _mergeMetadata(target, source, conflicts);
    await database.saveMedia(mergedMedia);

    final chapterMoves = source is CanonicalManga
        ? await _mergeChapters(sourceId, targetId, conflicts)
        : <Map<String, Object?>>[];
    final episodeMoves = source is CanonicalAnime
        ? await _mergeEpisodes(source, target as CanonicalAnime, conflicts)
        : <Map<String, Object?>>[];
    snapshot['chapterMoves'] = chapterMoves;
    snapshot['episodeMoves'] = episodeMoves;

    for (final binding in sourceMediaBindings) {
      await (database.update(database.canonicalMediaBindings)..where(
            (row) =>
                row.providerId.equals(binding.providerId.value) &
                row.externalId.equals(binding.externalId),
          ))
          .write(
            CanonicalMediaBindingsCompanion(canonicalId: Value(targetId.value)),
          );
    }

    await _mergeLibrary(sourceId, targetId, conflicts);
    await _mergeProgress(
      sourceId,
      targetId,
      chapterMoves,
      episodeMoves,
      conflicts,
    );
    final preferred =
        await database.preferredProvider(targetId) ??
        await database.preferredProvider(sourceId);
    await database.setPreferredProvider(targetId, preferred);

    await database.saveCanonicalAlias(
      historicalId: sourceId,
      targetId: targetId,
      mergeAuditId: auditId,
      createdAt: DateTime.now().toUtc(),
    );
    final fingerprint = await _fingerprint(targetId);
    await database
        .into(database.canonicalMergeAudits)
        .insert(
          CanonicalMergeAuditsCompanion.insert(
            id: auditId,
            sourceId: sourceId.value,
            targetId: targetId.value,
            reason: reason.name,
            snapshotJson: jsonEncode(snapshot),
            mergedFingerprint: fingerprint,
            conflictsJson: Value(
              jsonEncode(
                conflicts
                    .map(
                      (conflict) => {
                        'kind': conflict.kind.name,
                        'description': conflict.description,
                      },
                    )
                    .toList(),
              ),
            ),
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return MergeResult(
      auditId: auditId,
      survivingId: targetId,
      retiredId: sourceId,
      conflicts: conflicts,
    );
  });

  Future<void> undoMerge(String auditId) => database.transaction(() async {
    final audit = await (database.select(
      database.canonicalMergeAudits,
    )..where((row) => row.id.equals(auditId))).getSingleOrNull();
    if (audit == null) {
      throw const ReconciliationException('Merge audit not found');
    }
    if (audit.undoneAt != null) {
      throw const ReconciliationException('Merge was already undone');
    }
    final targetId = CanonicalMediaId(audit.targetId);
    if (await _fingerprint(targetId) != audit.mergedFingerprint) {
      throw const ReconciliationException(
        'Merged state changed after review; automatic undo would lose data',
      );
    }
    final sourceId = CanonicalMediaId(audit.sourceId);
    final snapshot = jsonDecode(audit.snapshotJson) as Map<String, dynamic>;

    for (final value in (snapshot['sourceMediaBindings'] as List<dynamic>)) {
      final binding = value as Map<String, dynamic>;
      await (database.update(database.canonicalMediaBindings)..where(
            (row) =>
                row.providerId.equals(binding['providerId'] as String) &
                row.externalId.equals(binding['externalId'] as String),
          ))
          .write(
            CanonicalMediaBindingsCompanion(canonicalId: Value(sourceId.value)),
          );
    }
    await _undoChapterMoves(
      sourceId,
      (snapshot['chapterMoves'] as List<dynamic>).cast<Map<String, dynamic>>(),
    );
    await _undoEpisodeMoves(
      sourceId,
      (snapshot['episodeMoves'] as List<dynamic>).cast<Map<String, dynamic>>(),
    );
    await database.saveMedia(
      _mediaFromJson(snapshot['targetMedia'] as Map<String, dynamic>),
    );
    await _restoreTargetState(targetId, snapshot);
    await (database.delete(
      database.canonicalMediaAliases,
    )..where((row) => row.historicalId.equals(sourceId.value))).go();
    await (database.update(
      database.canonicalMergeAudits,
    )..where((row) => row.id.equals(auditId))).write(
      CanonicalMergeAuditsCompanion(undoneAt: Value(DateTime.now().toUtc())),
    );
  });

  Future<List<Map<String, Object?>>> _mergeChapters(
    CanonicalMediaId sourceId,
    CanonicalMediaId targetId,
    List<MergeConflict> conflicts,
  ) async {
    final sourceChapters = await database.chaptersFor(sourceId);
    final targetChapters = await database.chaptersFor(targetId);
    final moves = <Map<String, Object?>>[];
    for (final source in sourceChapters) {
      final bindings = await database.chapterBindingsFor(source.id);
      CanonicalChapter? matched;
      if (source.number.normalizedNumber != null) {
        final sameNumberCandidates = targetChapters
            .where(
              (target) =>
                  target.number.normalizedNumber ==
                  source.number.normalizedNumber,
            )
            .toList();
        final candidates = targetChapters.where((target) {
          final sameNumber =
              target.number.normalizedNumber == source.number.normalizedNumber;
          final compatibleVolume =
              target.volumeLabel == null ||
              source.volumeLabel == null ||
              target.volumeLabel == source.volumeLabel;
          return sameNumber && compatibleVolume;
        }).toList();
        if (candidates.length == 1 &&
            !_providerOverlap(
              bindings,
              await database.chapterBindingsFor(candidates.single.id),
            )) {
          matched = candidates.single;
        } else if (candidates.isNotEmpty || sameNumberCandidates.isNotEmpty) {
          conflicts.add(
            MergeConflict(
              kind: MergeConflictKind.ambiguousInstallment,
              description: 'Chapter ${source.number.rawLabel} is ambiguous',
            ),
          );
        }
      } else {
        conflicts.add(
          MergeConflict(
            kind: MergeConflictKind.ambiguousInstallment,
            description:
                'Special chapter ${source.number.rawLabel} was not auto-reconciled',
          ),
        );
      }
      moves.add({
        'sourceId': source.id.value,
        'targetId': matched?.id.value,
        'bindings': bindings.map(_bindingToJson).toList(),
      });
      if (matched == null) {
        await (database.update(
          database.canonicalChapterRecords,
        )..where((row) => row.id.equals(source.id.value))).write(
          CanonicalChapterRecordsCompanion(mediaId: Value(targetId.value)),
        );
        await (database.update(
          database.mangaSourcePageResumes,
        )..where((row) => row.chapterId.equals(source.id.value))).write(
          MangaSourcePageResumesCompanion(mediaId: Value(targetId.value)),
        );
      } else {
        for (final binding in bindings) {
          await (database.update(database.canonicalChapterBindings)..where(
                (row) =>
                    row.providerId.equals(binding.providerId.value) &
                    row.externalId.equals(binding.externalId),
              ))
              .write(
                CanonicalChapterBindingsCompanion(
                  canonicalId: Value(matched.id.value),
                ),
              );
          await (database.update(database.mangaSourcePageResumes)..where(
                (row) =>
                    row.providerId.equals(binding.providerId.value) &
                    row.chapterExternalId.equals(binding.externalId),
              ))
              .write(
                MangaSourcePageResumesCompanion(
                  mediaId: Value(targetId.value),
                  chapterId: Value(matched.id.value),
                ),
              );
        }
      }
    }
    return moves;
  }

  Future<List<Map<String, Object?>>> _mergeEpisodes(
    CanonicalAnime source,
    CanonicalAnime target,
    List<MergeConflict> conflicts,
  ) async {
    final sourceEpisodes = await database.episodesFor(source.id);
    final targetEpisodes = await database.episodesFor(target.id);
    final allowNumericReconciliation =
        source.format == AnimeFormat.tv && target.format == AnimeFormat.tv;
    final moves = <Map<String, Object?>>[];
    for (final sourceEpisode in sourceEpisodes) {
      final bindings = await database.episodeBindingsFor(sourceEpisode.id);
      CanonicalEpisode? matched;
      var ambiguous = !allowNumericReconciliation;
      if (allowNumericReconciliation &&
          sourceEpisode.label.number != null &&
          sourceEpisode.label.number! % 1 == 0) {
        final sameNumberCandidates = targetEpisodes
            .where(
              (targetEpisode) =>
                  targetEpisode.label.number == sourceEpisode.label.number,
            )
            .toList();
        final candidates = targetEpisodes
            .where(
              (targetEpisode) =>
                  targetEpisode.label.number == sourceEpisode.label.number &&
                  targetEpisode.narrativeSeason ==
                      sourceEpisode.narrativeSeason,
            )
            .toList();
        if (candidates.length == 1 &&
            !_providerOverlap(
              bindings,
              await database.episodeBindingsFor(candidates.single.id),
            )) {
          matched = candidates.single;
        } else if (sameNumberCandidates.isNotEmpty) {
          ambiguous = true;
        }
      } else if (sourceEpisode.label.number == null ||
          sourceEpisode.label.number! % 1 != 0) {
        ambiguous = true;
      }
      if (matched == null && ambiguous) {
        conflicts.add(
          MergeConflict(
            kind: MergeConflictKind.ambiguousInstallment,
            description:
                'Episode ${sourceEpisode.label.rawLabel} was not auto-reconciled',
          ),
        );
      }
      moves.add({
        'sourceId': sourceEpisode.id.value,
        'targetId': matched?.id.value,
        'bindings': bindings.map(_bindingToJson).toList(),
      });
      if (matched == null) {
        await (database.update(
          database.canonicalEpisodeRecords,
        )..where((row) => row.id.equals(sourceEpisode.id.value))).write(
          CanonicalEpisodeRecordsCompanion(mediaId: Value(target.id.value)),
        );
        await (database.update(
          database.animeSourcePlaybackResumes,
        )..where((row) => row.episodeId.equals(sourceEpisode.id.value))).write(
          AnimeSourcePlaybackResumesCompanion(mediaId: Value(target.id.value)),
        );
      } else {
        for (final binding in bindings) {
          await (database.update(database.canonicalEpisodeBindings)..where(
                (row) =>
                    row.providerId.equals(binding.providerId.value) &
                    row.externalId.equals(binding.externalId),
              ))
              .write(
                CanonicalEpisodeBindingsCompanion(
                  canonicalId: Value(matched.id.value),
                ),
              );
          await (database.update(database.animeSourcePlaybackResumes)..where(
                (row) =>
                    row.providerId.equals(binding.providerId.value) &
                    row.episodeExternalId.equals(binding.externalId),
              ))
              .write(
                AnimeSourcePlaybackResumesCompanion(
                  mediaId: Value(target.id.value),
                  episodeId: Value(matched.id.value),
                ),
              );
        }
      }
    }
    return moves;
  }

  bool _providerOverlap(
    List<SourceBinding<CanonicalId>> left,
    List<SourceBinding<CanonicalId>> right,
  ) => left
      .map((binding) => binding.providerId)
      .toSet()
      .intersection(right.map((binding) => binding.providerId).toSet())
      .isNotEmpty;

  Future<void> _mergeLibrary(
    CanonicalMediaId sourceId,
    CanonicalMediaId targetId,
    List<MergeConflict> conflicts,
  ) async {
    final source = await database.libraryEntry(sourceId);
    final target = await database.libraryEntry(targetId);
    if (source == null) return;
    if (target != null && source.status != target.status) {
      conflicts.add(
        const MergeConflict(
          kind: MergeConflictKind.libraryStatus,
          description:
              'Target library status retained; both facts remain in audit',
        ),
      );
    }
    await database.saveLibraryEntry(
      CanonicalLibraryEntry(
        mediaId: targetId,
        isSaved: source.isSaved || (target?.isSaved ?? false),
        isFavorite: source.isFavorite || (target?.isFavorite ?? false),
        status: target?.status ?? source.status,
        createdAt: target == null || source.createdAt.isBefore(target.createdAt)
            ? source.createdAt
            : target.createdAt,
        updatedAt: target == null || source.updatedAt.isAfter(target.updatedAt)
            ? source.updatedAt
            : target.updatedAt,
      ),
    );
  }

  Future<void> _mergeProgress(
    CanonicalMediaId sourceId,
    CanonicalMediaId targetId,
    List<Map<String, Object?>> chapterMoves,
    List<Map<String, Object?>> episodeMoves,
    List<MergeConflict> conflicts,
  ) async {
    final sourceManga = await database.mangaProgress(sourceId);
    final targetManga = await database.mangaProgress(targetId);
    if (sourceManga != null) {
      if (targetManga != null) {
        conflicts.add(
          const MergeConflict(
            kind: MergeConflictKind.mangaProgress,
            description:
                'Newest manga progress selected; both facts remain in audit',
          ),
        );
      }
      final chosen =
          targetManga == null ||
              sourceManga.updatedAt.isAfter(targetManga.updatedAt)
          ? sourceManga
          : targetManga;
      final mapped = _mappedId(chosen.chapterId.value, chapterMoves);
      await database.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: targetId,
          chapterId: CanonicalChapterId(mapped),
          pageIndex: chosen.pageIndex,
          totalPages: chosen.totalPages,
          updatedAt: chosen.updatedAt,
        ),
      );
    }
    final sourceAnime = await database.animeProgress(sourceId);
    final targetAnime = await database.animeProgress(targetId);
    if (sourceAnime != null) {
      if (targetAnime != null) {
        conflicts.add(
          const MergeConflict(
            kind: MergeConflictKind.animeProgress,
            description:
                'Newest anime progress selected; both facts remain in audit',
          ),
        );
      }
      final chosen =
          targetAnime == null ||
              sourceAnime.updatedAt.isAfter(targetAnime.updatedAt)
          ? sourceAnime
          : targetAnime;
      final mapped = _mappedId(chosen.episodeId.value, episodeMoves);
      await database.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: targetId,
          episodeId: CanonicalEpisodeId(mapped),
          position: chosen.position,
          duration: chosen.duration,
          updatedAt: chosen.updatedAt,
        ),
      );
    }
  }

  String _mappedId(String original, List<Map<String, Object?>> moves) {
    for (final move in moves) {
      if (move['sourceId'] == original) {
        return move['targetId'] as String? ?? original;
      }
    }
    return original;
  }

  Future<void> _undoChapterMoves(
    CanonicalMediaId sourceId,
    List<Map<String, dynamic>> moves,
  ) async {
    for (final move in moves) {
      final originalId = move['sourceId'] as String;
      for (final value in move['bindings'] as List<dynamic>) {
        final binding = value as Map<String, dynamic>;
        await (database.update(database.canonicalChapterBindings)..where(
              (row) =>
                  row.providerId.equals(binding['providerId'] as String) &
                  row.externalId.equals(binding['externalId'] as String),
            ))
            .write(
              CanonicalChapterBindingsCompanion(canonicalId: Value(originalId)),
            );
        await (database.update(database.mangaSourcePageResumes)..where(
              (row) =>
                  row.providerId.equals(binding['providerId'] as String) &
                  row.chapterExternalId.equals(binding['externalId'] as String),
            ))
            .write(
              MangaSourcePageResumesCompanion(
                mediaId: Value(sourceId.value),
                chapterId: Value(originalId),
              ),
            );
      }
      await (database.update(
        database.canonicalChapterRecords,
      )..where((row) => row.id.equals(originalId))).write(
        CanonicalChapterRecordsCompanion(mediaId: Value(sourceId.value)),
      );
    }
  }

  Future<void> _undoEpisodeMoves(
    CanonicalMediaId sourceId,
    List<Map<String, dynamic>> moves,
  ) async {
    for (final move in moves) {
      final originalId = move['sourceId'] as String;
      for (final value in move['bindings'] as List<dynamic>) {
        final binding = value as Map<String, dynamic>;
        await (database.update(database.canonicalEpisodeBindings)..where(
              (row) =>
                  row.providerId.equals(binding['providerId'] as String) &
                  row.externalId.equals(binding['externalId'] as String),
            ))
            .write(
              CanonicalEpisodeBindingsCompanion(canonicalId: Value(originalId)),
            );
        await (database.update(database.animeSourcePlaybackResumes)..where(
              (row) =>
                  row.providerId.equals(binding['providerId'] as String) &
                  row.episodeExternalId.equals(binding['externalId'] as String),
            ))
            .write(
              AnimeSourcePlaybackResumesCompanion(
                mediaId: Value(sourceId.value),
                episodeId: Value(originalId),
              ),
            );
      }
      await (database.update(
        database.canonicalEpisodeRecords,
      )..where((row) => row.id.equals(originalId))).write(
        CanonicalEpisodeRecordsCompanion(mediaId: Value(sourceId.value)),
      );
    }
  }

  Future<void> _restoreTargetState(
    CanonicalMediaId targetId,
    Map<String, dynamic> snapshot,
  ) async {
    await (database.delete(
      database.canonicalLibraryRecords,
    )..where((row) => row.mediaId.equals(targetId.value))).go();
    final library = _libraryFromJson(
      snapshot['targetLibrary'] as Map<String, dynamic>?,
    );
    if (library != null) await database.saveLibraryEntry(library);
    await (database.delete(
      database.canonicalMangaProgressRecords,
    )..where((row) => row.mediaId.equals(targetId.value))).go();
    final manga = _mangaProgressFromJson(
      snapshot['targetMangaProgress'] as Map<String, dynamic>?,
    );
    if (manga != null) await database.saveMangaProgress(manga);
    await (database.delete(
      database.canonicalAnimeProgressRecords,
    )..where((row) => row.mediaId.equals(targetId.value))).go();
    final anime = _animeProgressFromJson(
      snapshot['targetAnimeProgress'] as Map<String, dynamic>?,
    );
    if (anime != null) await database.saveAnimeProgress(anime);
    final preferred = snapshot['targetPreferredProvider'] as String?;
    await database.setPreferredProvider(
      targetId,
      preferred == null ? null : ProviderId(preferred),
    );
  }

  Future<String> _fingerprint(CanonicalMediaId targetId) async {
    final media = await database.media(targetId);
    if (media == null) return 'missing';
    final chapters = await database.chaptersFor(targetId);
    final episodes = await database.episodesFor(targetId);
    chapters.sort((a, b) => a.id.value.compareTo(b.id.value));
    episodes.sort((a, b) => a.id.value.compareTo(b.id.value));
    final value = <String, Object?>{
      'media': _mediaToJson(media),
      'mediaBindings':
          (await database.mediaBindingsFor(
            targetId,
          )).map(_bindingToJson).toList()..sort(
            (a, b) => '${a['providerId']}/${a['externalId']}'.compareTo(
              '${b['providerId']}/${b['externalId']}',
            ),
          ),
      'chapters': [
        for (final chapter in chapters)
          {
            'id': chapter.id.value,
            'label': chapter.number.rawLabel,
            'volume': chapter.volumeLabel,
            'bindings':
                (await database.chapterBindingsFor(
                  chapter.id,
                )).map(_bindingToJson).toList()..sort(
                  (a, b) => '${a['providerId']}/${a['externalId']}'.compareTo(
                    '${b['providerId']}/${b['externalId']}',
                  ),
                ),
          },
      ],
      'episodes': [
        for (final episode in episodes)
          {
            'id': episode.id.value,
            'label': episode.label.rawLabel,
            'bindings':
                (await database.episodeBindingsFor(
                  episode.id,
                )).map(_bindingToJson).toList()..sort(
                  (a, b) => '${a['providerId']}/${a['externalId']}'.compareTo(
                    '${b['providerId']}/${b['externalId']}',
                  ),
                ),
          },
      ],
      'library': _libraryToJson(await database.libraryEntry(targetId)),
      'mangaProgress': _mangaProgressToJson(
        await database.mangaProgress(targetId),
      ),
      'animeProgress': _animeProgressToJson(
        await database.animeProgress(targetId),
      ),
      'sourcePlaybackResumes':
          (await (database.select(
                database.animeSourcePlaybackResumes,
              )..where((row) => row.mediaId.equals(targetId.value))).get())
              .map(
                (row) => {
                  'providerId': row.providerId,
                  'externalId': row.episodeExternalId,
                  'episodeId': row.episodeId,
                  'position': row.positionMilliseconds,
                  'duration': row.durationMilliseconds,
                },
              )
              .toList()
            ..sort(
              (a, b) => '${a['providerId']}/${a['externalId']}'.compareTo(
                '${b['providerId']}/${b['externalId']}',
              ),
            ),
      'preferred': (await database.preferredProvider(targetId))?.value,
    };
    return base64Url.encode(utf8.encode(jsonEncode(value)));
  }

  String _nextAuditId() =>
      'merge-${DateTime.now().microsecondsSinceEpoch}-${++_auditCounter}';
}

CanonicalMedia _mergeMetadata(
  CanonicalMedia target,
  CanonicalMedia source,
  List<MergeConflict> conflicts,
) {
  if (target.title.value != source.title.value) {
    conflicts.add(
      const MergeConflict(
        kind: MergeConflictKind.title,
        description:
            'Target primary title retained; source title preserved as alternate',
      ),
    );
  }
  final alternate = _uniqueSourced([
    ...target.alternateTitles,
    ...source.alternateTitles,
    if (target.title.value != source.title.value) source.title,
  ]);
  final description = target.description ?? source.description;
  final genres = _uniqueSourced([...target.genres, ...source.genres]);
  if (target is CanonicalManga && source is CanonicalManga) {
    return CanonicalManga(
      id: target.id,
      title: target.title,
      alternateTitles: alternate,
      description: description,
      status: target.status,
      genres: genres,
      coverLocator: target.coverLocator ?? source.coverLocator,
    );
  }
  final targetAnime = target as CanonicalAnime;
  final sourceAnime = source as CanonicalAnime;
  return CanonicalAnime(
    id: target.id,
    title: target.title,
    alternateTitles: alternate,
    description: description,
    status: target.status,
    genres: genres,
    coverLocator: target.coverLocator ?? source.coverLocator,
    format: targetAnime.format,
    airingWindow: targetAnime.airingWindow ?? sourceAnime.airingWindow,
    narrativeSeason: targetAnime.narrativeSeason ?? sourceAnime.narrativeSeason,
    knownEpisodeTotal:
        targetAnime.knownEpisodeTotal ?? sourceAnime.knownEpisodeTotal,
    rawEpisodeTotal: targetAnime.rawEpisodeTotal ?? sourceAnime.rawEpisodeTotal,
  );
}

List<SourcedValue<String>> _uniqueSourced(List<SourcedValue<String>> values) {
  final seen = <String>{};
  return values
      .where(
        (value) => seen.add(
          '${value.provenance.providerId.value}\u0000${value.value}',
        ),
      )
      .toList();
}

Map<String, Object?> _bindingToJson(SourceBinding<CanonicalId> binding) => {
  'providerId': binding.providerId.value,
  'externalId': binding.externalId,
  'relativeLocator': binding.relativeLocator,
  'rawMetadata': binding.rawMetadata,
};

Map<String, Object?> _mediaToJson(CanonicalMedia media) => {
  'id': media.id.value,
  'kind': media.kind.name,
  'title': _sourcedToJson(media.title),
  'alternateTitles': media.alternateTitles.map(_sourcedToJson).toList(),
  'description': media.description == null
      ? null
      : _sourcedToJson(media.description!),
  'status': media.status.name,
  'genres': media.genres.map(_sourcedToJson).toList(),
  'coverLocator': media.coverLocator,
  if (media is CanonicalAnime) ...{
    'format': media.format.name,
    'airingSeason': media.airingWindow?.season.name,
    'airingYear': media.airingWindow?.year,
    'airingRawLabel': media.airingWindow?.rawLabel,
    'narrativeSeason': media.narrativeSeason?.value,
    'knownEpisodeTotal': media.knownEpisodeTotal,
    'rawEpisodeTotal': media.rawEpisodeTotal,
  },
};

CanonicalMedia _mediaFromJson(Map<String, dynamic> json) {
  final common = (
    id: CanonicalMediaId(json['id'] as String),
    title: _sourcedFromJson(json['title'] as Map<String, dynamic>),
    alternate: (json['alternateTitles'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_sourcedFromJson)
        .toList(),
    description: json['description'] == null
        ? null
        : _sourcedFromJson(json['description'] as Map<String, dynamic>),
    status: CanonicalMediaStatus.values.byName(json['status'] as String),
    genres: (json['genres'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(_sourcedFromJson)
        .toList(),
    cover: json['coverLocator'] as String?,
  );
  if (json['kind'] == CanonicalMediaKind.manga.name) {
    return CanonicalManga(
      id: common.id,
      title: common.title,
      alternateTitles: common.alternate,
      description: common.description,
      status: common.status,
      genres: common.genres,
      coverLocator: common.cover,
    );
  }
  final airingYear = json['airingYear'] as int?;
  return CanonicalAnime(
    id: common.id,
    title: common.title,
    alternateTitles: common.alternate,
    description: common.description,
    status: common.status,
    genres: common.genres,
    coverLocator: common.cover,
    format: AnimeFormat.values.byName(json['format'] as String),
    airingWindow: airingYear == null
        ? null
        : AiringWindow(
            season: AiringSeason.values.byName(json['airingSeason'] as String),
            year: airingYear,
            rawLabel: json['airingRawLabel'] as String,
          ),
    narrativeSeason: json['narrativeSeason'] == null
        ? null
        : NarrativeSeasonNumber(json['narrativeSeason'] as int),
    knownEpisodeTotal: json['knownEpisodeTotal'] as int?,
    rawEpisodeTotal: json['rawEpisodeTotal'] as String?,
  );
}

Map<String, Object?> _sourcedToJson(SourcedValue<String> value) => {
  'value': value.value,
  'providerId': value.provenance.providerId.value,
  'rawValue': value.rawValue,
};

SourcedValue<String> _sourcedFromJson(Map<String, dynamic> json) =>
    SourcedValue(
      value: json['value'] as String,
      provenance: FieldProvenance(
        providerId: ProviderId(json['providerId'] as String),
      ),
      rawValue: json['rawValue'] as String?,
    );

Map<String, Object?>? _libraryToJson(CanonicalLibraryEntry? value) =>
    value == null
    ? null
    : {
        'mediaId': value.mediaId.value,
        'isSaved': value.isSaved,
        'isFavorite': value.isFavorite,
        'status': value.status.name,
        'createdAt': value.createdAt.toIso8601String(),
        'updatedAt': value.updatedAt.toIso8601String(),
      };

CanonicalLibraryEntry? _libraryFromJson(Map<String, dynamic>? json) =>
    json == null
    ? null
    : CanonicalLibraryEntry(
        mediaId: CanonicalMediaId(json['mediaId'] as String),
        isSaved: json['isSaved'] as bool,
        isFavorite: json['isFavorite'] as bool,
        status: CanonicalLibraryStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

Map<String, Object?>? _mangaProgressToJson(CanonicalMangaProgress? value) =>
    value == null
    ? null
    : {
        'mediaId': value.mediaId.value,
        'chapterId': value.chapterId.value,
        'pageIndex': value.pageIndex,
        'totalPages': value.totalPages,
        'updatedAt': value.updatedAt.toIso8601String(),
      };

CanonicalMangaProgress? _mangaProgressFromJson(Map<String, dynamic>? json) =>
    json == null
    ? null
    : CanonicalMangaProgress(
        mediaId: CanonicalMediaId(json['mediaId'] as String),
        chapterId: CanonicalChapterId(json['chapterId'] as String),
        pageIndex: json['pageIndex'] as int,
        totalPages: json['totalPages'] as int?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

Map<String, Object?>? _animeProgressToJson(CanonicalAnimeProgress? value) =>
    value == null
    ? null
    : {
        'mediaId': value.mediaId.value,
        'episodeId': value.episodeId.value,
        'position': value.position.inMilliseconds,
        'duration': value.duration?.inMilliseconds,
        'updatedAt': value.updatedAt.toIso8601String(),
      };

CanonicalAnimeProgress? _animeProgressFromJson(Map<String, dynamic>? json) =>
    json == null
    ? null
    : CanonicalAnimeProgress(
        mediaId: CanonicalMediaId(json['mediaId'] as String),
        episodeId: CanonicalEpisodeId(json['episodeId'] as String),
        position: Duration(milliseconds: json['position'] as int),
        duration: json['duration'] == null
            ? null
            : Duration(milliseconds: json['duration'] as int),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
