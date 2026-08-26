import '../canonical/domain/bindings.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/installments.dart';
import '../canonical/domain/user_state.dart';
import '../canonical/persistence/canonical_database.dart';
import 'playback_domain.dart';
import 'playback_preferences_store.dart';
import 'playback_source.dart';
import '../product_maturity/maturity_domain.dart';

class PlaybackEpisodeAvailability {
  const PlaybackEpisodeAvailability({
    required this.episode,
    required this.bindings,
    required this.capabilities,
  });
  final CanonicalEpisode episode;
  final List<EpisodeSourceBinding> bindings;
  final Map<ProviderId, PlaybackSourceCapability> capabilities;
  List<EpisodeSourceBinding> get playableBindings => bindings
      .where(
        (binding) =>
            capabilities[binding.providerId] ==
            PlaybackSourceCapability.playbackCapable,
      )
      .toList();
}

class PlaybackRepository {
  const PlaybackRepository({
    required this.database,
    required this.sources,
    required this.preferencesStore,
  });
  final CanonicalDatabase database;
  final PlaybackSourceRegistry sources;
  final PlaybackPreferencesStore preferencesStore;

  Future<List<PlaybackEpisodeAvailability>> episodes(
    CanonicalMediaId requestedId,
  ) async {
    final mediaId = await database.resolveCanonicalId(requestedId);
    final episodes = await database.episodesFor(mediaId);
    final edits = await database.episodeUserEditsFor(mediaId);
    episodes.sort((left, right) {
      final l = edits[left.id]?.explicitOrder;
      final r = edits[right.id]?.explicitOrder;
      if (l != null || r != null) {
        final compared = (l ?? left.label.number ?? double.infinity).compareTo(
          r ?? right.label.number ?? double.infinity,
        );
        if (compared != 0) return compared;
      }
      return _compareEpisodes(left, right);
    });
    return Future.wait(
      episodes.map((episode) async {
        final bindings = await database.episodeBindingsFor(episode.id);
        return PlaybackEpisodeAvailability(
          episode: episode,
          bindings: bindings,
          capabilities: {
            for (final binding in bindings)
              binding.providerId: sources.capability(binding),
          },
        );
      }),
    );
  }

  Future<PlaybackSession> open(PlaybackSessionRequest request) async {
    final mediaId = await database.resolveCanonicalId(request.mediaId);
    final episode = await database.episode(request.episodeId);
    if (episode == null || episode.mediaId != mediaId) {
      throw const PlaybackException(
        PlaybackErrorKind.manifestInvalid,
        'The selected episode does not belong to this anime.',
      );
    }
    final bindings = await database.episodeBindingsFor(episode.id);
    EpisodeSourceBinding? binding;
    if (request.binding case final requested?) {
      binding = bindings
          .where(
            (item) =>
                item.providerId == requested.providerId &&
                item.externalId == requested.externalId,
          )
          .firstOrNull;
    }
    binding ??= await _preferredPlayable(mediaId, bindings);
    if (binding == null ||
        sources.capability(binding) !=
            PlaybackSourceCapability.playbackCapable) {
      throw const PlaybackException(
        PlaybackErrorKind.sourceUnavailable,
        'No playback-capable source is configured for this episode.',
      );
    }
    if (request.binding != null) {
      await database.setPreferredProvider(mediaId, binding.providerId);
    }
    final resolver = sources.resolver(binding.providerId);
    if (resolver == null) {
      throw const PlaybackException(
        PlaybackErrorKind.sourceUnavailable,
        'The playback adapter for this source is unavailable.',
      );
    }
    final manifest = await resolver.resolve(
      PlaybackSessionRequest(
        mediaId: mediaId,
        episodeId: episode.id,
        binding: binding,
      ),
    );
    if (manifest.uri.scheme.isEmpty ||
        manifest.binding.externalId != binding.externalId) {
      throw const PlaybackException(
        PlaybackErrorKind.manifestInvalid,
        'The playback manifest is invalid.',
      );
    }
    final resume = await database.animeSourcePlaybackResume(
      binding.providerId,
      binding.externalId,
    );
    return PlaybackSession(
      mediaId: mediaId,
      episode: episode,
      manifest: manifest,
      startPosition: resume?.position ?? Duration.zero,
      preferences: await preferencesStore.load(),
      resume: resume,
    );
  }

  Future<EpisodeSourceBinding?> _preferredPlayable(
    CanonicalMediaId mediaId,
    List<EpisodeSourceBinding> bindings,
  ) async {
    final playable = bindings
        .where(
          (binding) =>
              sources.capability(binding) ==
              PlaybackSourceCapability.playbackCapable,
        )
        .toList();
    final preferred = await database.preferredProvider(mediaId);
    for (final binding in playable) {
      if (binding.providerId == preferred) return binding;
    }
    playable.sort((a, b) => a.providerId.value.compareTo(b.providerId.value));
    return playable.firstOrNull;
  }

  Future<void> savePosition(
    PlaybackSession session,
    Duration position,
    Duration duration,
  ) async {
    final bounded = position < Duration.zero
        ? Duration.zero
        : position > duration
        ? duration
        : position;
    final now = DateTime.now().toUtc();
    await database.transaction(() async {
      await database.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: session.mediaId,
          episodeId: session.episode.id,
          position: bounded,
          duration: duration,
          updatedAt: now,
        ),
      );
      await database.saveAnimeSourcePlaybackResume(
        AnimeSourcePlaybackResume(
          mediaId: session.mediaId,
          episodeId: session.episode.id,
          providerId: session.manifest.binding.providerId,
          episodeExternalId: session.manifest.binding.externalId,
          position: bounded,
          duration: duration,
          updatedAt: now,
        ),
      );
      if (duration > Duration.zero &&
          bounded.inMilliseconds / duration.inMilliseconds >= 0.9) {
        await database.setEpisodeCompleted(
          session.episode.id,
          origin: CompletionOrigin.automatic,
        );
      }
    });
  }

  Future<void> markWatched(CanonicalEpisodeId episodeId) =>
      database.setEpisodeCompleted(episodeId, origin: CompletionOrigin.manual);

  Future<void> markUnwatched(CanonicalEpisodeId episodeId) =>
      database.setEpisodeUnwatched(episodeId);

  Future<PlaybackEpisodeAvailability?> autoplayNext(
    PlaybackSession session,
  ) async {
    if (!session.preferences.autoplayNext) return null;
    final next = await adjacent(session, 1);
    return next != null && next.playableBindings.isNotEmpty ? next : null;
  }

  Future<void> savePreferences(PlaybackPreferences value) =>
      preferencesStore.save(value);

  Future<PlaybackEpisodeAvailability?> adjacent(
    PlaybackSession session,
    int direction,
  ) async {
    final values = await episodes(session.mediaId);
    final index = values.indexWhere(
      (item) => item.episode.id == session.episode.id,
    );
    final next = index + direction;
    return index < 0 || next < 0 || next >= values.length ? null : values[next];
  }
}

int _compareEpisodes(CanonicalEpisode left, CanonicalEpisode right) {
  final l = left.label.number;
  final r = right.label.number;
  if (l != null && r != null) {
    final compared = l.compareTo(r);
    if (compared != 0) return compared;
  } else if (l != null) {
    return -1;
  } else if (r != null) {
    return 1;
  }
  return left.label.rawLabel.toLowerCase().compareTo(
    right.label.rawLabel.toLowerCase(),
  );
}
