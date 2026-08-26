import 'identifiers.dart';

enum CanonicalMediaKind { manga, anime }

enum CanonicalMediaStatus { ongoing, completed, planned, dropped, unknown }

enum AnimeFormat { tv, movie, ova, ona, special, music, unknown }

enum AiringSeason { winter, spring, summer, fall, unknown }

class FieldProvenance {
  const FieldProvenance({required this.providerId, this.observedAt});
  final ProviderId providerId;
  final DateTime? observedAt;
}

class SourcedValue<T> {
  const SourcedValue({
    required this.value,
    required this.provenance,
    this.rawValue,
  });
  final T value;
  final FieldProvenance provenance;
  final String? rawValue;
}

class AiringWindow {
  const AiringWindow({
    required this.season,
    required this.year,
    required this.rawLabel,
  });
  final AiringSeason season;
  final int year;
  final String rawLabel;
}

class NarrativeSeasonNumber {
  const NarrativeSeasonNumber(this.value) : assert(value > 0);
  final int value;
}

sealed class CanonicalMedia {
  const CanonicalMedia({
    required this.id,
    required this.title,
    this.alternateTitles = const [],
    this.description,
    this.status = CanonicalMediaStatus.unknown,
    this.genres = const [],
    this.coverLocator,
  });
  final CanonicalMediaId id;
  final SourcedValue<String> title;
  final List<SourcedValue<String>> alternateTitles;
  final SourcedValue<String>? description;
  final CanonicalMediaStatus status;
  final List<SourcedValue<String>> genres;
  final String? coverLocator;
  CanonicalMediaKind get kind;
}

class CanonicalManga extends CanonicalMedia {
  const CanonicalManga({
    required super.id,
    required super.title,
    super.alternateTitles,
    super.description,
    super.status,
    super.genres,
    super.coverLocator,
  });
  @override
  CanonicalMediaKind get kind => CanonicalMediaKind.manga;
}

class CanonicalAnime extends CanonicalMedia {
  const CanonicalAnime({
    required super.id,
    required super.title,
    required this.format,
    super.alternateTitles,
    super.description,
    super.status,
    super.genres,
    super.coverLocator,
    this.airingWindow,
    this.narrativeSeason,
    this.knownEpisodeTotal,
    this.rawEpisodeTotal,
  });
  final AnimeFormat format;
  final AiringWindow? airingWindow;
  final NarrativeSeasonNumber? narrativeSeason;
  final int? knownEpisodeTotal;
  final String? rawEpisodeTotal;
  @override
  CanonicalMediaKind get kind => CanonicalMediaKind.anime;
}
