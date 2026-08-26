import '../domain/bindings.dart';
import '../domain/installments.dart';
import '../domain/media.dart';

class MangaCanonicalImport {
  const MangaCanonicalImport({
    required this.media,
    required this.chapters,
    required this.mediaBinding,
    required this.chapterBindings,
  });
  final CanonicalManga media;
  final List<CanonicalChapter> chapters;
  final MediaSourceBinding mediaBinding;
  final List<ChapterSourceBinding> chapterBindings;
}

class AnimeCanonicalImport {
  const AnimeCanonicalImport({
    required this.media,
    required this.episodes,
    required this.mediaBinding,
    required this.episodeBindings,
  });
  final CanonicalAnime media;
  final List<CanonicalEpisode> episodes;
  final MediaSourceBinding mediaBinding;
  final List<EpisodeSourceBinding> episodeBindings;
}
