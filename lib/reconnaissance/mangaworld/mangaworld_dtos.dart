import '../source_contracts.dart';

class MangaWorldCatalogPageDto extends SourcePage<MangaWorldCatalogItemDto> {
  const MangaWorldCatalogPageDto({
    required super.items,
    super.currentPage,
    super.totalPages,
  });
}

class MangaWorldCatalogItemDto {
  const MangaWorldCatalogItemDto({
    required this.sourceId,
    required this.sourceUrl,
    required this.title,
    this.coverUrl,
    this.type,
    this.status,
    this.year,
    this.latestChapterLabel,
    this.genres = const [],
  });

  final String sourceId;
  final Uri sourceUrl;
  final String title;
  final Uri? coverUrl;
  final String? type;
  final String? status;
  final int? year;
  final String? latestChapterLabel;
  final List<String> genres;
}

class MangaWorldTitleDto {
  const MangaWorldTitleDto({
    required this.sourceId,
    required this.sourceUrl,
    required this.title,
    required this.chapters,
    this.coverUrl,
    this.description,
    this.type,
    this.status,
    this.author,
    this.artist,
    this.year,
    this.views,
    this.fansub,
    this.genres = const [],
    this.alternateTitles = const [],
  });

  final String sourceId;
  final Uri sourceUrl;
  final String title;
  final Uri? coverUrl;
  final String? description;
  final String? type;
  final String? status;
  final String? author;
  final String? artist;
  final int? year;
  final int? views;
  final String? fansub;
  final List<String> genres;
  final List<String> alternateTitles;
  final List<MangaWorldChapterDto> chapters;
}

class MangaWorldChapterDto {
  const MangaWorldChapterDto({
    required this.sourceId,
    required this.sourceUrl,
    required this.label,
    this.number,
    this.volumeLabel,
    this.displayDate,
    this.title,
  });

  final String sourceId;
  final Uri sourceUrl;
  final String label;
  final double? number;
  final String? volumeLabel;
  final String? displayDate;
  final String? title;
}
