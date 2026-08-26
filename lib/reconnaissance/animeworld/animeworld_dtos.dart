import '../source_contracts.dart';

class AnimeWorldCatalogPageDto extends SourcePage<AnimeWorldCatalogItemDto> {
  const AnimeWorldCatalogPageDto({
    required super.items,
    super.currentPage,
    super.totalPages,
  });
}

class AnimeWorldCatalogItemDto {
  const AnimeWorldCatalogItemDto({
    required this.sourceId,
    required this.sourceUrl,
    required this.title,
    this.alternateTitle,
    this.coverUrl,
    this.format,
    this.status,
    this.audioLanguage,
    this.isDubbed = false,
    this.episodeCountLabel,
  });

  final String sourceId;
  final Uri sourceUrl;
  final String title;
  final String? alternateTitle;
  final Uri? coverUrl;
  final String? format;
  final String? status;
  final String? audioLanguage;
  final bool isDubbed;
  final String? episodeCountLabel;
}

class AnimeWorldTitleDto {
  const AnimeWorldTitleDto({
    required this.sourceId,
    required this.sourceUrl,
    required this.title,
    required this.episodes,
    this.alternateTitle,
    this.coverUrl,
    this.description,
    this.format,
    this.status,
    this.audioLanguage,
    this.subtitleMode,
    this.releaseDateLabel,
    this.airingSeasonLabel,
    this.studio,
    this.score,
    this.durationLabel,
    this.episodeCount,
    this.episodeCountLabel,
    this.views,
    this.genres = const [],
  });

  final String sourceId;
  final Uri sourceUrl;
  final String title;
  final String? alternateTitle;
  final Uri? coverUrl;
  final String? description;
  final String? format;
  final String? status;
  final String? audioLanguage;
  final String? subtitleMode;
  final String? releaseDateLabel;
  final String? airingSeasonLabel;
  final String? studio;
  final double? score;
  final String? durationLabel;
  final int? episodeCount;
  final String? episodeCountLabel;
  final int? views;
  final List<String> genres;
  final List<AnimeWorldEpisodeDto> episodes;
}

class AnimeWorldEpisodeDto {
  const AnimeWorldEpisodeDto({
    required this.sourceId,
    required this.sourceUrl,
    required this.label,
    this.number,
    this.title,
    this.displayDate,
  });

  final String sourceId;
  final Uri sourceUrl;
  final String label;
  final double? number;
  final String? title;
  final String? displayDate;
}
