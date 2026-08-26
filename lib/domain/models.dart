enum MediaType { manga, anime }

enum LibraryStatus { planning, inProgress, completed, onHold, dropped }

sealed class Media {
  const Media({
    required this.id,
    required this.title,
    required this.description,
    required this.coverColor,
  });

  final String id;
  final String title;
  final String description;
  final int coverColor;
  MediaType get type;
}

class Manga extends Media {
  const Manga({
    required super.id,
    required super.title,
    required super.description,
    required super.coverColor,
    required this.chapters,
  });

  final List<Chapter> chapters;
  @override
  MediaType get type => MediaType.manga;
}

class Anime extends Media {
  const Anime({
    required super.id,
    required super.title,
    required super.description,
    required super.coverColor,
    required this.episodes,
  });

  final List<Episode> episodes;
  @override
  MediaType get type => MediaType.anime;
}

class Chapter {
  const Chapter({required this.id, required this.number, required this.title});
  final String id;
  final double number;
  final String title;
}

class Episode {
  const Episode({
    required this.id,
    required this.number,
    required this.title,
    required this.duration,
  });
  final String id;
  final int number;
  final String title;
  final Duration duration;
}

class MangaProgress {
  const MangaProgress({
    required this.mediaId,
    required this.chapterId,
    required this.page,
    required this.updatedAt,
  });
  final String mediaId;
  final String chapterId;
  final int page;
  final DateTime updatedAt;
}

class AnimeProgress {
  const AnimeProgress({
    required this.mediaId,
    required this.episodeId,
    required this.position,
    required this.updatedAt,
  });
  final String mediaId;
  final String episodeId;
  final Duration position;
  final DateTime updatedAt;
}

class LibraryEntry {
  const LibraryEntry({
    required this.mediaId,
    required this.mediaType,
    required this.status,
    required this.isFavorite,
    required this.addedAt,
  });
  final String mediaId;
  final MediaType mediaType;
  final LibraryStatus status;
  final bool isFavorite;
  final DateTime addedAt;
}

class SourceBinding {
  const SourceBinding({
    required this.mediaId,
    required this.providerKey,
    required this.providerMediaId,
    this.url,
  });
  final String mediaId;
  final String providerKey;
  final String providerMediaId;
  final String? url;
}
