import '../../reconnaissance/animeworld/animeworld_dtos.dart';
import '../domain/bindings.dart';
import '../domain/identifiers.dart';
import '../domain/installments.dart';
import '../domain/media.dart';
import 'canonical_import.dart';

class AnimeWorldCanonicalMapper {
  const AnimeWorldCanonicalMapper({
    this.providerId = const ProviderId('animeworld'),
  });
  final ProviderId providerId;

  AnimeCanonicalImport mapTitle({
    required AnimeWorldTitleDto dto,
    required CanonicalMediaId mediaId,
    required CanonicalEpisodeId Function(AnimeWorldEpisodeDto episode)
    episodeIdFor,
  }) {
    final provenance = FieldProvenance(providerId: providerId);
    final episodes = dto.episodes
        .map(
          (episode) => CanonicalEpisode(
            id: episodeIdFor(episode),
            mediaId: mediaId,
            label: EpisodeLabel.parse(episode.label),
            title: episode.title,
          ),
        )
        .toList();
    return AnimeCanonicalImport(
      media: CanonicalAnime(
        id: mediaId,
        title: SourcedValue(
          value: dto.title,
          provenance: provenance,
          rawValue: dto.title,
        ),
        alternateTitles:
            dto.alternateTitle == null || dto.alternateTitle == dto.title
            ? const []
            : [
                SourcedValue(
                  value: dto.alternateTitle!,
                  provenance: provenance,
                  rawValue: dto.alternateTitle,
                ),
              ],
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
        format: _format(dto.format),
        airingWindow: _airingWindow(dto.airingSeasonLabel),
        knownEpisodeTotal: dto.episodeCount,
        rawEpisodeTotal: dto.episodeCountLabel,
      ),
      episodes: episodes,
      mediaBinding: MediaSourceBinding(
        canonicalId: mediaId,
        providerId: providerId,
        externalId: dto.sourceId,
        relativeLocator: _locator(dto.sourceUrl),
        rawMetadata: {
          if (dto.format != null) 'format': dto.format!,
          if (dto.status != null) 'status': dto.status!,
          if (dto.audioLanguage != null) 'audioLanguage': dto.audioLanguage!,
          if (dto.subtitleMode != null) 'subtitleMode': dto.subtitleMode!,
          if (dto.studio != null) 'studio': dto.studio!,
          if (dto.durationLabel != null) 'duration': dto.durationLabel!,
        },
      ),
      episodeBindings: [
        for (var index = 0; index < dto.episodes.length; index++)
          EpisodeSourceBinding(
            canonicalId: episodes[index].id,
            providerId: providerId,
            externalId: dto.episodes[index].sourceId,
            relativeLocator: _locator(dto.episodes[index].sourceUrl),
            rawMetadata: {
              'label': dto.episodes[index].label,
              if (dto.episodes[index].displayDate != null)
                'displayDate': dto.episodes[index].displayDate!,
            },
          ),
      ],
    );
  }

  AnimeFormat _format(String? raw) => switch (raw?.toLowerCase()) {
    'anime' || 'tv' => AnimeFormat.tv,
    'movie' => AnimeFormat.movie,
    'ova' => AnimeFormat.ova,
    'ona' => AnimeFormat.ona,
    'special' => AnimeFormat.special,
    'music' => AnimeFormat.music,
    _ => AnimeFormat.unknown,
  };

  CanonicalMediaStatus _status(String? raw) => switch (raw?.toLowerCase()) {
    'in corso' => CanonicalMediaStatus.ongoing,
    'finito' || 'completato' => CanonicalMediaStatus.completed,
    'non rilasciato' => CanonicalMediaStatus.planned,
    'droppato' => CanonicalMediaStatus.dropped,
    _ => CanonicalMediaStatus.unknown,
  };

  AiringWindow? _airingWindow(String? raw) {
    if (raw == null) return null;
    final match = RegExp(r'^(\S+)\s+(\d{4})$').firstMatch(raw.trim());
    if (match == null) return null;
    final season = switch (match.group(1)!.toLowerCase()) {
      'inverno' => AiringSeason.winter,
      'primavera' => AiringSeason.spring,
      'estate' => AiringSeason.summer,
      'autunno' => AiringSeason.fall,
      _ => AiringSeason.unknown,
    };
    return AiringWindow(
      season: season,
      year: int.parse(match.group(2)!),
      rawLabel: raw,
    );
  }

  String _locator(Uri url) =>
      url.hasQuery ? '${url.path}?${url.query}' : url.path;
}
