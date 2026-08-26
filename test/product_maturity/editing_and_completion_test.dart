import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/product_maturity/maturity_domain.dart';
import 'package:zanka_no_tachi/adapter_platform/adapter_sdk.dart';

void main() {
  late CanonicalDatabase database;
  const provider = ProviderId('local');
  const mediaId = CanonicalMediaId('media');

  setUp(() async {
    database = CanonicalDatabase(NativeDatabase.memory());
    await database.saveMedia(
      const CanonicalManga(
        id: mediaId,
        title: SourcedValue(
          value: 'Provider fact',
          provenance: FieldProvenance(providerId: provider),
        ),
        status: CanonicalMediaStatus.unknown,
      ),
    );
  });

  tearDown(() => database.close());

  test(
    'chapter edit is an overlay and preserves identity and both progress layers',
    () async {
      const chapterId = CanonicalChapterId('chapter');
      await database.saveChapter(
        CanonicalChapter(
          id: chapterId,
          mediaId: mediaId,
          number: ChapterNumber.parse('Chapter one'),
        ),
      );
      await database.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: mediaId,
          chapterId: chapterId,
          pageIndex: 4,
          totalPages: 10,
          updatedAt: DateTime.utc(2026),
        ),
      );
      await database.saveChapterBinding(
        const ChapterSourceBinding(
          canonicalId: chapterId,
          providerId: provider,
          externalId: 'binding',
        ),
      );
      await database.saveMangaSourcePageResume(
        MangaSourcePageResume(
          mediaId: mediaId,
          chapterId: chapterId,
          providerId: provider,
          chapterExternalId: 'binding',
          pageIndex: 4,
          totalPages: 10,
          updatedAt: DateTime.utc(2026),
        ),
      );

      await database.saveChapterUserEdit(
        ChapterUserEdit(
          chapterId: chapterId,
          rawLabel: '7.5',
          kind: MangaInstallmentKind.decimal,
          volumeLabel: '2',
          explicitOrder: 7.5,
          sourceDisplayLabel: 'Bonus chapter',
          updatedAt: DateTime.utc(2026, 2),
        ),
      );

      expect(
        (await database.chapter(chapterId))!.number.rawLabel,
        'Chapter one',
      );
      expect((await database.chapterUserEdit(chapterId))!.rawLabel, '7.5');
      expect((await database.mangaProgress(mediaId))!.chapterId, chapterId);
      expect(
        (await database.mangaSourcePageResume(provider, 'binding'))!.pageIndex,
        4,
      );
    },
  );

  test(
    'episode edit preserves identity, canonical progress, and source resume',
    () async {
      await database.saveMedia(
        const CanonicalAnime(
          id: mediaId,
          title: SourcedValue(
            value: 'Anime',
            provenance: FieldProvenance(providerId: provider),
          ),
          status: CanonicalMediaStatus.unknown,
          format: AnimeFormat.unknown,
        ),
      );
      const episodeId = CanonicalEpisodeId('episode');
      await database.saveEpisode(
        CanonicalEpisode(
          id: episodeId,
          mediaId: mediaId,
          label: EpisodeLabel.parse('Special'),
        ),
      );
      await database.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: mediaId,
          episodeId: episodeId,
          position: const Duration(seconds: 30),
          duration: const Duration(minutes: 2),
          updatedAt: DateTime.utc(2026),
        ),
      );
      await database.saveEpisodeBinding(
        const EpisodeSourceBinding(
          canonicalId: episodeId,
          providerId: provider,
          externalId: 'video',
        ),
      );
      await database.saveAnimeSourcePlaybackResume(
        AnimeSourcePlaybackResume(
          mediaId: mediaId,
          episodeId: episodeId,
          providerId: provider,
          episodeExternalId: 'video',
          position: const Duration(seconds: 30),
          duration: const Duration(minutes: 2),
          updatedAt: DateTime.utc(2026),
        ),
      );
      await database.saveEpisodeUserEdit(
        EpisodeUserEdit(
          episodeId: episodeId,
          rawLabel: 'OVA 1',
          number: 1,
          kind: AnimeInstallmentKind.ova,
          explicitOrder: 1.5,
          sourceDisplayLabel: 'Disc extra',
          updatedAt: DateTime.utc(2026, 2),
        ),
      );
      expect((await database.episode(episodeId))!.label.rawLabel, 'Special');
      expect(
        (await database.episodeUserEdit(episodeId))!.kind,
        AnimeInstallmentKind.ova,
      );
      expect((await database.animeProgress(mediaId))!.episodeId, episodeId);
      expect(
        (await database.animeSourcePlaybackResume(provider, 'video'))!.position,
        const Duration(seconds: 30),
      );
    },
  );

  test('completion is reversible and never clears exact resume', () async {
    const chapterId = CanonicalChapterId('chapter');
    await database.saveChapter(
      CanonicalChapter(
        id: chapterId,
        mediaId: mediaId,
        number: ChapterNumber.parse('1'),
      ),
    );
    await database.saveMangaProgress(
      CanonicalMangaProgress(
        mediaId: mediaId,
        chapterId: chapterId,
        pageIndex: 8,
        totalPages: 9,
        updatedAt: DateTime.utc(2026),
      ),
    );
    await database.setChapterCompleted(
      chapterId,
      origin: CompletionOrigin.automatic,
    );
    expect(await database.chapterCompletionsFor(mediaId), hasLength(1));
    await database.setChapterUnread(chapterId);
    expect(await database.chapterCompletionsFor(mediaId), isEmpty);
    expect((await database.mangaProgress(mediaId))!.pageIndex, 8);
  });

  test(
    'individual and all metadata clears fall back to source facts',
    () async {
      await database.saveMetadataOverride(
        const MetadataOverride(
          mediaId: mediaId,
          displayTitle: 'My title',
          description: 'My description',
          genres: ['Personal'],
          status: CanonicalMediaStatus.completed,
        ),
      );
      expect((await database.effectiveMedia(mediaId))!.title.value, 'My title');
      await database.clearMetadataOverrideField(
        mediaId,
        MetadataOverrideField.displayTitle,
      );
      expect(
        (await database.effectiveMedia(mediaId))!.title.value,
        'Provider fact',
      );
      expect(
        (await database.metadataOverride(mediaId))!.description,
        'My description',
      );
      await database.clearMetadataOverride(mediaId);
      expect(
        (await database.effectiveMedia(mediaId))!.status,
        CanonicalMediaStatus.unknown,
      );
    },
  );
}
