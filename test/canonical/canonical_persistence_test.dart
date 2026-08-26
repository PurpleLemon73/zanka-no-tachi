import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
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
    'canonical state and provenance round-trip through an isolated file database',
    () async {
      final directory = await Directory.systemTemp.createTemp('zanka-m1-');
      final file = File('${directory.path}/canonical.sqlite');
      const mediaId = CanonicalMediaId('roundtrip-anime');
      const episodeId = CanonicalEpisodeId('roundtrip-episode');
      final now = DateTime.utc(2026, 8, 25, 10, 30);
      var database = CanonicalDatabase(NativeDatabase(file));
      await database.saveMedia(
        CanonicalAnime(
          id: mediaId,
          title: const SourcedValue(
            value: 'Canonical title',
            provenance: FieldProvenance(
              providerId: ProviderId('metadata-source'),
            ),
            rawValue: 'Raw title',
          ),
          alternateTitles: const [
            SourcedValue(
              value: 'Alt',
              provenance: FieldProvenance(providerId: ProviderId('provider-a')),
            ),
          ],
          description: const SourcedValue(
            value: 'Description',
            provenance: FieldProvenance(providerId: ProviderId('provider-a')),
          ),
          genres: const [
            SourcedValue(
              value: 'Sci-Fi',
              provenance: FieldProvenance(providerId: ProviderId('provider-a')),
            ),
          ],
          format: AnimeFormat.ova,
          airingWindow: const AiringWindow(
            season: AiringSeason.winter,
            year: 2020,
            rawLabel: 'Inverno 2020',
          ),
          knownEpisodeTotal: null,
          rawEpisodeTotal: '??',
        ),
      );
      await database.saveEpisode(
        CanonicalEpisode(
          id: episodeId,
          mediaId: mediaId,
          label: EpisodeLabel.parse('Special A'),
        ),
      );
      await database.saveLibraryEntry(
        CanonicalLibraryEntry(
          mediaId: mediaId,
          isSaved: true,
          isFavorite: true,
          status: CanonicalLibraryStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: mediaId,
          episodeId: episodeId,
          position: const Duration(minutes: 4),
          updatedAt: now,
        ),
      );
      await database.close();

      database = CanonicalDatabase(NativeDatabase(file));
      final media = await database.media(mediaId) as CanonicalAnime;
      expect(
        media.title.provenance.providerId,
        const ProviderId('metadata-source'),
      );
      expect(media.alternateTitles.single.value, 'Alt');
      expect(media.genres.single.value, 'Sci-Fi');
      expect(media.format, AnimeFormat.ova);
      expect(media.rawEpisodeTotal, '??');
      expect((await database.libraryEntry(mediaId))?.isFavorite, isTrue);
      expect(
        (await database.animeProgress(mediaId))?.position,
        const Duration(minutes: 4),
      );
      await database.close();
      await directory.delete(recursive: true);
    },
  );

  test(
    'binding uniqueness keeps one provider binding per canonical entity',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      const mediaId = CanonicalMediaId('media');
      await database.saveMedia(
        const CanonicalManga(
          id: mediaId,
          title: SourcedValue(
            value: 'Manga',
            provenance: FieldProvenance(providerId: ProviderId('p')),
          ),
        ),
      );
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: mediaId,
          providerId: ProviderId('p'),
          externalId: 'old',
        ),
      );
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: mediaId,
          providerId: ProviderId('p'),
          externalId: 'new',
        ),
      );
      final rows = await (database.select(
        database.canonicalMediaBindings,
      )..orderBy([(row) => OrderingTerm.asc(row.externalId)])).get();
      expect(rows, hasLength(1));
      expect(rows.single.externalId, 'new');
      const otherMediaId = CanonicalMediaId('other-media');
      await database.saveMedia(
        const CanonicalManga(
          id: otherMediaId,
          title: SourcedValue(
            value: 'Other',
            provenance: FieldProvenance(providerId: ProviderId('p')),
          ),
        ),
      );
      await expectLater(
        database.saveMediaBinding(
          const MediaSourceBinding(
            canonicalId: otherMediaId,
            providerId: ProviderId('p'),
            externalId: 'new',
          ),
        ),
        throwsA(anything),
      );
      expect(
        await database.mediaBinding(const ProviderId('p'), 'new'),
        mediaId,
      );
      await database.close();
    },
  );

  test(
    'library and both progress types survive replacement and restart',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'zanka-replacement-',
      );
      final file = File('${directory.path}/state.sqlite');
      const mangaId = CanonicalMediaId('manga');
      const animeId = CanonicalMediaId('anime');
      const chapterId = CanonicalChapterId('chapter');
      const episodeId = CanonicalEpisodeId('episode');
      const providerA = ProviderId('provider-a');
      const providerB = ProviderId('provider-b');
      const provenance = FieldProvenance(providerId: providerA);
      final now = DateTime.utc(2026, 8, 25);
      var database = CanonicalDatabase(NativeDatabase(file));
      await database.saveMedia(
        const CanonicalManga(
          id: mangaId,
          title: SourcedValue(value: 'Manga', provenance: provenance),
        ),
      );
      await database.saveMedia(
        const CanonicalAnime(
          id: animeId,
          title: SourcedValue(value: 'Anime', provenance: provenance),
          format: AnimeFormat.tv,
        ),
      );
      await database.saveChapter(
        CanonicalChapter(
          id: chapterId,
          mediaId: mangaId,
          number: ChapterNumber.parse('Extra'),
        ),
      );
      await database.saveEpisode(
        CanonicalEpisode(
          id: episodeId,
          mediaId: animeId,
          label: EpisodeLabel.parse('Special A'),
        ),
      );
      await database.saveLibraryEntry(
        CanonicalLibraryEntry(
          mediaId: mangaId,
          isSaved: true,
          isFavorite: true,
          status: CanonicalLibraryStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await database.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: mangaId,
          chapterId: chapterId,
          pageIndex: 17,
          updatedAt: now,
        ),
      );
      await database.saveAnimeProgress(
        CanonicalAnimeProgress(
          mediaId: animeId,
          episodeId: episodeId,
          position: const Duration(minutes: 9),
          updatedAt: now,
        ),
      );
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: mangaId,
          providerId: providerA,
          externalId: 'A-M',
        ),
      );
      await database.saveChapterBinding(
        const ChapterSourceBinding(
          canonicalId: chapterId,
          providerId: providerA,
          externalId: 'A-C',
        ),
      );
      await database.saveEpisodeBinding(
        const EpisodeSourceBinding(
          canonicalId: episodeId,
          providerId: providerA,
          externalId: 'A-E',
        ),
      );
      await database.removeProviderBindings(providerA);
      await database.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: mangaId,
          providerId: providerB,
          externalId: 'B-M',
        ),
      );
      await database.saveChapterBinding(
        const ChapterSourceBinding(
          canonicalId: chapterId,
          providerId: providerB,
          externalId: 'B-C',
        ),
      );
      await database.saveEpisodeBinding(
        const EpisodeSourceBinding(
          canonicalId: episodeId,
          providerId: providerB,
          externalId: 'B-E',
        ),
      );
      await database.close();

      database = CanonicalDatabase(NativeDatabase(file));
      expect((await database.libraryEntry(mangaId))?.isFavorite, isTrue);
      expect((await database.mangaProgress(mangaId))?.pageIndex, 17);
      expect((await database.mangaProgress(mangaId))?.totalPages, isNull);
      expect(
        (await database.animeProgress(animeId))?.position,
        const Duration(minutes: 9),
      );
      expect((await database.animeProgress(animeId))?.duration, isNull);
      expect(await database.chapterBinding(providerA, 'A-C'), isNull);
      expect(await database.chapterBinding(providerB, 'B-C'), chapterId);
      expect(await database.episodeBinding(providerB, 'B-E'), episodeId);
      await database.close();
      await directory.delete(recursive: true);
    },
  );

  test('progress rejects an installment belonging to another media', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    const sourceMedia = CanonicalMediaId('source');
    const otherMedia = CanonicalMediaId('other');
    const chapterId = CanonicalChapterId('chapter');
    const provenance = FieldProvenance(providerId: ProviderId('p'));
    await database.saveMedia(
      const CanonicalManga(
        id: sourceMedia,
        title: SourcedValue(value: 'Source', provenance: provenance),
      ),
    );
    await database.saveMedia(
      const CanonicalManga(
        id: otherMedia,
        title: SourcedValue(value: 'Other', provenance: provenance),
      ),
    );
    await database.saveChapter(
      CanonicalChapter(
        id: chapterId,
        mediaId: sourceMedia,
        number: ChapterNumber.parse('1'),
      ),
    );
    expect(
      () => database.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: otherMedia,
          chapterId: chapterId,
          pageIndex: 2,
          updatedAt: DateTime.now(),
        ),
      ),
      throwsA(isA<StateError>()),
    );
    await database.close();
  });
}
