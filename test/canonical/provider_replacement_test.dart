import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';

void main() {
  test(
    'manga progress survives provider and provider-local ID replacement',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      const mediaId = CanonicalMediaId('media-berserk');
      const chapterId = CanonicalChapterId('chapter-berserk-142');
      const providerA = ProviderId('provider-a');
      const providerB = ProviderId('provider-b');
      final now = DateTime(2026, 8, 25);

      await database.saveMedia(
        CanonicalManga(id: mediaId, title: _title('Berserk', providerA)),
      );
      await database.saveChapter(
        CanonicalChapter(
          id: chapterId,
          mediaId: mediaId,
          number: ChapterNumber.parse('142'),
        ),
      );
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: mediaId,
          providerId: providerA,
          externalId: 'A-MEDIA',
          relativeLocator: '/manga/A-MEDIA',
        ),
      );
      await database.saveChapterBinding(
        const ChapterSourceBinding(
          canonicalId: chapterId,
          providerId: providerA,
          externalId: 'A-CH-142',
          relativeLocator: '/chapter/A-CH-142',
        ),
      );
      await database.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: mediaId,
          chapterId: chapterId,
          pageIndex: 17,
          updatedAt: now,
        ),
      );

      await database.removeProviderBindings(providerA);
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: mediaId,
          providerId: providerB,
          externalId: 'B-MEDIA',
          relativeLocator: '/title/B-MEDIA',
        ),
      );
      await database.saveChapterBinding(
        const ChapterSourceBinding(
          canonicalId: chapterId,
          providerId: providerB,
          externalId: 'B-CH-142',
          relativeLocator: '/chapter/B-CH-142',
        ),
      );

      final progress = await database.mangaProgress(mediaId);
      expect(progress?.mediaId, mediaId);
      expect(progress?.chapterId, chapterId);
      expect(progress?.pageIndex, 17);
      expect(await database.chapterBinding(providerB, 'B-CH-142'), chapterId);
      expect(await database.chapterBinding(providerA, 'A-CH-142'), isNull);
      await database.close();
    },
  );

  test(
    'anime progress survives provider and provider-local ID replacement',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      const mediaId = CanonicalMediaId('media-cowboy-bebop');
      const episodeId = CanonicalEpisodeId('episode-cowboy-bebop-5');
      const providerA = ProviderId('provider-a');
      const providerB = ProviderId('provider-b');
      final now = DateTime(2026, 8, 25);

      await database.saveMedia(
        CanonicalAnime(
          id: mediaId,
          title: _title('Cowboy Bebop', providerA),
          format: AnimeFormat.tv,
        ),
      );
      await database.saveEpisode(
        CanonicalEpisode(
          id: episodeId,
          mediaId: mediaId,
          label: EpisodeLabel.parse('5'),
        ),
      );
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: mediaId,
          providerId: providerA,
          externalId: 'A-ANIME',
        ),
      );
      await database.saveEpisodeBinding(
        const EpisodeSourceBinding(
          canonicalId: episodeId,
          providerId: providerA,
          externalId: 'A-EP-5',
        ),
      );
      await database.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: mediaId,
          episodeId: episodeId,
          position: const Duration(minutes: 12, seconds: 34),
          duration: const Duration(minutes: 24),
          updatedAt: now,
        ),
      );

      await database.removeProviderBindings(providerA);
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: mediaId,
          providerId: providerB,
          externalId: 'B-ANIME',
        ),
      );
      await database.saveEpisodeBinding(
        const EpisodeSourceBinding(
          canonicalId: episodeId,
          providerId: providerB,
          externalId: 'B-EP-5',
        ),
      );

      final progress = await database.animeProgress(mediaId);
      expect(progress?.mediaId, mediaId);
      expect(progress?.episodeId, episodeId);
      expect(progress?.position, const Duration(minutes: 12, seconds: 34));
      expect(await database.episodeBinding(providerB, 'B-EP-5'), episodeId);
      expect(await database.episodeBinding(providerA, 'A-EP-5'), isNull);
      await database.close();
    },
  );
}

SourcedValue<String> _title(String value, ProviderId providerId) =>
    SourcedValue(
      value: value,
      provenance: FieldProvenance(providerId: providerId),
      rawValue: value,
    );
