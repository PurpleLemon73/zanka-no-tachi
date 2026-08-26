import 'identifiers.dart';

enum CanonicalLibraryStatus { planned, inProgress, completed, paused, dropped }

class CanonicalLibraryEntry {
  const CanonicalLibraryEntry({
    required this.mediaId,
    required this.isSaved,
    required this.isFavorite,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  final CanonicalMediaId mediaId;
  final bool isSaved;
  final bool isFavorite;
  final CanonicalLibraryStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class CanonicalMangaProgress {
  const CanonicalMangaProgress({
    required this.mediaId,
    required this.chapterId,
    required this.pageIndex,
    required this.updatedAt,
    this.totalPages,
  });
  final CanonicalMediaId mediaId;
  final CanonicalChapterId chapterId;
  final int pageIndex;
  final int? totalPages;
  final DateTime updatedAt;
}

class CanonicalAnimeProgress {
  const CanonicalAnimeProgress({
    required this.mediaId,
    required this.episodeId,
    required this.position,
    required this.updatedAt,
    this.duration,
  });
  final CanonicalMediaId mediaId;
  final CanonicalEpisodeId episodeId;
  final Duration position;
  final Duration? duration;
  final DateTime updatedAt;
}

class MangaSourcePageResume {
  const MangaSourcePageResume({
    required this.mediaId,
    required this.chapterId,
    required this.providerId,
    required this.chapterExternalId,
    required this.pageIndex,
    required this.updatedAt,
    this.totalPages,
  });
  final CanonicalMediaId mediaId;
  final CanonicalChapterId chapterId;
  final ProviderId providerId;
  final String chapterExternalId;
  final int pageIndex;
  final int? totalPages;
  final DateTime updatedAt;
}

class AnimeSourcePlaybackResume {
  const AnimeSourcePlaybackResume({
    required this.mediaId,
    required this.episodeId,
    required this.providerId,
    required this.episodeExternalId,
    required this.position,
    required this.updatedAt,
    this.duration,
  });
  final CanonicalMediaId mediaId;
  final CanonicalEpisodeId episodeId;
  final ProviderId providerId;
  final String episodeExternalId;
  final Duration position;
  final Duration? duration;
  final DateTime updatedAt;
}
