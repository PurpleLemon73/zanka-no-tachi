import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/local_playback_source.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/player/playback_repository.dart';
import 'package:zanka_no_tachi/player/playback_source.dart';

const mediaId = CanonicalMediaId('anime');
const episodeId = CanonicalEpisodeId('episode-1');
const sourceA = ProviderId('source-a');
const sourceB = ProviderId('source-b');

void main() {
  late CanonicalDatabase database;
  late Directory temp;
  late PlaybackRepository repository;

  setUp(() async {
    database = CanonicalDatabase(NativeDatabase.memory());
    temp = await Directory.systemTemp.createTemp('zanka-player-test');
    repository = PlaybackRepository(
      database: database,
      sources: PlaybackSourceRegistry([
        _FakeResolver(sourceA),
        _FakeResolver(sourceB),
      ]),
      preferencesStore: PlaybackPreferencesStore(
        file: File('${temp.path}/preferences.json'),
      ),
    );
    const provenance = FieldProvenance(providerId: sourceA);
    await database.saveMedia(
      const CanonicalAnime(
        id: mediaId,
        title: SourcedValue(value: 'Sample anime', provenance: provenance),
        status: CanonicalMediaStatus.ongoing,
        format: AnimeFormat.tv,
      ),
    );
    await database.saveEpisode(
      const CanonicalEpisode(
        id: episodeId,
        mediaId: mediaId,
        label: EpisodeLabel(rawLabel: 'Episode 1', number: 1),
      ),
    );
    await database.saveEpisodeBinding(
      const EpisodeSourceBinding(
        canonicalId: episodeId,
        providerId: sourceA,
        externalId: 'a-1',
        relativeLocator: '/a.mp4',
      ),
    );
    await database.saveEpisodeBinding(
      const EpisodeSourceBinding(
        canonicalId: episodeId,
        providerId: sourceB,
        externalId: 'b-1',
        relativeLocator: '/b.mp4',
      ),
    );
  });

  tearDown(() async {
    await database.close();
    await temp.delete(recursive: true);
  });

  test(
    'same binding resumes exact timestamp and persists canonical progress',
    () async {
      final first = await repository.open(
        const PlaybackSessionRequest(
          mediaId: mediaId,
          episodeId: episodeId,
          binding: EpisodeSourceBinding(
            canonicalId: episodeId,
            providerId: sourceA,
            externalId: 'a-1',
            relativeLocator: '/a.mp4',
          ),
        ),
      );
      await repository.savePosition(
        first,
        const Duration(seconds: 42),
        const Duration(minutes: 2),
      );
      final reopened = await repository.open(
        const PlaybackSessionRequest(
          mediaId: mediaId,
          episodeId: episodeId,
          binding: EpisodeSourceBinding(
            canonicalId: episodeId,
            providerId: sourceA,
            externalId: 'a-1',
          ),
        ),
      );
      expect(reopened.startPosition, const Duration(seconds: 42));
      expect(
        (await database.animeProgress(mediaId))?.position,
        const Duration(seconds: 42),
      );
    },
  );

  test(
    'deliberate episode navigation starts at zero without erasing resume',
    () async {
      final session = await repository.open(
        const PlaybackSessionRequest(mediaId: mediaId, episodeId: episodeId),
      );
      await repository.savePosition(
        session,
        const Duration(seconds: 42),
        const Duration(minutes: 2),
      );
      final deliberateStart = await repository.open(
        const PlaybackSessionRequest(
          mediaId: mediaId,
          episodeId: episodeId,
          startAtBeginning: true,
        ),
      );
      expect(deliberateStart.startPosition, Duration.zero);
      final normalResume = await repository.open(
        const PlaybackSessionRequest(mediaId: mediaId, episodeId: episodeId),
      );
      expect(normalResume.startPosition, const Duration(seconds: 42));
    },
  );

  test(
    'canonical first, middle, last and unavailable adjacency is truthful',
    () async {
      const second = CanonicalEpisodeId('episode-2');
      const third = CanonicalEpisodeId('episode-3');
      for (final item in const [
        (second, 'Episode 2', 2.0),
        (third, 'Episode 3', 3.0),
      ]) {
        await database.saveEpisode(
          CanonicalEpisode(
            id: item.$1,
            mediaId: mediaId,
            label: EpisodeLabel(rawLabel: item.$2, number: item.$3),
          ),
        );
      }
      await database.saveEpisodeBinding(
        const EpisodeSourceBinding(
          canonicalId: second,
          providerId: sourceA,
          externalId: 'a-2',
          relativeLocator: '/a2.mp4',
        ),
      );
      await database.saveEpisodeBinding(
        const EpisodeSourceBinding(
          canonicalId: third,
          providerId: ProviderId('metadata-only'),
          externalId: 'meta-3',
        ),
      );
      final first = await repository.open(
        const PlaybackSessionRequest(mediaId: mediaId, episodeId: episodeId),
      );
      expect(await repository.adjacent(first, -1), isNull);
      expect((await repository.adjacent(first, 1))?.episode.id, second);
      final middle = await repository.open(
        const PlaybackSessionRequest(mediaId: mediaId, episodeId: second),
      );
      expect((await repository.adjacent(middle, -1))?.episode.id, episodeId);
      final unavailable = await repository.adjacent(middle, 1);
      expect(unavailable?.episode.id, third);
      expect(unavailable?.openableBindings, isEmpty);
    },
  );

  test(
    'switching encode starts at zero and does not copy exact resume',
    () async {
      final first = await repository.open(
        const PlaybackSessionRequest(
          mediaId: mediaId,
          episodeId: episodeId,
          binding: EpisodeSourceBinding(
            canonicalId: episodeId,
            providerId: sourceA,
            externalId: 'a-1',
          ),
        ),
      );
      await repository.savePosition(
        first,
        const Duration(seconds: 75),
        const Duration(minutes: 2),
      );
      final alternate = await repository.open(
        const PlaybackSessionRequest(
          mediaId: mediaId,
          episodeId: episodeId,
          binding: EpisodeSourceBinding(
            canonicalId: episodeId,
            providerId: sourceB,
            externalId: 'b-1',
          ),
        ),
      );
      expect(alternate.startPosition, Duration.zero);
      expect(await database.animeSourcePlaybackResume(sourceB, 'b-1'), isNull);
      expect(
        (await database.animeProgress(mediaId))?.position,
        const Duration(seconds: 75),
      );
    },
  );

  test('fresh live retry is bounded and preserves exact timestamp', () async {
    final original = await repository.open(
      const PlaybackSessionRequest(mediaId: mediaId, episodeId: episodeId),
    );
    await repository.savePosition(
      original,
      const Duration(seconds: 37),
      const Duration(minutes: 2),
    );
    final resolver = _FlakyPlaybackResolver();
    final retrying = PlaybackRepository(
      database: database,
      sources: PlaybackSourceRegistry([resolver]),
      preferencesStore: PlaybackPreferencesStore(
        file: File('${temp.path}/retry-preferences.json'),
      ),
    );
    final reopened = await retrying.open(
      const PlaybackSessionRequest(
        mediaId: mediaId,
        episodeId: episodeId,
        binding: EpisodeSourceBinding(
          canonicalId: episodeId,
          providerId: sourceA,
          externalId: 'a-1',
        ),
      ),
    );
    expect(resolver.calls, 2);
    expect(reopened.startPosition, const Duration(seconds: 37));
    expect(
      (await database.animeProgress(mediaId))?.position,
      const Duration(seconds: 37),
    );
  });

  test('metadata-only bindings are not playback capable', () async {
    const metadata = EpisodeSourceBinding(
      canonicalId: episodeId,
      providerId: ProviderId('animeworld'),
      externalId: 'token',
    );
    expect(
      PlaybackSourceRegistry(const []).capability(metadata),
      PlaybackSourceCapability.metadataOnly,
    );
  });

  test('position is clamped and player preferences survive reopen', () async {
    final session = await repository.open(
      const PlaybackSessionRequest(mediaId: mediaId, episodeId: episodeId),
    );
    await repository.savePosition(
      session,
      const Duration(minutes: 5),
      const Duration(minutes: 2),
    );
    expect(
      (await database.animeProgress(mediaId))?.position,
      const Duration(minutes: 2),
    );
    const preferences = PlaybackPreferences(
      seekStepSeconds: 15,
      autoplay: false,
      speed: 1.5,
      preferredAudioLanguage: 'ja',
      preferredSubtitleLanguage: 'it',
    );
    await repository.savePreferences(preferences);
    final reopened = await repository.open(
      const PlaybackSessionRequest(mediaId: mediaId, episodeId: episodeId),
    );
    expect(reopened.preferences.seekStepSeconds, 15);
    expect(reopened.preferences.autoplay, isFalse);
    expect(reopened.preferences.speed, 1.5);
    expect(reopened.preferences.preferredSubtitleLanguage, 'it');
  });

  test('local resolver reports a missing file as a typed failure', () async {
    const resolver = LocalVideoPlaybackSource(sourceA, 'Local');
    await expectLater(
      resolver.resolve(
        const PlaybackSessionRequest(
          mediaId: mediaId,
          episodeId: episodeId,
          binding: EpisodeSourceBinding(
            canonicalId: episodeId,
            providerId: sourceA,
            externalId: 'missing',
            relativeLocator: '/definitely/missing.mp4',
          ),
        ),
      ),
      throwsA(
        isA<PlaybackException>().having(
          (error) => error.kind,
          'kind',
          PlaybackErrorKind.localFileMissing,
        ),
      ),
    );
  });

  test(
    'watched threshold is separate from resume and autoplay requires playable next',
    () async {
      const second = CanonicalEpisodeId('episode-2');
      await database.saveEpisode(
        const CanonicalEpisode(
          id: second,
          mediaId: mediaId,
          label: EpisodeLabel(rawLabel: 'Episode 2', number: 2),
        ),
      );
      await database.saveEpisodeBinding(
        const EpisodeSourceBinding(
          canonicalId: second,
          providerId: sourceA,
          externalId: 'a-2',
          relativeLocator: '/a2.mp4',
        ),
      );
      await repository.savePreferences(
        const PlaybackPreferences(autoplayNext: true),
      );
      final session = await repository.open(
        const PlaybackSessionRequest(mediaId: mediaId, episodeId: episodeId),
      );
      await repository.savePosition(
        session,
        const Duration(seconds: 91),
        const Duration(seconds: 100),
      );
      expect(await database.episodeCompletionsFor(mediaId), hasLength(1));
      expect(
        (await database.animeProgress(mediaId))!.position,
        const Duration(seconds: 91),
      );
      expect((await repository.autoplayNext(session))!.episode.id, second);
      await repository.markUnwatched(episodeId);
      expect(await database.episodeCompletionsFor(mediaId), isEmpty);
      expect(
        (await database.animeProgress(mediaId))!.position,
        const Duration(seconds: 91),
      );
    },
  );
}

class _FakeResolver implements PlaybackSourceResolver {
  const _FakeResolver(this.providerId);
  @override
  final ProviderId providerId;
  @override
  PlaybackSourceCapability capability(EpisodeSourceBinding binding) =>
      PlaybackSourceCapability.playbackCapable;
  @override
  Future<PlaybackManifest> resolve(PlaybackSessionRequest request) async =>
      PlaybackManifest(
        sourceName: providerId.value,
        binding: request.binding!,
        uri: Uri.file(request.binding!.relativeLocator ?? '/fake.mp4'),
      );
}

class _FlakyPlaybackResolver
    implements PlaybackSourceResolver, FreshPlaybackManifestRetry {
  int calls = 0;
  @override
  ProviderId get providerId => sourceA;
  @override
  PlaybackSourceCapability capability(EpisodeSourceBinding binding) =>
      PlaybackSourceCapability.playbackCapable;
  @override
  Future<PlaybackManifest> resolve(PlaybackSessionRequest request) async {
    calls++;
    if (calls == 1) {
      throw const PlaybackException(
        PlaybackErrorKind.sourceUnavailable,
        'temporary',
      );
    }
    return PlaybackManifest(
      sourceName: 'Recovered',
      binding: request.binding!,
      uri: Uri.file('/recovered.mp4'),
    );
  }
}
