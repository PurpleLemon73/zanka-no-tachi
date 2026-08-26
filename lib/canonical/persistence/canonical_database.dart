import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/bindings.dart' as domain;
import '../domain/identifiers.dart';
import '../domain/installments.dart';
import '../domain/media.dart';
import '../domain/user_state.dart';
import '../../local_library/local_asset.dart';
import '../../adapter_platform/adapter_descriptor.dart';
import '../../adapter_platform/adapter_sdk.dart';
import '../../adapter_platform/adapter_state.dart';
import '../../product_maturity/maturity_domain.dart';

part 'canonical_database.g.dart';

@DataClassName('CanonicalMediaRow')
class CanonicalMediaRecords extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get titleProviderId => text()();
  TextColumn get titleRawValue => text().nullable()();
  TextColumn get alternateTitlesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get description => text().nullable()();
  TextColumn get descriptionProviderId => text().nullable()();
  TextColumn get descriptionRawValue => text().nullable()();
  TextColumn get status => text()();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get coverLocator => text().nullable()();
  TextColumn get animeFormat => text().nullable()();
  TextColumn get airingSeason => text().nullable()();
  IntColumn get airingYear => integer().nullable()();
  TextColumn get airingRawLabel => text().nullable()();
  IntColumn get narrativeSeason => integer().nullable()();
  IntColumn get knownEpisodeTotal => integer().nullable()();
  TextColumn get rawEpisodeTotal => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CanonicalChapterRow')
class CanonicalChapterRecords extends Table {
  TextColumn get id => text()();
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get rawLabel => text()();
  TextColumn get normalizedNumber => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get volumeLabel => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CanonicalEpisodeRow')
class CanonicalEpisodeRecords extends Table {
  TextColumn get id => text()();
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get rawLabel => text()();
  RealColumn get number => real().nullable()();
  TextColumn get title => text().nullable()();
  IntColumn get narrativeSeason => integer().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MediaBindingRow')
class CanonicalMediaBindings extends Table {
  TextColumn get canonicalId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get providerId => text()();
  TextColumn get externalId => text()();
  TextColumn get relativeLocator => text().nullable()();
  TextColumn get rawMetadataJson => text().withDefault(const Constant('{}'))();
  @override
  Set<Column<Object>> get primaryKey => {providerId, externalId};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {canonicalId, providerId},
  ];
}

@DataClassName('ChapterBindingRow')
class CanonicalChapterBindings extends Table {
  TextColumn get canonicalId =>
      text().references(CanonicalChapterRecords, #id)();
  TextColumn get providerId => text()();
  TextColumn get externalId => text()();
  TextColumn get relativeLocator => text().nullable()();
  TextColumn get rawMetadataJson => text().withDefault(const Constant('{}'))();
  @override
  Set<Column<Object>> get primaryKey => {providerId, externalId};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {canonicalId, providerId},
  ];
}

@DataClassName('EpisodeBindingRow')
class CanonicalEpisodeBindings extends Table {
  TextColumn get canonicalId =>
      text().references(CanonicalEpisodeRecords, #id)();
  TextColumn get providerId => text()();
  TextColumn get externalId => text()();
  TextColumn get relativeLocator => text().nullable()();
  TextColumn get rawMetadataJson => text().withDefault(const Constant('{}'))();
  @override
  Set<Column<Object>> get primaryKey => {providerId, externalId};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {canonicalId, providerId},
  ];
}

@DataClassName('CanonicalLibraryRow')
class CanonicalLibraryRecords extends Table {
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  BoolColumn get isSaved => boolean()();
  BoolColumn get isFavorite => boolean()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

@DataClassName('CanonicalMangaProgressRow')
class CanonicalMangaProgressRecords extends Table {
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get chapterId => text().references(CanonicalChapterRecords, #id)();
  IntColumn get pageIndex =>
      integer().customConstraint('NOT NULL CHECK (page_index >= 0)')();
  IntColumn get totalPages => integer().nullable().customConstraint(
    'CHECK (total_pages IS NULL OR total_pages >= 0)',
  )();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

@DataClassName('CanonicalAnimeProgressRow')
class CanonicalAnimeProgressRecords extends Table {
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get episodeId => text().references(CanonicalEpisodeRecords, #id)();
  IntColumn get positionMilliseconds => integer().customConstraint(
    'NOT NULL CHECK (position_milliseconds >= 0)',
  )();
  IntColumn get durationMilliseconds => integer().nullable().customConstraint(
    'CHECK (duration_milliseconds IS NULL OR duration_milliseconds >= 0)',
  )();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

@DataClassName('CanonicalAliasRow')
class CanonicalMediaAliases extends Table {
  TextColumn get historicalId => text()();
  TextColumn get targetId => text()();
  TextColumn get mergeAuditId => text()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {historicalId};
}

@DataClassName('MergeAuditRow')
class CanonicalMergeAudits extends Table {
  TextColumn get id => text()();
  TextColumn get sourceId => text()();
  TextColumn get targetId => text()();
  TextColumn get reason => text()();
  TextColumn get snapshotJson => text()();
  TextColumn get mergedFingerprint => text()();
  TextColumn get conflictsJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get undoneAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MangaSourcePageResumeRow')
class MangaSourcePageResumes extends Table {
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get chapterId => text().references(CanonicalChapterRecords, #id)();
  TextColumn get providerId => text()();
  TextColumn get chapterExternalId => text()();
  IntColumn get pageIndex =>
      integer().customConstraint('NOT NULL CHECK (page_index >= 0)')();
  IntColumn get totalPages => integer().nullable().customConstraint(
    'CHECK (total_pages IS NULL OR total_pages >= 0)',
  )();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {providerId, chapterExternalId};
}

@DataClassName('AnimeSourcePlaybackResumeRow')
class AnimeSourcePlaybackResumes extends Table {
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get episodeId => text().references(CanonicalEpisodeRecords, #id)();
  TextColumn get providerId => text()();
  TextColumn get episodeExternalId => text()();
  IntColumn get positionMilliseconds => integer().customConstraint(
    'NOT NULL CHECK (position_milliseconds >= 0)',
  )();
  IntColumn get durationMilliseconds => integer().nullable().customConstraint(
    'CHECK (duration_milliseconds IS NULL OR duration_milliseconds >= 0)',
  )();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {providerId, episodeExternalId};
}

@DataClassName('PreferredMediaSourceRow')
class PreferredMediaSources extends Table {
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get providerId => text()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

@DataClassName('LocalAssetRow')
class LocalAssetRecords extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get ownership => text()();
  TextColumn get state => text()();
  TextColumn get providerId => text()();
  TextColumn get bindingExternalId => text()();
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get installmentId => text()();
  TextColumn get originalName => text()();
  TextColumn get managedRelativePath => text().nullable()();
  IntColumn get sizeBytes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {id};
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {providerId, bindingExternalId},
  ];
}

@DataClassName('AdapterConfigurationRow')
class AdapterConfigurations extends Table {
  TextColumn get adapterId => text()();
  BoolColumn get enabled => boolean()();
  TextColumn get baseUrl => text().nullable()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {adapterId};
}

@DataClassName('AdapterReliabilityRow')
class AdapterReliabilityRecords extends Table {
  TextColumn get adapterId => text()();
  DateTimeColumn get lastCheckedAt => dateTime().nullable()();
  DateTimeColumn get lastSuccessAt => dateTime().nullable()();
  DateTimeColumn get lastFailureAt => dateTime().nullable()();
  IntColumn get consecutiveFailures =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get lastParserMismatchAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {adapterId};
}

@DataClassName('MetadataEnrichmentRow')
class MetadataEnrichmentRecords extends Table {
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get adapterId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get observedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId, adapterId};
}

@DataClassName('MetadataOverrideRow')
class MetadataOverrideRecords extends Table {
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  TextColumn get displayTitle => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get coverLocator => text().nullable()();
  TextColumn get alternateTitlesJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get genresJson => text().withDefault(const Constant('[]'))();
  TextColumn get status => text().nullable()();
  TextColumn get animeFormat => text().nullable()();
  TextColumn get creatorOrStudio => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

@DataClassName('ChapterUserEditRow')
class ChapterUserEditRecords extends Table {
  TextColumn get chapterId => text().references(CanonicalChapterRecords, #id)();
  TextColumn get rawLabel => text()();
  TextColumn get kind => text()();
  TextColumn get volumeLabel => text().nullable()();
  RealColumn get explicitOrder => real().nullable()();
  TextColumn get sourceDisplayLabel => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {chapterId};
}

@DataClassName('EpisodeUserEditRow')
class EpisodeUserEditRecords extends Table {
  TextColumn get episodeId => text().references(CanonicalEpisodeRecords, #id)();
  TextColumn get rawLabel => text()();
  RealColumn get number => real().nullable()();
  TextColumn get kind => text()();
  IntColumn get narrativeSeason => integer().nullable()();
  RealColumn get explicitOrder => real().nullable()();
  TextColumn get sourceDisplayLabel => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {episodeId};
}

@DataClassName('ChapterCompletionRow')
class ChapterCompletionRecords extends Table {
  TextColumn get chapterId => text().references(CanonicalChapterRecords, #id)();
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get origin => text()();
  @override
  Set<Column<Object>> get primaryKey => {chapterId};
}

@DataClassName('EpisodeCompletionRow')
class EpisodeCompletionRecords extends Table {
  TextColumn get episodeId => text().references(CanonicalEpisodeRecords, #id)();
  TextColumn get mediaId => text().references(CanonicalMediaRecords, #id)();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get origin => text()();
  @override
  Set<Column<Object>> get primaryKey => {episodeId};
}

@DriftDatabase(
  tables: [
    CanonicalMediaRecords,
    CanonicalChapterRecords,
    CanonicalEpisodeRecords,
    CanonicalMediaBindings,
    CanonicalChapterBindings,
    CanonicalEpisodeBindings,
    CanonicalLibraryRecords,
    CanonicalMangaProgressRecords,
    CanonicalAnimeProgressRecords,
    CanonicalMediaAliases,
    CanonicalMergeAudits,
    MangaSourcePageResumes,
    AnimeSourcePlaybackResumes,
    PreferredMediaSources,
    LocalAssetRecords,
    AdapterConfigurations,
    AdapterReliabilityRecords,
    MetadataEnrichmentRecords,
    MetadataOverrideRecords,
    ChapterUserEditRecords,
    EpisodeUserEditRecords,
    ChapterCompletionRecords,
    EpisodeCompletionRecords,
  ],
)
class CanonicalDatabase extends _$CanonicalDatabase {
  CanonicalDatabase(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(canonicalMediaAliases);
        await migrator.createTable(canonicalMergeAudits);
        await migrator.createTable(mangaSourcePageResumes);
        await migrator.createTable(preferredMediaSources);
      }
      if (from < 3) {
        await migrator.createTable(animeSourcePlaybackResumes);
      }
      if (from < 4) await migrator.createTable(localAssetRecords);
      if (from < 5) {
        await migrator.createTable(adapterConfigurations);
        await migrator.createTable(adapterReliabilityRecords);
        await migrator.createTable(metadataEnrichmentRecords);
        await migrator.createTable(metadataOverrideRecords);
      }
      if (from < 6) {
        if (from >= 5) {
          await migrator.addColumn(
            metadataOverrideRecords,
            metadataOverrideRecords.description,
          );
          await migrator.addColumn(
            metadataOverrideRecords,
            metadataOverrideRecords.status,
          );
          await migrator.addColumn(
            metadataOverrideRecords,
            metadataOverrideRecords.animeFormat,
          );
          await migrator.addColumn(
            metadataOverrideRecords,
            metadataOverrideRecords.creatorOrStudio,
          );
        }
        await migrator.createTable(chapterUserEditRecords);
        await migrator.createTable(episodeUserEditRecords);
        await migrator.createTable(chapterCompletionRecords);
        await migrator.createTable(episodeCompletionRecords);
      }
    },
    beforeOpen: (details) async => customStatement('PRAGMA foreign_keys = ON'),
  );

  Future<void> saveMedia(CanonicalMedia media) =>
      into(canonicalMediaRecords).insertOnConflictUpdate(
        CanonicalMediaRecordsCompanion.insert(
          id: media.id.value,
          kind: media.kind.name,
          title: media.title.value,
          titleProviderId: media.title.provenance.providerId.value,
          titleRawValue: Value(media.title.rawValue),
          alternateTitlesJson: Value(_encodeSourced(media.alternateTitles)),
          description: Value(media.description?.value),
          descriptionProviderId: Value(
            media.description?.provenance.providerId.value,
          ),
          descriptionRawValue: Value(media.description?.rawValue),
          status: media.status.name,
          genresJson: Value(_encodeSourced(media.genres)),
          coverLocator: Value(media.coverLocator),
          animeFormat: Value(
            media is CanonicalAnime ? media.format.name : null,
          ),
          airingSeason: Value(
            media is CanonicalAnime ? media.airingWindow?.season.name : null,
          ),
          airingYear: Value(
            media is CanonicalAnime ? media.airingWindow?.year : null,
          ),
          airingRawLabel: Value(
            media is CanonicalAnime ? media.airingWindow?.rawLabel : null,
          ),
          narrativeSeason: Value(
            media is CanonicalAnime ? media.narrativeSeason?.value : null,
          ),
          knownEpisodeTotal: Value(
            media is CanonicalAnime ? media.knownEpisodeTotal : null,
          ),
          rawEpisodeTotal: Value(
            media is CanonicalAnime ? media.rawEpisodeTotal : null,
          ),
        ),
      );

  Future<CanonicalMedia?> media(CanonicalMediaId id) async {
    final row = await (select(
      canonicalMediaRecords,
    )..where((r) => r.id.equals(id.value))).getSingleOrNull();
    if (row == null) return null;
    final title = SourcedValue(
      value: row.title,
      provenance: FieldProvenance(providerId: ProviderId(row.titleProviderId)),
      rawValue: row.titleRawValue,
    );
    final description =
        row.description == null || row.descriptionProviderId == null
        ? null
        : SourcedValue(
            value: row.description!,
            provenance: FieldProvenance(
              providerId: ProviderId(row.descriptionProviderId!),
            ),
            rawValue: row.descriptionRawValue,
          );
    final common = (
      alternateTitles: _decodeSourced(row.alternateTitlesJson),
      genres: _decodeSourced(row.genresJson),
    );
    if (CanonicalMediaKind.values.byName(row.kind) ==
        CanonicalMediaKind.manga) {
      return CanonicalManga(
        id: id,
        title: title,
        alternateTitles: common.alternateTitles,
        description: description,
        status: CanonicalMediaStatus.values.byName(row.status),
        genres: common.genres,
        coverLocator: row.coverLocator,
      );
    }
    final window =
        row.airingSeason == null ||
            row.airingYear == null ||
            row.airingRawLabel == null
        ? null
        : AiringWindow(
            season: AiringSeason.values.byName(row.airingSeason!),
            year: row.airingYear!,
            rawLabel: row.airingRawLabel!,
          );
    return CanonicalAnime(
      id: id,
      title: title,
      format: AnimeFormat.values.byName(
        row.animeFormat ?? AnimeFormat.unknown.name,
      ),
      alternateTitles: common.alternateTitles,
      description: description,
      status: CanonicalMediaStatus.values.byName(row.status),
      genres: common.genres,
      coverLocator: row.coverLocator,
      airingWindow: window,
      narrativeSeason: row.narrativeSeason == null
          ? null
          : NarrativeSeasonNumber(row.narrativeSeason!),
      knownEpisodeTotal: row.knownEpisodeTotal,
      rawEpisodeTotal: row.rawEpisodeTotal,
    );
  }

  Future<List<CanonicalMedia>> allMedia() async {
    final aliases = await select(canonicalMediaAliases).get();
    final retiredIds = aliases.map((alias) => alias.historicalId).toSet();
    final rows = await select(canonicalMediaRecords).get();
    final result = <CanonicalMedia>[];
    for (final row in rows) {
      if (retiredIds.contains(row.id)) continue;
      final value = await media(CanonicalMediaId(row.id));
      if (value != null) result.add(value);
    }
    return result;
  }

  Future<void> saveChapter(CanonicalChapter chapter) =>
      into(canonicalChapterRecords).insertOnConflictUpdate(
        CanonicalChapterRecordsCompanion.insert(
          id: chapter.id.value,
          mediaId: chapter.mediaId.value,
          rawLabel: chapter.number.rawLabel,
          normalizedNumber: Value(chapter.number.normalizedNumber),
          title: Value(chapter.title),
          volumeLabel: Value(chapter.volumeLabel),
        ),
      );
  Future<void> saveEpisode(CanonicalEpisode episode) =>
      into(canonicalEpisodeRecords).insertOnConflictUpdate(
        CanonicalEpisodeRecordsCompanion.insert(
          id: episode.id.value,
          mediaId: episode.mediaId.value,
          rawLabel: episode.label.rawLabel,
          number: Value(episode.label.number),
          title: Value(episode.title),
          narrativeSeason: Value(episode.narrativeSeason),
        ),
      );

  Future<CanonicalChapter?> chapter(CanonicalChapterId id) async {
    final row = await (select(
      canonicalChapterRecords,
    )..where((r) => r.id.equals(id.value))).getSingleOrNull();
    return row == null
        ? null
        : CanonicalChapter(
            id: id,
            mediaId: CanonicalMediaId(row.mediaId),
            number: ChapterNumber.parse(row.rawLabel),
            title: row.title,
            volumeLabel: row.volumeLabel,
          );
  }

  Future<CanonicalEpisode?> episode(CanonicalEpisodeId id) async {
    final row = await (select(
      canonicalEpisodeRecords,
    )..where((r) => r.id.equals(id.value))).getSingleOrNull();
    return row == null
        ? null
        : CanonicalEpisode(
            id: id,
            mediaId: CanonicalMediaId(row.mediaId),
            label: EpisodeLabel(rawLabel: row.rawLabel, number: row.number),
            title: row.title,
            narrativeSeason: row.narrativeSeason,
          );
  }

  Future<List<CanonicalChapter>> chaptersFor(CanonicalMediaId mediaId) async {
    final rows = await (select(
      canonicalChapterRecords,
    )..where((row) => row.mediaId.equals(mediaId.value))).get();
    return rows
        .map(
          (row) => CanonicalChapter(
            id: CanonicalChapterId(row.id),
            mediaId: mediaId,
            number: ChapterNumber.parse(row.rawLabel),
            title: row.title,
            volumeLabel: row.volumeLabel,
          ),
        )
        .toList();
  }

  Future<List<CanonicalEpisode>> episodesFor(CanonicalMediaId mediaId) async {
    final rows = await (select(
      canonicalEpisodeRecords,
    )..where((row) => row.mediaId.equals(mediaId.value))).get();
    return rows
        .map(
          (row) => CanonicalEpisode(
            id: CanonicalEpisodeId(row.id),
            mediaId: mediaId,
            label: EpisodeLabel(rawLabel: row.rawLabel, number: row.number),
            title: row.title,
            narrativeSeason: row.narrativeSeason,
          ),
        )
        .toList();
  }

  Future<void> saveMediaBinding(domain.MediaSourceBinding binding) =>
      transaction(() async {
        await (delete(canonicalMediaBindings)..where(
              (row) =>
                  row.canonicalId.equals(binding.canonicalId.value) &
                  row.providerId.equals(binding.providerId.value),
            ))
            .go();
        await into(canonicalMediaBindings).insert(
          CanonicalMediaBindingsCompanion.insert(
            canonicalId: binding.canonicalId.value,
            providerId: binding.providerId.value,
            externalId: binding.externalId,
            relativeLocator: Value(binding.relativeLocator),
            rawMetadataJson: Value(jsonEncode(binding.rawMetadata)),
          ),
        );
      });

  Future<void> saveChapterBinding(domain.ChapterSourceBinding binding) =>
      transaction(() async {
        await (delete(canonicalChapterBindings)..where(
              (row) =>
                  row.canonicalId.equals(binding.canonicalId.value) &
                  row.providerId.equals(binding.providerId.value),
            ))
            .go();
        await into(canonicalChapterBindings).insert(
          CanonicalChapterBindingsCompanion.insert(
            canonicalId: binding.canonicalId.value,
            providerId: binding.providerId.value,
            externalId: binding.externalId,
            relativeLocator: Value(binding.relativeLocator),
            rawMetadataJson: Value(jsonEncode(binding.rawMetadata)),
          ),
        );
      });

  Future<void> saveEpisodeBinding(domain.EpisodeSourceBinding binding) =>
      transaction(() async {
        await (delete(canonicalEpisodeBindings)..where(
              (row) =>
                  row.canonicalId.equals(binding.canonicalId.value) &
                  row.providerId.equals(binding.providerId.value),
            ))
            .go();
        await into(canonicalEpisodeBindings).insert(
          CanonicalEpisodeBindingsCompanion.insert(
            canonicalId: binding.canonicalId.value,
            providerId: binding.providerId.value,
            externalId: binding.externalId,
            relativeLocator: Value(binding.relativeLocator),
            rawMetadataJson: Value(jsonEncode(binding.rawMetadata)),
          ),
        );
      });

  Future<CanonicalChapterId?> chapterBinding(
    ProviderId providerId,
    String externalId,
  ) async {
    final row =
        await (select(canonicalChapterBindings)..where(
              (r) =>
                  r.providerId.equals(providerId.value) &
                  r.externalId.equals(externalId),
            ))
            .getSingleOrNull();
    return row == null ? null : CanonicalChapterId(row.canonicalId);
  }

  Future<CanonicalMediaId?> mediaBinding(
    ProviderId providerId,
    String externalId,
  ) async {
    final row =
        await (select(canonicalMediaBindings)..where(
              (r) =>
                  r.providerId.equals(providerId.value) &
                  r.externalId.equals(externalId),
            ))
            .getSingleOrNull();
    return row == null ? null : CanonicalMediaId(row.canonicalId);
  }

  Future<CanonicalEpisodeId?> episodeBinding(
    ProviderId providerId,
    String externalId,
  ) async {
    final row =
        await (select(canonicalEpisodeBindings)..where(
              (r) =>
                  r.providerId.equals(providerId.value) &
                  r.externalId.equals(externalId),
            ))
            .getSingleOrNull();
    return row == null ? null : CanonicalEpisodeId(row.canonicalId);
  }

  Future<domain.MediaSourceBinding?> mediaSourceBinding(
    ProviderId providerId,
    String externalId,
  ) async {
    final row =
        await (select(canonicalMediaBindings)..where(
              (r) =>
                  r.providerId.equals(providerId.value) &
                  r.externalId.equals(externalId),
            ))
            .getSingleOrNull();
    return row == null
        ? null
        : domain.MediaSourceBinding(
            canonicalId: CanonicalMediaId(row.canonicalId),
            providerId: ProviderId(row.providerId),
            externalId: row.externalId,
            relativeLocator: row.relativeLocator,
            rawMetadata: _decodeMetadata(row.rawMetadataJson),
          );
  }

  Future<List<domain.MediaSourceBinding>> mediaBindingsFor(
    CanonicalMediaId mediaId,
  ) async {
    final rows = await (select(
      canonicalMediaBindings,
    )..where((row) => row.canonicalId.equals(mediaId.value))).get();
    return rows
        .map(
          (row) => domain.MediaSourceBinding(
            canonicalId: mediaId,
            providerId: ProviderId(row.providerId),
            externalId: row.externalId,
            relativeLocator: row.relativeLocator,
            rawMetadata: _decodeMetadata(row.rawMetadataJson),
          ),
        )
        .toList();
  }

  /// Loads all media bindings in one query for summary/list screens.
  Future<Map<CanonicalMediaId, List<domain.MediaSourceBinding>>>
  allMediaBindingsByMedia() async {
    final result = <CanonicalMediaId, List<domain.MediaSourceBinding>>{};
    for (final row in await select(canonicalMediaBindings).get()) {
      final id = CanonicalMediaId(row.canonicalId);
      result
          .putIfAbsent(id, () => [])
          .add(
            domain.MediaSourceBinding(
              canonicalId: id,
              providerId: ProviderId(row.providerId),
              externalId: row.externalId,
              relativeLocator: row.relativeLocator,
              rawMetadata: _decodeMetadata(row.rawMetadataJson),
            ),
          );
    }
    return result;
  }

  Future<Map<CanonicalChapterId, String>> allChapterLabels() async => {
    for (final row in await select(canonicalChapterRecords).get())
      CanonicalChapterId(row.id): row.rawLabel,
  };

  Future<Map<CanonicalEpisodeId, String>> allEpisodeLabels() async => {
    for (final row in await select(canonicalEpisodeRecords).get())
      CanonicalEpisodeId(row.id): row.rawLabel,
  };

  Future<List<domain.ChapterSourceBinding>> chapterBindingsFor(
    CanonicalChapterId chapterId,
  ) async {
    final rows = await (select(
      canonicalChapterBindings,
    )..where((row) => row.canonicalId.equals(chapterId.value))).get();
    return rows
        .map(
          (row) => domain.ChapterSourceBinding(
            canonicalId: chapterId,
            providerId: ProviderId(row.providerId),
            externalId: row.externalId,
            relativeLocator: row.relativeLocator,
            rawMetadata: _decodeMetadata(row.rawMetadataJson),
          ),
        )
        .toList();
  }

  Future<Map<CanonicalChapterId, List<domain.ChapterSourceBinding>>>
  allChapterBindingsByChapter() async {
    final result = <CanonicalChapterId, List<domain.ChapterSourceBinding>>{};
    for (final row in await select(canonicalChapterBindings).get()) {
      final id = CanonicalChapterId(row.canonicalId);
      result
          .putIfAbsent(id, () => [])
          .add(
            domain.ChapterSourceBinding(
              canonicalId: id,
              providerId: ProviderId(row.providerId),
              externalId: row.externalId,
              relativeLocator: row.relativeLocator,
              rawMetadata: _decodeMetadata(row.rawMetadataJson),
            ),
          );
    }
    return result;
  }

  Future<List<domain.EpisodeSourceBinding>> episodeBindingsFor(
    CanonicalEpisodeId episodeId,
  ) async {
    final rows = await (select(
      canonicalEpisodeBindings,
    )..where((row) => row.canonicalId.equals(episodeId.value))).get();
    return rows
        .map(
          (row) => domain.EpisodeSourceBinding(
            canonicalId: episodeId,
            providerId: ProviderId(row.providerId),
            externalId: row.externalId,
            relativeLocator: row.relativeLocator,
            rawMetadata: _decodeMetadata(row.rawMetadataJson),
          ),
        )
        .toList();
  }

  Future<Map<CanonicalEpisodeId, List<domain.EpisodeSourceBinding>>>
  allEpisodeBindingsByEpisode() async {
    final result = <CanonicalEpisodeId, List<domain.EpisodeSourceBinding>>{};
    for (final row in await select(canonicalEpisodeBindings).get()) {
      final id = CanonicalEpisodeId(row.canonicalId);
      result
          .putIfAbsent(id, () => [])
          .add(
            domain.EpisodeSourceBinding(
              canonicalId: id,
              providerId: ProviderId(row.providerId),
              externalId: row.externalId,
              relativeLocator: row.relativeLocator,
              rawMetadata: _decodeMetadata(row.rawMetadataJson),
            ),
          );
    }
    return result;
  }

  Future<CanonicalMediaId> resolveCanonicalId(CanonicalMediaId id) async {
    var current = id;
    final visited = <CanonicalMediaId>{};
    while (true) {
      if (!visited.add(current)) {
        throw StateError('Canonical alias cycle detected at ${current.value}');
      }
      final row =
          await (select(canonicalMediaAliases)
                ..where((alias) => alias.historicalId.equals(current.value)))
              .getSingleOrNull();
      if (row == null) return current;
      current = CanonicalMediaId(row.targetId);
    }
  }

  Future<void> saveCanonicalAlias({
    required CanonicalMediaId historicalId,
    required CanonicalMediaId targetId,
    required String mergeAuditId,
    required DateTime createdAt,
  }) async {
    if (historicalId == targetId) {
      throw StateError('A canonical ID cannot alias itself');
    }
    final resolvedTarget = await resolveCanonicalId(targetId);
    if (resolvedTarget == historicalId) {
      throw StateError('Canonical alias would create a cycle');
    }
    await into(canonicalMediaAliases).insert(
      CanonicalMediaAliasesCompanion.insert(
        historicalId: historicalId.value,
        targetId: resolvedTarget.value,
        mergeAuditId: mergeAuditId,
        createdAt: createdAt,
      ),
    );
  }

  Future<void> removeProviderBindings(ProviderId providerId) =>
      transaction(() async {
        await (delete(
          canonicalChapterBindings,
        )..where((r) => r.providerId.equals(providerId.value))).go();
        await (delete(
          canonicalEpisodeBindings,
        )..where((r) => r.providerId.equals(providerId.value))).go();
        await (delete(
          canonicalMediaBindings,
        )..where((r) => r.providerId.equals(providerId.value))).go();
      });

  Future<void> deleteMediaBindingExact(
    ProviderId providerId,
    String externalId,
  ) =>
      (delete(canonicalMediaBindings)..where(
            (row) =>
                row.providerId.equals(providerId.value) &
                row.externalId.equals(externalId),
          ))
          .go();

  Future<void> saveLibraryEntry(CanonicalLibraryEntry entry) =>
      into(canonicalLibraryRecords).insertOnConflictUpdate(
        CanonicalLibraryRecordsCompanion.insert(
          mediaId: entry.mediaId.value,
          isSaved: entry.isSaved,
          isFavorite: entry.isFavorite,
          status: entry.status.name,
          createdAt: entry.createdAt,
          updatedAt: entry.updatedAt,
        ),
      );
  Future<CanonicalLibraryEntry?> libraryEntry(CanonicalMediaId mediaId) async {
    final row = await (select(
      canonicalLibraryRecords,
    )..where((r) => r.mediaId.equals(mediaId.value))).getSingleOrNull();
    return row == null
        ? null
        : CanonicalLibraryEntry(
            mediaId: mediaId,
            isSaved: row.isSaved,
            isFavorite: row.isFavorite,
            status: CanonicalLibraryStatus.values.byName(row.status),
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          );
  }

  Future<List<CanonicalLibraryEntry>> allLibraryEntries() async {
    final rows = await select(canonicalLibraryRecords).get();
    return rows
        .map(
          (row) => CanonicalLibraryEntry(
            mediaId: CanonicalMediaId(row.mediaId),
            isSaved: row.isSaved,
            isFavorite: row.isFavorite,
            status: CanonicalLibraryStatus.values.byName(row.status),
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  Future<List<CanonicalMangaProgress>> allMangaProgress() async {
    final rows = await select(canonicalMangaProgressRecords).get();
    return rows
        .map(
          (row) => CanonicalMangaProgress(
            mediaId: CanonicalMediaId(row.mediaId),
            chapterId: CanonicalChapterId(row.chapterId),
            pageIndex: row.pageIndex,
            totalPages: row.totalPages,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  Future<List<CanonicalAnimeProgress>> allAnimeProgress() async {
    final rows = await select(canonicalAnimeProgressRecords).get();
    return rows
        .map(
          (row) => CanonicalAnimeProgress(
            mediaId: CanonicalMediaId(row.mediaId),
            episodeId: CanonicalEpisodeId(row.episodeId),
            position: Duration(milliseconds: row.positionMilliseconds),
            duration: row.durationMilliseconds == null
                ? null
                : Duration(milliseconds: row.durationMilliseconds!),
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  Future<void> saveMangaProgress(CanonicalMangaProgress progress) async {
    final installment = await chapter(progress.chapterId);
    if (installment == null || installment.mediaId != progress.mediaId) {
      throw StateError(
        'Manga progress chapter must belong to its canonical media',
      );
    }
    await into(canonicalMangaProgressRecords).insertOnConflictUpdate(
      CanonicalMangaProgressRecordsCompanion.insert(
        mediaId: progress.mediaId.value,
        chapterId: progress.chapterId.value,
        pageIndex: progress.pageIndex,
        totalPages: Value(progress.totalPages),
        updatedAt: progress.updatedAt,
      ),
    );
  }

  Future<CanonicalMangaProgress?> mangaProgress(
    CanonicalMediaId mediaId,
  ) async {
    final row = await (select(
      canonicalMangaProgressRecords,
    )..where((r) => r.mediaId.equals(mediaId.value))).getSingleOrNull();
    return row == null
        ? null
        : CanonicalMangaProgress(
            mediaId: mediaId,
            chapterId: CanonicalChapterId(row.chapterId),
            pageIndex: row.pageIndex,
            totalPages: row.totalPages,
            updatedAt: row.updatedAt,
          );
  }

  Future<void> saveAnimeProgress(CanonicalAnimeProgress progress) async {
    final installment = await episode(progress.episodeId);
    if (installment == null || installment.mediaId != progress.mediaId) {
      throw StateError(
        'Anime progress episode must belong to its canonical media',
      );
    }
    await into(canonicalAnimeProgressRecords).insertOnConflictUpdate(
      CanonicalAnimeProgressRecordsCompanion.insert(
        mediaId: progress.mediaId.value,
        episodeId: progress.episodeId.value,
        positionMilliseconds: progress.position.inMilliseconds,
        durationMilliseconds: Value(progress.duration?.inMilliseconds),
        updatedAt: progress.updatedAt,
      ),
    );
  }

  Future<CanonicalAnimeProgress?> animeProgress(
    CanonicalMediaId mediaId,
  ) async {
    final row = await (select(
      canonicalAnimeProgressRecords,
    )..where((r) => r.mediaId.equals(mediaId.value))).getSingleOrNull();
    return row == null
        ? null
        : CanonicalAnimeProgress(
            mediaId: mediaId,
            episodeId: CanonicalEpisodeId(row.episodeId),
            position: Duration(milliseconds: row.positionMilliseconds),
            duration: row.durationMilliseconds == null
                ? null
                : Duration(milliseconds: row.durationMilliseconds!),
            updatedAt: row.updatedAt,
          );
  }

  Future<void> saveMangaSourcePageResume(MangaSourcePageResume resume) async {
    final binding = await chapterBinding(
      resume.providerId,
      resume.chapterExternalId,
    );
    if (binding != resume.chapterId) {
      throw StateError('Page resume must reference its exact source binding');
    }
    final chapterValue = await chapter(resume.chapterId);
    if (chapterValue == null || chapterValue.mediaId != resume.mediaId) {
      throw StateError(
        'Page resume chapter must belong to its canonical media',
      );
    }
    await into(mangaSourcePageResumes).insertOnConflictUpdate(
      MangaSourcePageResumesCompanion.insert(
        mediaId: resume.mediaId.value,
        chapterId: resume.chapterId.value,
        providerId: resume.providerId.value,
        chapterExternalId: resume.chapterExternalId,
        pageIndex: resume.pageIndex,
        totalPages: Value(resume.totalPages),
        updatedAt: resume.updatedAt,
      ),
    );
  }

  Future<MangaSourcePageResume?> mangaSourcePageResume(
    ProviderId providerId,
    String chapterExternalId,
  ) async {
    final row =
        await (select(mangaSourcePageResumes)..where(
              (resume) =>
                  resume.providerId.equals(providerId.value) &
                  resume.chapterExternalId.equals(chapterExternalId),
            ))
            .getSingleOrNull();
    return row == null
        ? null
        : MangaSourcePageResume(
            mediaId: CanonicalMediaId(row.mediaId),
            chapterId: CanonicalChapterId(row.chapterId),
            providerId: ProviderId(row.providerId),
            chapterExternalId: row.chapterExternalId,
            pageIndex: row.pageIndex,
            totalPages: row.totalPages,
            updatedAt: row.updatedAt,
          );
  }

  Future<void> saveAnimeSourcePlaybackResume(
    AnimeSourcePlaybackResume resume,
  ) async {
    final binding = await episodeBinding(
      resume.providerId,
      resume.episodeExternalId,
    );
    if (binding != resume.episodeId) {
      throw StateError(
        'Playback resume must reference its exact source binding',
      );
    }
    final episodeValue = await episode(resume.episodeId);
    if (episodeValue == null || episodeValue.mediaId != resume.mediaId) {
      throw StateError(
        'Playback resume episode must belong to its canonical media',
      );
    }
    await into(animeSourcePlaybackResumes).insertOnConflictUpdate(
      AnimeSourcePlaybackResumesCompanion.insert(
        mediaId: resume.mediaId.value,
        episodeId: resume.episodeId.value,
        providerId: resume.providerId.value,
        episodeExternalId: resume.episodeExternalId,
        positionMilliseconds: resume.position.inMilliseconds,
        durationMilliseconds: Value(resume.duration?.inMilliseconds),
        updatedAt: resume.updatedAt,
      ),
    );
  }

  Future<AnimeSourcePlaybackResume?> animeSourcePlaybackResume(
    ProviderId providerId,
    String episodeExternalId,
  ) async {
    final row =
        await (select(animeSourcePlaybackResumes)..where(
              (resume) =>
                  resume.providerId.equals(providerId.value) &
                  resume.episodeExternalId.equals(episodeExternalId),
            ))
            .getSingleOrNull();
    return row == null
        ? null
        : AnimeSourcePlaybackResume(
            mediaId: CanonicalMediaId(row.mediaId),
            episodeId: CanonicalEpisodeId(row.episodeId),
            providerId: ProviderId(row.providerId),
            episodeExternalId: row.episodeExternalId,
            position: Duration(milliseconds: row.positionMilliseconds),
            duration: row.durationMilliseconds == null
                ? null
                : Duration(milliseconds: row.durationMilliseconds!),
            updatedAt: row.updatedAt,
          );
  }

  Future<void> saveLocalAsset(LocalAsset asset) =>
      into(localAssetRecords).insertOnConflictUpdate(
        LocalAssetRecordsCompanion.insert(
          id: asset.id.value,
          kind: asset.kind.name,
          ownership: asset.ownership.name,
          state: asset.state.name,
          providerId: asset.providerId.value,
          bindingExternalId: asset.bindingExternalId,
          mediaId: asset.mediaId.value,
          installmentId: asset.installmentId,
          originalName: asset.originalName,
          managedRelativePath: Value(asset.managedRelativePath),
          sizeBytes: Value(asset.sizeBytes),
          createdAt: asset.createdAt,
          updatedAt: asset.updatedAt,
        ),
      );

  Future<List<LocalAsset>> allLocalAssets() async =>
      (await select(localAssetRecords).get()).map(_localAssetFromRow).toList();

  Future<LocalAsset?> localAsset(LocalAssetId id) async {
    final row = await (select(
      localAssetRecords,
    )..where((item) => item.id.equals(id.value))).getSingleOrNull();
    return row == null ? null : _localAssetFromRow(row);
  }

  Future<void> deleteLocalAssetRecord(LocalAssetId id) => (delete(
    localAssetRecords,
  )..where((item) => item.id.equals(id.value))).go();

  Future<void> deleteChapterBindingExact(
    ProviderId providerId,
    String externalId,
  ) async {
    await (delete(mangaSourcePageResumes)..where(
          (row) =>
              row.providerId.equals(providerId.value) &
              row.chapterExternalId.equals(externalId),
        ))
        .go();
    await (delete(canonicalChapterBindings)..where(
          (row) =>
              row.providerId.equals(providerId.value) &
              row.externalId.equals(externalId),
        ))
        .go();
  }

  Future<void> deleteEpisodeBindingExact(
    ProviderId providerId,
    String externalId,
  ) async {
    await (delete(animeSourcePlaybackResumes)..where(
          (row) =>
              row.providerId.equals(providerId.value) &
              row.episodeExternalId.equals(externalId),
        ))
        .go();
    await (delete(canonicalEpisodeBindings)..where(
          (row) =>
              row.providerId.equals(providerId.value) &
              row.externalId.equals(externalId),
        ))
        .go();
  }

  Future<void> setPreferredProvider(
    CanonicalMediaId mediaId,
    ProviderId? providerId,
  ) async {
    if (providerId == null) {
      await (delete(
        preferredMediaSources,
      )..where((row) => row.mediaId.equals(mediaId.value))).go();
      return;
    }
    await into(preferredMediaSources).insertOnConflictUpdate(
      PreferredMediaSourcesCompanion.insert(
        mediaId: mediaId.value,
        providerId: providerId.value,
      ),
    );
  }

  Future<ProviderId?> preferredProvider(CanonicalMediaId mediaId) async {
    final row = await (select(
      preferredMediaSources,
    )..where((item) => item.mediaId.equals(mediaId.value))).getSingleOrNull();
    return row == null ? null : ProviderId(row.providerId);
  }

  Future<void> saveAdapterConfiguration(PersistedAdapterConfiguration value) =>
      into(adapterConfigurations).insertOnConflictUpdate(
        AdapterConfigurationsCompanion.insert(
          adapterId: value.adapterId.value,
          enabled: value.enabled,
          baseUrl: Value(value.baseUrl?.toString()),
          sortOrder: value.order,
          updatedAt: value.updatedAt,
        ),
      );

  Future<List<PersistedAdapterConfiguration>>
  allAdapterConfigurations() async =>
      (await (select(
            adapterConfigurations,
          )..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).get())
          .map(
            (row) => PersistedAdapterConfiguration(
              adapterId: AdapterId(row.adapterId),
              enabled: row.enabled,
              baseUrl: row.baseUrl == null ? null : Uri.tryParse(row.baseUrl!),
              order: row.sortOrder,
              updatedAt: row.updatedAt,
            ),
          )
          .toList();

  Future<AdapterReliability?> adapterReliability(AdapterId id) async {
    final row = await (select(
      adapterReliabilityRecords,
    )..where((row) => row.adapterId.equals(id.value))).getSingleOrNull();
    return row == null
        ? null
        : AdapterReliability(
            adapterId: id,
            lastCheckedAt: row.lastCheckedAt,
            lastSuccessAt: row.lastSuccessAt,
            lastFailureAt: row.lastFailureAt,
            consecutiveFailures: row.consecutiveFailures,
            lastParserMismatchAt: row.lastParserMismatchAt,
            lastError: row.lastError,
          );
  }

  Future<List<AdapterReliability>> allAdapterReliability() async {
    final values = <AdapterReliability>[];
    for (final row in await select(adapterReliabilityRecords).get()) {
      values.add(
        AdapterReliability(
          adapterId: AdapterId(row.adapterId),
          lastCheckedAt: row.lastCheckedAt,
          lastSuccessAt: row.lastSuccessAt,
          lastFailureAt: row.lastFailureAt,
          consecutiveFailures: row.consecutiveFailures,
          lastParserMismatchAt: row.lastParserMismatchAt,
          lastError: row.lastError,
        ),
      );
    }
    return values;
  }

  Future<void> recordAdapterCheck(
    AdapterId id, {
    required bool success,
    required bool parserMismatch,
    String? error,
    DateTime? checkedAt,
  }) async {
    final now = checkedAt ?? DateTime.now().toUtc();
    final current = await adapterReliability(id);
    final value = AdapterReliabilityRecordsCompanion.insert(
      adapterId: id.value,
      lastCheckedAt: Value(now),
      lastSuccessAt: Value(success ? now : current?.lastSuccessAt),
      lastFailureAt: Value(success ? current?.lastFailureAt : now),
      consecutiveFailures: Value(
        success ? 0 : (current?.consecutiveFailures ?? 0) + 1,
      ),
      lastParserMismatchAt: Value(
        parserMismatch ? now : current?.lastParserMismatchAt,
      ),
      lastError: Value(success ? null : error),
    );
    await into(adapterReliabilityRecords).insertOnConflictUpdate(value);
  }

  Future<void> saveEnrichment(
    CanonicalMediaId mediaId,
    MetadataEnrichment enrichment, {
    DateTime? observedAt,
  }) => into(metadataEnrichmentRecords).insertOnConflictUpdate(
    MetadataEnrichmentRecordsCompanion.insert(
      mediaId: mediaId.value,
      adapterId: enrichment.adapterId.value,
      payloadJson: jsonEncode({
        'title': enrichment.title,
        'description': enrichment.description,
        'coverLocator': enrichment.coverLocator,
        'alternateTitles': enrichment.alternateTitles,
        'genres': enrichment.genres,
      }),
      observedAt: observedAt ?? DateTime.now().toUtc(),
    ),
  );

  Future<List<MetadataEnrichment>> enrichmentsFor(
    CanonicalMediaId mediaId,
  ) async =>
      (await (select(metadataEnrichmentRecords)
                ..where((row) => row.mediaId.equals(mediaId.value))
                ..orderBy([(row) => OrderingTerm.asc(row.adapterId)]))
              .get())
          .map((row) {
            final value = jsonDecode(row.payloadJson) as Map<String, dynamic>;
            return MetadataEnrichment(
              adapterId: AdapterId(row.adapterId),
              title: value['title'] as String?,
              description: value['description'] as String?,
              coverLocator: value['coverLocator'] as String?,
              alternateTitles: (value['alternateTitles'] as List)
                  .cast<String>(),
              genres: (value['genres'] as List).cast<String>(),
            );
          })
          .toList();

  Future<void> saveMetadataOverride(MetadataOverride value) =>
      into(metadataOverrideRecords).insertOnConflictUpdate(
        MetadataOverrideRecordsCompanion.insert(
          mediaId: value.mediaId.value,
          displayTitle: Value(value.displayTitle),
          description: Value(value.description),
          coverLocator: Value(value.coverLocator),
          alternateTitlesJson: Value(jsonEncode(value.alternateTitles)),
          genresJson: Value(jsonEncode(value.genres)),
          status: Value(value.status?.name),
          animeFormat: Value(value.animeFormat?.name),
          creatorOrStudio: Value(value.creatorOrStudio),
          updatedAt: DateTime.now().toUtc(),
        ),
      );

  Future<MetadataOverride?> metadataOverride(CanonicalMediaId mediaId) async {
    final row = await (select(
      metadataOverrideRecords,
    )..where((row) => row.mediaId.equals(mediaId.value))).getSingleOrNull();
    return row == null
        ? null
        : MetadataOverride(
            mediaId: mediaId,
            displayTitle: row.displayTitle,
            description: row.description,
            coverLocator: row.coverLocator,
            alternateTitles: (jsonDecode(row.alternateTitlesJson) as List)
                .cast<String>(),
            genres: (jsonDecode(row.genresJson) as List).cast<String>(),
            status: row.status == null
                ? null
                : CanonicalMediaStatus.values.byName(row.status!),
            animeFormat: row.animeFormat == null
                ? null
                : AnimeFormat.values.byName(row.animeFormat!),
            creatorOrStudio: row.creatorOrStudio,
          );
  }

  Future<void> clearMetadataOverride(CanonicalMediaId mediaId) => (delete(
    metadataOverrideRecords,
  )..where((row) => row.mediaId.equals(mediaId.value))).go();

  Future<void> clearMetadataOverrideField(
    CanonicalMediaId mediaId,
    MetadataOverrideField field,
  ) async {
    final current = await metadataOverride(mediaId);
    if (current == null) return;
    final next = MetadataOverride(
      mediaId: mediaId,
      displayTitle: field == MetadataOverrideField.displayTitle
          ? null
          : current.displayTitle,
      alternateTitles: field == MetadataOverrideField.alternateTitles
          ? const []
          : current.alternateTitles,
      description: field == MetadataOverrideField.description
          ? null
          : current.description,
      coverLocator: field == MetadataOverrideField.cover
          ? null
          : current.coverLocator,
      genres: field == MetadataOverrideField.genres ? const [] : current.genres,
      status: field == MetadataOverrideField.status ? null : current.status,
      animeFormat: field == MetadataOverrideField.format
          ? null
          : current.animeFormat,
      creatorOrStudio: field == MetadataOverrideField.creatorOrStudio
          ? null
          : current.creatorOrStudio,
    );
    next.isEmpty
        ? await clearMetadataOverride(mediaId)
        : await saveMetadataOverride(next);
  }

  Future<CanonicalMedia?> effectiveMedia(CanonicalMediaId id) async {
    final base = await media(id);
    if (base == null) return null;
    final enrichment = (await enrichmentsFor(id)).firstOrNull;
    final override = await metadataOverride(id);
    final source = override?.displayTitle != null
        ? const ProviderId('user-override')
        : enrichment?.title != null
        ? enrichment!.adapterId.providerId
        : base.title.provenance.providerId;
    final title =
        override?.displayTitle ?? enrichment?.title ?? base.title.value;
    final cover =
        override?.coverLocator ?? enrichment?.coverLocator ?? base.coverLocator;
    final alternateValues =
        override != null && override.alternateTitles.isNotEmpty
        ? override.alternateTitles
        : enrichment != null && enrichment.alternateTitles.isNotEmpty
        ? enrichment.alternateTitles
        : null;
    final alternateProvider =
        override != null && override.alternateTitles.isNotEmpty
        ? const ProviderId('user-override')
        : enrichment?.adapterId.providerId;
    final alternates = alternateValues != null
        ? alternateValues
              .map(
                (value) => SourcedValue(
                  value: value,
                  provenance: FieldProvenance(providerId: alternateProvider!),
                ),
              )
              .toList()
        : base.alternateTitles;
    final genreValues = override != null && override.genres.isNotEmpty
        ? override.genres
        : enrichment != null && enrichment.genres.isNotEmpty
        ? enrichment.genres
        : null;
    final genreProvider = override != null && override.genres.isNotEmpty
        ? const ProviderId('user-override')
        : enrichment?.adapterId.providerId;
    final genres = genreValues != null
        ? genreValues
              .map(
                (value) => SourcedValue(
                  value: value,
                  provenance: FieldProvenance(providerId: genreProvider!),
                ),
              )
              .toList()
        : base.genres;
    final description = override?.description != null
        ? SourcedValue(
            value: override!.description!,
            provenance: const FieldProvenance(
              providerId: ProviderId('user-override'),
            ),
          )
        : enrichment?.description == null
        ? base.description
        : SourcedValue(
            value: enrichment!.description!,
            provenance: FieldProvenance(
              providerId: enrichment.adapterId.providerId,
            ),
          );
    final sourcedTitle = SourcedValue(
      value: title,
      provenance: FieldProvenance(providerId: source),
    );
    return switch (base) {
      CanonicalManga() => CanonicalManga(
        id: base.id,
        title: sourcedTitle,
        alternateTitles: alternates,
        description: description,
        status: override?.status ?? base.status,
        genres: genres,
        coverLocator: cover,
      ),
      CanonicalAnime() => CanonicalAnime(
        id: base.id,
        title: sourcedTitle,
        format: override?.animeFormat ?? base.format,
        alternateTitles: alternates,
        description: description,
        status: override?.status ?? base.status,
        genres: genres,
        coverLocator: cover,
        airingWindow: base.airingWindow,
        narrativeSeason: base.narrativeSeason,
        knownEpisodeTotal: base.knownEpisodeTotal,
        rawEpisodeTotal: base.rawEpisodeTotal,
      ),
    };
  }

  Future<void> saveChapterUserEdit(ChapterUserEdit edit) =>
      into(chapterUserEditRecords).insertOnConflictUpdate(
        ChapterUserEditRecordsCompanion.insert(
          chapterId: edit.chapterId.value,
          rawLabel: edit.rawLabel,
          kind: edit.kind.name,
          volumeLabel: Value(edit.volumeLabel),
          explicitOrder: Value(edit.explicitOrder),
          sourceDisplayLabel: Value(edit.sourceDisplayLabel),
          updatedAt: edit.updatedAt,
        ),
      );

  Future<ChapterUserEdit?> chapterUserEdit(CanonicalChapterId id) async {
    final row = await (select(
      chapterUserEditRecords,
    )..where((row) => row.chapterId.equals(id.value))).getSingleOrNull();
    return row == null
        ? null
        : ChapterUserEdit(
            chapterId: id,
            rawLabel: row.rawLabel,
            kind: MangaInstallmentKind.values.byName(row.kind),
            volumeLabel: row.volumeLabel,
            explicitOrder: row.explicitOrder,
            sourceDisplayLabel: row.sourceDisplayLabel,
            updatedAt: row.updatedAt,
          );
  }

  Future<Map<CanonicalChapterId, ChapterUserEdit>> chapterUserEditsFor(
    CanonicalMediaId mediaId,
  ) async {
    final ids = (await chaptersFor(mediaId)).map((value) => value.id).toSet();
    final result = <CanonicalChapterId, ChapterUserEdit>{};
    for (final row in await select(chapterUserEditRecords).get()) {
      final id = CanonicalChapterId(row.chapterId);
      if (!ids.contains(id)) continue;
      result[id] = ChapterUserEdit(
        chapterId: id,
        rawLabel: row.rawLabel,
        kind: MangaInstallmentKind.values.byName(row.kind),
        volumeLabel: row.volumeLabel,
        explicitOrder: row.explicitOrder,
        sourceDisplayLabel: row.sourceDisplayLabel,
        updatedAt: row.updatedAt,
      );
    }
    return result;
  }

  Future<void> saveEpisodeUserEdit(EpisodeUserEdit edit) =>
      into(episodeUserEditRecords).insertOnConflictUpdate(
        EpisodeUserEditRecordsCompanion.insert(
          episodeId: edit.episodeId.value,
          rawLabel: edit.rawLabel,
          number: Value(edit.number),
          kind: edit.kind.name,
          narrativeSeason: Value(edit.narrativeSeason),
          explicitOrder: Value(edit.explicitOrder),
          sourceDisplayLabel: Value(edit.sourceDisplayLabel),
          updatedAt: edit.updatedAt,
        ),
      );

  Future<EpisodeUserEdit?> episodeUserEdit(CanonicalEpisodeId id) async {
    final row = await (select(
      episodeUserEditRecords,
    )..where((row) => row.episodeId.equals(id.value))).getSingleOrNull();
    return row == null
        ? null
        : EpisodeUserEdit(
            episodeId: id,
            rawLabel: row.rawLabel,
            number: row.number,
            kind: AnimeInstallmentKind.values.byName(row.kind),
            narrativeSeason: row.narrativeSeason,
            explicitOrder: row.explicitOrder,
            sourceDisplayLabel: row.sourceDisplayLabel,
            updatedAt: row.updatedAt,
          );
  }

  Future<Map<CanonicalEpisodeId, EpisodeUserEdit>> episodeUserEditsFor(
    CanonicalMediaId mediaId,
  ) async {
    final ids = (await episodesFor(mediaId)).map((value) => value.id).toSet();
    final result = <CanonicalEpisodeId, EpisodeUserEdit>{};
    for (final row in await select(episodeUserEditRecords).get()) {
      final id = CanonicalEpisodeId(row.episodeId);
      if (!ids.contains(id)) continue;
      result[id] = EpisodeUserEdit(
        episodeId: id,
        rawLabel: row.rawLabel,
        number: row.number,
        kind: AnimeInstallmentKind.values.byName(row.kind),
        narrativeSeason: row.narrativeSeason,
        explicitOrder: row.explicitOrder,
        sourceDisplayLabel: row.sourceDisplayLabel,
        updatedAt: row.updatedAt,
      );
    }
    return result;
  }

  Future<void> setChapterCompleted(
    CanonicalChapterId chapterId, {
    required CompletionOrigin origin,
    DateTime? at,
  }) async {
    final value = await chapter(chapterId);
    if (value == null) throw StateError('Chapter no longer exists.');
    await into(chapterCompletionRecords).insertOnConflictUpdate(
      ChapterCompletionRecordsCompanion.insert(
        chapterId: chapterId.value,
        mediaId: value.mediaId.value,
        completedAt: at ?? DateTime.now().toUtc(),
        origin: origin.name,
      ),
    );
  }

  Future<void> setChapterUnread(CanonicalChapterId chapterId) => (delete(
    chapterCompletionRecords,
  )..where((row) => row.chapterId.equals(chapterId.value))).go();

  Future<List<ChapterCompletion>> chapterCompletionsFor(
    CanonicalMediaId mediaId,
  ) async =>
      (await (select(
            chapterCompletionRecords,
          )..where((row) => row.mediaId.equals(mediaId.value))).get())
          .map(
            (row) => ChapterCompletion(
              chapterId: CanonicalChapterId(row.chapterId),
              mediaId: mediaId,
              completedAt: row.completedAt,
              origin: CompletionOrigin.values.byName(row.origin),
            ),
          )
          .toList();

  Future<void> setEpisodeCompleted(
    CanonicalEpisodeId episodeId, {
    required CompletionOrigin origin,
    DateTime? at,
  }) async {
    final value = await episode(episodeId);
    if (value == null) throw StateError('Episode no longer exists.');
    await into(episodeCompletionRecords).insertOnConflictUpdate(
      EpisodeCompletionRecordsCompanion.insert(
        episodeId: episodeId.value,
        mediaId: value.mediaId.value,
        completedAt: at ?? DateTime.now().toUtc(),
        origin: origin.name,
      ),
    );
  }

  Future<void> setEpisodeUnwatched(CanonicalEpisodeId episodeId) => (delete(
    episodeCompletionRecords,
  )..where((row) => row.episodeId.equals(episodeId.value))).go();

  Future<List<EpisodeCompletion>> episodeCompletionsFor(
    CanonicalMediaId mediaId,
  ) async =>
      (await (select(
            episodeCompletionRecords,
          )..where((row) => row.mediaId.equals(mediaId.value))).get())
          .map(
            (row) => EpisodeCompletion(
              episodeId: CanonicalEpisodeId(row.episodeId),
              mediaId: mediaId,
              completedAt: row.completedAt,
              origin: CompletionOrigin.values.byName(row.origin),
            ),
          )
          .toList();

  Future<Set<CanonicalChapterId>> allCompletedChapterIds() async =>
      (await select(
        chapterCompletionRecords,
      ).get()).map((row) => CanonicalChapterId(row.chapterId)).toSet();

  Future<Set<CanonicalEpisodeId>> allCompletedEpisodeIds() async =>
      (await select(
        episodeCompletionRecords,
      ).get()).map((row) => CanonicalEpisodeId(row.episodeId)).toSet();
}

LocalAsset _localAssetFromRow(LocalAssetRow row) => LocalAsset(
  id: LocalAssetId(row.id),
  kind: LocalAssetKind.values.byName(row.kind),
  ownership: LocalAssetOwnership.values.byName(row.ownership),
  state: LocalAssetState.values.byName(row.state),
  providerId: ProviderId(row.providerId),
  bindingExternalId: row.bindingExternalId,
  mediaId: CanonicalMediaId(row.mediaId),
  installmentId: row.installmentId,
  originalName: row.originalName,
  managedRelativePath: row.managedRelativePath,
  sizeBytes: row.sizeBytes,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
);

String _encodeSourced(List<SourcedValue<String>> values) => jsonEncode(
  values
      .map(
        (value) => {
          'value': value.value,
          'providerId': value.provenance.providerId.value,
          'rawValue': value.rawValue,
        },
      )
      .toList(),
);
List<SourcedValue<String>> _decodeSourced(String value) =>
    (jsonDecode(value) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(
          (item) => SourcedValue(
            value: item['value'] as String,
            provenance: FieldProvenance(
              providerId: ProviderId(item['providerId'] as String),
            ),
            rawValue: item['rawValue'] as String?,
          ),
        )
        .toList();

Map<String, String> _decodeMetadata(String value) =>
    (jsonDecode(value) as Map<String, dynamic>).map(
      (key, item) => MapEntry(key, item.toString()),
    );
