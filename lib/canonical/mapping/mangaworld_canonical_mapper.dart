import '../../reconnaissance/mangaworld/mangaworld_dtos.dart';
import '../domain/bindings.dart';
import '../domain/identifiers.dart';
import '../domain/installments.dart';
import '../domain/media.dart';
import 'canonical_import.dart';

class MangaWorldCanonicalMapper {
  const MangaWorldCanonicalMapper({
    this.providerId = const ProviderId('mangaworld'),
  });
  final ProviderId providerId;

  MangaCanonicalImport mapTitle({
    required MangaWorldTitleDto dto,
    required CanonicalMediaId mediaId,
    required CanonicalChapterId Function(MangaWorldChapterDto chapter)
    chapterIdFor,
  }) {
    final provenance = FieldProvenance(providerId: providerId);
    final chapters = dto.chapters
        .map(
          (chapter) => CanonicalChapter(
            id: chapterIdFor(chapter),
            mediaId: mediaId,
            number: ChapterNumber.parse(chapter.label),
            title: chapter.title,
            volumeLabel: chapter.volumeLabel,
          ),
        )
        .toList();
    return MangaCanonicalImport(
      media: CanonicalManga(
        id: mediaId,
        title: SourcedValue(
          value: dto.title,
          provenance: provenance,
          rawValue: dto.title,
        ),
        alternateTitles: dto.alternateTitles
            .map(
              (value) => SourcedValue(
                value: value,
                provenance: provenance,
                rawValue: value,
              ),
            )
            .toList(),
        description: dto.description == null
            ? null
            : SourcedValue(
                value: dto.description!,
                provenance: provenance,
                rawValue: dto.description,
              ),
        status: _status(dto.status),
        genres: dto.genres
            .map(
              (value) => SourcedValue(
                value: value,
                provenance: provenance,
                rawValue: value,
              ),
            )
            .toList(),
        coverLocator: dto.coverUrl?.toString(),
      ),
      chapters: chapters,
      mediaBinding: MediaSourceBinding(
        canonicalId: mediaId,
        providerId: providerId,
        externalId: dto.sourceId,
        relativeLocator: _locator(dto.sourceUrl),
        rawMetadata: {
          if (dto.type != null) 'type': dto.type!,
          if (dto.status != null) 'status': dto.status!,
          if (dto.author != null) 'author': dto.author!,
          if (dto.artist != null) 'artist': dto.artist!,
          if (dto.fansub != null) 'fansub': dto.fansub!,
        },
      ),
      chapterBindings: [
        for (var index = 0; index < dto.chapters.length; index++)
          ChapterSourceBinding(
            canonicalId: chapters[index].id,
            providerId: providerId,
            externalId: dto.chapters[index].sourceId,
            relativeLocator: _locator(dto.chapters[index].sourceUrl),
            rawMetadata: {
              'label': dto.chapters[index].label,
              if (dto.chapters[index].displayDate != null)
                'displayDate': dto.chapters[index].displayDate!,
              if (dto.chapters[index].volumeLabel != null)
                'volumeLabel': dto.chapters[index].volumeLabel!,
            },
          ),
      ],
    );
  }

  CanonicalMediaStatus _status(String? raw) => switch (raw?.toLowerCase()) {
    'in corso' => CanonicalMediaStatus.ongoing,
    'finito' || 'completato' => CanonicalMediaStatus.completed,
    _ => CanonicalMediaStatus.unknown,
  };

  String _locator(Uri url) =>
      url.hasQuery ? '${url.path}?${url.query}' : url.path;
}
