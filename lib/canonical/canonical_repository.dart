import 'mapping/canonical_import.dart';
import 'persistence/canonical_database.dart';

class CanonicalRepository {
  const CanonicalRepository(this.database);
  final CanonicalDatabase database;

  Future<void> saveMangaImport(MangaCanonicalImport bundle) =>
      database.transaction(() async {
        await database.saveMedia(bundle.media);
        for (final chapter in bundle.chapters) {
          await database.saveChapter(chapter);
        }
        await database.saveMediaBinding(bundle.mediaBinding);
        for (final binding in bundle.chapterBindings) {
          await database.saveChapterBinding(binding);
        }
      });

  Future<void> saveAnimeImport(AnimeCanonicalImport bundle) =>
      database.transaction(() async {
        await database.saveMedia(bundle.media);
        for (final episode in bundle.episodes) {
          await database.saveEpisode(episode);
        }
        await database.saveMediaBinding(bundle.mediaBinding);
        for (final binding in bundle.episodeBindings) {
          await database.saveEpisodeBinding(binding);
        }
      });
}
