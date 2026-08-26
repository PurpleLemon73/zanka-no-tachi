import '../canonical/domain/identifiers.dart';

enum MangaInstallmentKind { standard, decimal, special, extra, oneshot }

enum AnimeInstallmentKind { standard, movie, ova, ona, special }

enum CompletionOrigin { automatic, manual }

class ChapterUserEdit {
  const ChapterUserEdit({
    required this.chapterId,
    required this.rawLabel,
    required this.kind,
    required this.updatedAt,
    this.volumeLabel,
    this.explicitOrder,
    this.sourceDisplayLabel,
  });

  final CanonicalChapterId chapterId;
  final String rawLabel;
  final MangaInstallmentKind kind;
  final String? volumeLabel;
  final double? explicitOrder;
  final String? sourceDisplayLabel;
  final DateTime updatedAt;
}

class EpisodeUserEdit {
  const EpisodeUserEdit({
    required this.episodeId,
    required this.rawLabel,
    required this.kind,
    required this.updatedAt,
    this.number,
    this.narrativeSeason,
    this.explicitOrder,
    this.sourceDisplayLabel,
  });

  final CanonicalEpisodeId episodeId;
  final String rawLabel;
  final double? number;
  final AnimeInstallmentKind kind;
  final int? narrativeSeason;
  final double? explicitOrder;
  final String? sourceDisplayLabel;
  final DateTime updatedAt;
}

class ChapterCompletion {
  const ChapterCompletion({
    required this.chapterId,
    required this.mediaId,
    required this.completedAt,
    required this.origin,
  });
  final CanonicalChapterId chapterId;
  final CanonicalMediaId mediaId;
  final DateTime completedAt;
  final CompletionOrigin origin;
}

class EpisodeCompletion {
  const EpisodeCompletion({
    required this.episodeId,
    required this.mediaId,
    required this.completedAt,
    required this.origin,
  });
  final CanonicalEpisodeId episodeId;
  final CanonicalMediaId mediaId;
  final DateTime completedAt;
  final CompletionOrigin origin;
}
