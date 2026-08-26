import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/matching.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/canonical/reconciliation/canonical_reconciliation_service.dart';
import 'package:zanka_no_tachi/canonical/reconciliation/source_availability.dart';

void main() {
  test(
    'reviewed anime merge reconciles TV overlap and undo restores it',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      await _anime(database, 'anime-a', 'provider-a');
      await _anime(database, 'anime-b', 'provider-b');
      for (final number in [1, 2, 3]) {
        await _episode(database, 'a-$number', 'anime-a', number, 'provider-a');
      }
      for (final number in [2, 3, 4]) {
        await _episode(database, 'b-$number', 'anime-b', number, 'provider-b');
      }
      final now = DateTime.utc(2026, 8, 25);
      await database.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: const CanonicalMediaId('anime-b'),
          episodeId: const CanonicalEpisodeId('b-4'),
          position: const Duration(minutes: 12),
          duration: const Duration(minutes: 24),
          updatedAt: now,
        ),
      );
      await database.saveAnimeSourcePlaybackResume(
        AnimeSourcePlaybackResume(
          mediaId: const CanonicalMediaId('anime-b'),
          episodeId: const CanonicalEpisodeId('b-2'),
          providerId: const ProviderId('provider-b'),
          episodeExternalId: 'provider-b-episode-2',
          position: const Duration(minutes: 7),
          duration: const Duration(minutes: 24),
          updatedAt: now,
        ),
      );

      final service = CanonicalReconciliationService(database);
      final result = await service.mergeCanonicalMedia(
        sourceId: const CanonicalMediaId('anime-b'),
        targetId: const CanonicalMediaId('anime-a'),
        reason: MergeReason.reviewedUserDecision,
      );

      final availability = await SourceAvailabilityRepository(
        database,
      ).episodes(const CanonicalMediaId('anime-a'));
      expect(availability, hasLength(4));
      expect(_providersFor(availability, 1), {'provider-a'});
      expect(_providersFor(availability, 2), {'provider-a', 'provider-b'});
      expect(_providersFor(availability, 3), {'provider-a', 'provider-b'});
      expect(_providersFor(availability, 4), {'provider-b'});
      final progress = await database.animeProgress(
        const CanonicalMediaId('anime-a'),
      );
      expect(progress?.episodeId, const CanonicalEpisodeId('b-4'));
      expect(progress?.position, const Duration(minutes: 12));
      final mergedResume = await database.animeSourcePlaybackResume(
        const ProviderId('provider-b'),
        'provider-b-episode-2',
      );
      expect(mergedResume?.mediaId, const CanonicalMediaId('anime-a'));
      expect(mergedResume?.episodeId, const CanonicalEpisodeId('a-2'));
      expect(mergedResume?.position, const Duration(minutes: 7));

      await service.undoMerge(result.auditId);
      expect(
        await database.episodesFor(const CanonicalMediaId('anime-b')),
        hasLength(3),
      );
      expect(
        (await database.animeProgress(
          const CanonicalMediaId('anime-b'),
        ))?.episodeId,
        const CanonicalEpisodeId('b-4'),
      );
      final restoredResume = await database.animeSourcePlaybackResume(
        const ProviderId('provider-b'),
        'provider-b-episode-2',
      );
      expect(restoredResume?.mediaId, const CanonicalMediaId('anime-b'));
      expect(restoredResume?.episodeId, const CanonicalEpisodeId('b-2'));
      expect(restoredResume?.position, const Duration(minutes: 7));
      await database.close();
    },
  );

  test('non-TV formats are never blindly reconciled', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    await _anime(database, 'ova-a', 'provider-a', format: AnimeFormat.ova);
    await _anime(database, 'ova-b', 'provider-b', format: AnimeFormat.ova);
    await _episode(database, 'a-1', 'ova-a', 1, 'provider-a');
    await _episode(database, 'b-1', 'ova-b', 1, 'provider-b');

    final result = await CanonicalReconciliationService(database)
        .mergeCanonicalMedia(
          sourceId: const CanonicalMediaId('ova-b'),
          targetId: const CanonicalMediaId('ova-a'),
          reason: MergeReason.reviewedUserDecision,
        );

    expect(
      await SourceAvailabilityRepository(
        database,
      ).episodes(const CanonicalMediaId('ova-a')),
      hasLength(2),
    );
    expect(
      result.conflicts.any(
        (item) => item.kind == MergeConflictKind.ambiguousInstallment,
      ),
      isTrue,
    );
    await database.close();
  });
}

Future<void> _anime(
  CanonicalDatabase database,
  String id,
  String provider, {
  AnimeFormat format = AnimeFormat.tv,
}) async {
  await database.saveMedia(
    CanonicalAnime(
      id: CanonicalMediaId(id),
      title: SourcedValue(
        value: 'Example Anime',
        provenance: FieldProvenance(providerId: ProviderId(provider)),
      ),
      format: format,
    ),
  );
  await database.saveMediaBinding(
    MediaSourceBinding(
      canonicalId: CanonicalMediaId(id),
      providerId: ProviderId(provider),
      externalId: '$provider-media',
    ),
  );
}

Future<void> _episode(
  CanonicalDatabase database,
  String id,
  String mediaId,
  int number,
  String provider,
) async {
  await database.saveEpisode(
    CanonicalEpisode(
      id: CanonicalEpisodeId(id),
      mediaId: CanonicalMediaId(mediaId),
      label: EpisodeLabel(
        rawLabel: 'Episode $number',
        number: number.toDouble(),
      ),
      narrativeSeason: 1,
    ),
  );
  await database.saveEpisodeBinding(
    EpisodeSourceBinding(
      canonicalId: CanonicalEpisodeId(id),
      providerId: ProviderId(provider),
      externalId: '$provider-episode-$number',
    ),
  );
}

Set<String> _providersFor(
  List<CanonicalEpisodeAvailability> items,
  int number,
) => items
    .singleWhere((item) => item.episode.label.number == number)
    .sourceBindings
    .map((binding) => binding.providerId.value)
    .toSet();
