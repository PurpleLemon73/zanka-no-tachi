import '../domain/bindings.dart';
import '../domain/identifiers.dart';
import '../domain/installments.dart';
import '../domain/media.dart';
import '../persistence/canonical_database.dart';

class CanonicalMediaAvailability {
  const CanonicalMediaAvailability({
    required this.media,
    required this.sourceBindings,
  });
  final CanonicalMedia media;
  final List<MediaSourceBinding> sourceBindings;
  List<ProviderId> get availableProviders =>
      sourceBindings.map((binding) => binding.providerId).toSet().toList();
}

class CanonicalChapterAvailability {
  const CanonicalChapterAvailability({
    required this.chapter,
    required this.sourceBindings,
  });
  final CanonicalChapter chapter;
  final List<ChapterSourceBinding> sourceBindings;
}

class CanonicalEpisodeAvailability {
  const CanonicalEpisodeAvailability({
    required this.episode,
    required this.sourceBindings,
  });
  final CanonicalEpisode episode;
  final List<EpisodeSourceBinding> sourceBindings;
}

class SourceAvailabilityRepository {
  const SourceAvailabilityRepository(this.database);
  final CanonicalDatabase database;

  Future<CanonicalMediaAvailability?> media(
    CanonicalMediaId requestedId,
  ) async {
    final id = await database.resolveCanonicalId(requestedId);
    final media = await database.media(id);
    return media == null
        ? null
        : CanonicalMediaAvailability(
            media: media,
            sourceBindings: await database.mediaBindingsFor(id),
          );
  }

  Future<List<CanonicalChapterAvailability>> chapters(
    CanonicalMediaId requestedId,
  ) async {
    final id = await database.resolveCanonicalId(requestedId);
    final chapters = await database.chaptersFor(id);
    final bindings = await database.allChapterBindingsByChapter();
    return [
      for (final chapter in chapters)
        CanonicalChapterAvailability(
          chapter: chapter,
          sourceBindings: bindings[chapter.id] ?? const [],
        ),
    ];
  }

  Future<List<CanonicalEpisodeAvailability>> episodes(
    CanonicalMediaId requestedId,
  ) async {
    final id = await database.resolveCanonicalId(requestedId);
    final episodes = await database.episodesFor(id);
    final bindings = await database.allEpisodeBindingsByEpisode();
    return [
      for (final episode in episodes)
        CanonicalEpisodeAvailability(
          episode: episode,
          sourceBindings: bindings[episode.id] ?? const [],
        ),
    ];
  }
}

class PreferredSourcePolicy {
  const PreferredSourcePolicy({
    this.preferredByKind = const {},
    this.fallbackOrder = const [],
  });
  final Map<CanonicalMediaKind, ProviderId> preferredByKind;
  final List<ProviderId> fallbackOrder;
}

class PreferredSourceSelector {
  const PreferredSourceSelector(
    this.database, {
    this.policy = const PreferredSourcePolicy(),
  });
  final CanonicalDatabase database;
  final PreferredSourcePolicy policy;

  Future<MediaSourceBinding?> mediaBinding(CanonicalMediaId requestedId) async {
    final id = await database.resolveCanonicalId(requestedId);
    final media = await database.media(id);
    if (media == null) return null;
    return _choose(
      await database.mediaBindingsFor(id),
      await database.preferredProvider(id),
      media.kind,
    );
  }

  Future<ChapterSourceBinding?> chapterBinding(
    CanonicalMediaId requestedMediaId,
    CanonicalChapterId chapterId,
  ) async {
    final mediaId = await database.resolveCanonicalId(requestedMediaId);
    final chapter = await database.chapter(chapterId);
    if (chapter?.mediaId != mediaId) return null;
    return _choose(
      await database.chapterBindingsFor(chapterId),
      await database.preferredProvider(mediaId),
      CanonicalMediaKind.manga,
    );
  }

  Future<EpisodeSourceBinding?> episodeBinding(
    CanonicalMediaId requestedMediaId,
    CanonicalEpisodeId episodeId,
  ) async {
    final mediaId = await database.resolveCanonicalId(requestedMediaId);
    final episode = await database.episode(episodeId);
    if (episode?.mediaId != mediaId) return null;
    return _choose(
      await database.episodeBindingsFor(episodeId),
      await database.preferredProvider(mediaId),
      CanonicalMediaKind.anime,
    );
  }

  T? _choose<T extends SourceBinding<CanonicalId>>(
    List<T> bindings,
    ProviderId? mediaPreference,
    CanonicalMediaKind kind,
  ) {
    if (bindings.isEmpty) return null;
    final order = <ProviderId>[
      if (mediaPreference != null) mediaPreference,
      if (policy.preferredByKind[kind] case final preferred?) preferred,
      ...policy.fallbackOrder,
    ];
    for (final provider in order) {
      for (final binding in bindings) {
        if (binding.providerId == provider) return binding;
      }
    }
    final sorted = [...bindings]
      ..sort((a, b) => a.providerId.value.compareTo(b.providerId.value));
    return sorted.first;
  }
}
