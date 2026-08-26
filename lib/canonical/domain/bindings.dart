import 'identifiers.dart';

abstract class SourceBinding<T extends CanonicalId> {
  const SourceBinding({
    required this.canonicalId,
    required this.providerId,
    required this.externalId,
    this.relativeLocator,
    this.rawMetadata = const {},
  });
  final T canonicalId;
  final ProviderId providerId;
  final String externalId;
  final String? relativeLocator;
  final Map<String, String> rawMetadata;
}

class MediaSourceBinding extends SourceBinding<CanonicalMediaId> {
  const MediaSourceBinding({
    required super.canonicalId,
    required super.providerId,
    required super.externalId,
    super.relativeLocator,
    super.rawMetadata,
  });
}

class ChapterSourceBinding extends SourceBinding<CanonicalChapterId> {
  const ChapterSourceBinding({
    required super.canonicalId,
    required super.providerId,
    required super.externalId,
    super.relativeLocator,
    super.rawMetadata,
  });
}

class EpisodeSourceBinding extends SourceBinding<CanonicalEpisodeId> {
  const EpisodeSourceBinding({
    required super.canonicalId,
    required super.providerId,
    required super.externalId,
    super.relativeLocator,
    super.rawMetadata,
  });
}
