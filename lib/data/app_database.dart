import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/models.dart' as domain;

part 'app_database.g.dart';

@DataClassName('LibraryEntryRow')
class LibraryEntries extends Table {
  TextColumn get mediaId => text()();
  TextColumn get mediaType => text()();
  TextColumn get status => text()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get addedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

class MangaProgressEntries extends Table {
  TextColumn get mediaId => text()();
  TextColumn get chapterId => text()();
  IntColumn get page => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

class AnimeProgressEntries extends Table {
  TextColumn get mediaId => text()();
  TextColumn get episodeId => text()();
  IntColumn get positionSeconds => integer()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId};
}

@DataClassName('SourceBindingRow')
class SourceBindings extends Table {
  TextColumn get mediaId => text()();
  TextColumn get providerKey => text()();
  TextColumn get providerMediaId => text()();
  TextColumn get url => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {mediaId, providerKey};
}

@DriftDatabase(
  tables: [
    LibraryEntries,
    MangaProgressEntries,
    AnimeProgressEntries,
    SourceBindings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Stream<List<domain.LibraryEntry>> watchLibrary() =>
      select(libraryEntries).watch().map(
        (rows) => rows
            .map(
              (row) => domain.LibraryEntry(
                mediaId: row.mediaId,
                mediaType: domain.MediaType.values.byName(row.mediaType),
                status: domain.LibraryStatus.values.byName(row.status),
                isFavorite: row.isFavorite,
                addedAt: row.addedAt,
              ),
            )
            .toList(),
      );

  Future<void> saveLibraryEntry(domain.LibraryEntry entry) =>
      into(libraryEntries).insertOnConflictUpdate(
        LibraryEntriesCompanion.insert(
          mediaId: entry.mediaId,
          mediaType: entry.mediaType.name,
          status: entry.status.name,
          isFavorite: Value(entry.isFavorite),
          addedAt: entry.addedAt,
        ),
      );

  Future<void> removeLibraryEntry(String mediaId) => (delete(
    libraryEntries,
  )..where((row) => row.mediaId.equals(mediaId))).go();

  Future<void> saveMangaProgress(domain.MangaProgress progress) =>
      into(mangaProgressEntries).insertOnConflictUpdate(
        MangaProgressEntriesCompanion.insert(
          mediaId: progress.mediaId,
          chapterId: progress.chapterId,
          page: progress.page,
          updatedAt: progress.updatedAt,
        ),
      );

  Future<domain.MangaProgress?> mangaProgress(String mediaId) async {
    final row = await (select(
      mangaProgressEntries,
    )..where((r) => r.mediaId.equals(mediaId))).getSingleOrNull();
    return row == null
        ? null
        : domain.MangaProgress(
            mediaId: row.mediaId,
            chapterId: row.chapterId,
            page: row.page,
            updatedAt: row.updatedAt,
          );
  }

  Future<void> saveAnimeProgress(domain.AnimeProgress progress) =>
      into(animeProgressEntries).insertOnConflictUpdate(
        AnimeProgressEntriesCompanion.insert(
          mediaId: progress.mediaId,
          episodeId: progress.episodeId,
          positionSeconds: progress.position.inSeconds,
          updatedAt: progress.updatedAt,
        ),
      );

  Future<domain.AnimeProgress?> animeProgress(String mediaId) async {
    final row = await (select(
      animeProgressEntries,
    )..where((r) => r.mediaId.equals(mediaId))).getSingleOrNull();
    return row == null
        ? null
        : domain.AnimeProgress(
            mediaId: row.mediaId,
            episodeId: row.episodeId,
            position: Duration(seconds: row.positionSeconds),
            updatedAt: row.updatedAt,
          );
  }

  Future<void> saveSourceBinding(domain.SourceBinding binding) =>
      into(sourceBindings).insertOnConflictUpdate(
        SourceBindingsCompanion.insert(
          mediaId: binding.mediaId,
          providerKey: binding.providerKey,
          providerMediaId: binding.providerMediaId,
          url: Value(binding.url),
        ),
      );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final directory = await getApplicationDocumentsDirectory();
  return NativeDatabase.createInBackground(
    File(p.join(directory.path, 'zanka.sqlite')),
  );
});
