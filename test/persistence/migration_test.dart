import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:zanka_no_tachi/adapter_platform/adapter_descriptor.dart';
import 'package:zanka_no_tachi/adapter_platform/adapter_sdk.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/local_library/local_asset.dart';
import 'package:zanka_no_tachi/product_maturity/maturity_domain.dart';

void main() {
  late Directory temporary;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('zanka-migration-');
  });
  tearDown(() async {
    await temporary.delete(recursive: true);
  });

  test(
    'representative v1 state migrates to v6 without losing user state',
    () async {
      final file = File('${temporary.path}/v1.sqlite');
      var database = CanonicalDatabase(NativeDatabase(file));
      await _seedCore(database);
      await database.close();
      _downgrade(file, 1);

      database = CanonicalDatabase(NativeDatabase(file));
      expect(
        (await database.libraryEntry(
          const CanonicalMediaId('manga'),
        ))?.isFavorite,
        isTrue,
      );
      expect(
        (await database.mangaProgress(
          const CanonicalMediaId('manga'),
        ))?.pageIndex,
        7,
      );
      expect(
        (await database.animeProgress(
          const CanonicalMediaId('anime'),
        ))?.position,
        const Duration(seconds: 42),
      );
      await database.saveMetadataOverride(
        const MetadataOverride(
          mediaId: CanonicalMediaId('manga'),
          displayTitle: 'Migrated title',
        ),
      );
      expect(
        (await database.effectiveMedia(
          const CanonicalMediaId('manga'),
        ))?.title.value,
        'Migrated title',
      );
      expect(database.schemaVersion, 6);
      await database.close();
    },
  );

  test('representative v3 aliases and exact source resumes survive', () async {
    final file = File('${temporary.path}/v3.sqlite');
    var database = CanonicalDatabase(NativeDatabase(file));
    await _seedCore(database);
    await database.saveMangaSourcePageResume(
      CanonicalMangaProgressFixture.resume,
    );
    await database.saveAnimeSourcePlaybackResume(
      CanonicalAnimeProgressFixture.resume,
    );
    await database.saveCanonicalAlias(
      historicalId: const CanonicalMediaId('old-manga'),
      targetId: const CanonicalMediaId('manga'),
      mergeAuditId: 'audit-fixture',
      createdAt: DateTime.utc(2026),
    );
    await database.close();
    _downgrade(file, 3);

    database = CanonicalDatabase(NativeDatabase(file));
    expect(
      await database.resolveCanonicalId(const CanonicalMediaId('old-manga')),
      const CanonicalMediaId('manga'),
    );
    expect(
      (await database.mangaSourcePageResume(
        const ProviderId('source'),
        'chapter-1',
      ))?.pageIndex,
      7,
    );
    expect(
      (await database.animeSourcePlaybackResume(
        const ProviderId('source'),
        'episode-1',
      ))?.position,
      const Duration(seconds: 42),
    );
    await database.close();
  });

  test(
    'representative v4 local assets survive and v6 state becomes available',
    () async {
      final file = File('${temporary.path}/v4.sqlite');
      var database = CanonicalDatabase(NativeDatabase(file));
      await _seedCore(database);
      await database.saveLocalAsset(
        LocalAsset(
          id: const LocalAssetId('asset'),
          kind: LocalAssetKind.mangaArchive,
          ownership: LocalAssetOwnership.appOwnedCopy,
          state: LocalAssetState.missing,
          providerId: const ProviderId('source'),
          bindingExternalId: 'chapter-1',
          mediaId: const CanonicalMediaId('manga'),
          installmentId: 'chapter',
          originalName: 'lawful.cbz',
          sizeBytes: 12,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      );
      await database.close();
      _downgrade(file, 4);

      database = CanonicalDatabase(NativeDatabase(file));
      expect(
        (await database.localAsset(const LocalAssetId('asset')))?.state,
        LocalAssetState.missing,
      );
      await database.recordAdapterCheck(
        const AdapterId('source'),
        success: false,
        parserMismatch: true,
        error: 'fixture drift',
      );
      expect(
        (await database.adapterReliability(
          const AdapterId('source'),
        ))?.lastParserMismatchAt,
        isNotNull,
      );
      await database.close();
    },
  );

  test(
    'v5 upgrades add reversible edits and completion without data loss',
    () async {
      final file = File('${temporary.path}/v5.sqlite');
      var database = CanonicalDatabase(NativeDatabase(file));
      await _seedCore(database);
      await database.close();
      _downgrade(file, 5);

      database = CanonicalDatabase(NativeDatabase(file));
      await database.saveChapterUserEdit(
        ChapterUserEdit(
          chapterId: const CanonicalChapterId('chapter'),
          rawLabel: '1.5',
          kind: MangaInstallmentKind.decimal,
          updatedAt: DateTime.utc(2026),
        ),
      );
      await database.setChapterCompleted(
        const CanonicalChapterId('chapter'),
        origin: CompletionOrigin.manual,
      );
      expect(
        (await database.chapterUserEdit(
          const CanonicalChapterId('chapter'),
        ))!.rawLabel,
        '1.5',
      );
      expect(
        await database.chapterCompletionsFor(const CanonicalMediaId('manga')),
        hasLength(1),
      );
      expect(
        (await database.mangaProgress(
          const CanonicalMediaId('manga'),
        ))!.pageIndex,
        7,
      );
      await database.close();
    },
  );
}

Future<void> _seedCore(CanonicalDatabase database) async {
  const provenance = FieldProvenance(providerId: ProviderId('source'));
  await database.saveMedia(
    const CanonicalManga(
      id: CanonicalMediaId('manga'),
      title: SourcedValue(value: 'Manga', provenance: provenance),
      status: CanonicalMediaStatus.ongoing,
    ),
  );
  await database.saveMedia(
    const CanonicalAnime(
      id: CanonicalMediaId('anime'),
      title: SourcedValue(value: 'Anime', provenance: provenance),
      status: CanonicalMediaStatus.ongoing,
      format: AnimeFormat.tv,
    ),
  );
  await database.saveChapter(
    CanonicalChapter(
      id: const CanonicalChapterId('chapter'),
      mediaId: const CanonicalMediaId('manga'),
      number: ChapterNumber.parse('1'),
    ),
  );
  await database.saveEpisode(
    CanonicalEpisode(
      id: const CanonicalEpisodeId('episode'),
      mediaId: const CanonicalMediaId('anime'),
      label: EpisodeLabel.parse('1'),
    ),
  );
  await database.saveChapterBinding(
    const ChapterSourceBinding(
      canonicalId: CanonicalChapterId('chapter'),
      providerId: ProviderId('source'),
      externalId: 'chapter-1',
    ),
  );
  await database.saveEpisodeBinding(
    const EpisodeSourceBinding(
      canonicalId: CanonicalEpisodeId('episode'),
      providerId: ProviderId('source'),
      externalId: 'episode-1',
    ),
  );
  await database.saveLibraryEntry(
    CanonicalLibraryEntry(
      mediaId: const CanonicalMediaId('manga'),
      isSaved: true,
      isFavorite: true,
      status: CanonicalLibraryStatus.inProgress,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  );
  await database.saveMangaProgress(CanonicalMangaProgressFixture.progress);
  await database.saveAnimeProgress(CanonicalAnimeProgressFixture.progress);
}

abstract final class CanonicalMangaProgressFixture {
  static final progress = CanonicalMangaProgress(
    mediaId: const CanonicalMediaId('manga'),
    chapterId: const CanonicalChapterId('chapter'),
    pageIndex: 7,
    totalPages: 20,
    updatedAt: DateTime.utc(2026),
  );
  static final resume = MangaSourcePageResume(
    mediaId: const CanonicalMediaId('manga'),
    chapterId: const CanonicalChapterId('chapter'),
    providerId: const ProviderId('source'),
    chapterExternalId: 'chapter-1',
    pageIndex: 7,
    totalPages: 20,
    updatedAt: DateTime.utc(2026),
  );
}

abstract final class CanonicalAnimeProgressFixture {
  static final progress = CanonicalAnimeProgress(
    mediaId: const CanonicalMediaId('anime'),
    episodeId: const CanonicalEpisodeId('episode'),
    position: const Duration(seconds: 42),
    duration: const Duration(minutes: 20),
    updatedAt: DateTime.utc(2026),
  );
  static final resume = AnimeSourcePlaybackResume(
    mediaId: const CanonicalMediaId('anime'),
    episodeId: const CanonicalEpisodeId('episode'),
    providerId: const ProviderId('source'),
    episodeExternalId: 'episode-1',
    position: const Duration(seconds: 42),
    duration: const Duration(minutes: 20),
    updatedAt: DateTime.utc(2026),
  );
}

void _downgrade(File file, int version) {
  final database = sqlite.sqlite3.open(file.path);
  try {
    if (version < 6) {
      database.execute('DROP TABLE chapter_user_edit_records');
      database.execute('DROP TABLE episode_user_edit_records');
      database.execute('DROP TABLE chapter_completion_records');
      database.execute('DROP TABLE episode_completion_records');
      if (version == 5) {
        database.execute(
          'ALTER TABLE metadata_override_records DROP COLUMN description',
        );
        database.execute(
          'ALTER TABLE metadata_override_records DROP COLUMN status',
        );
        database.execute(
          'ALTER TABLE metadata_override_records DROP COLUMN anime_format',
        );
        database.execute(
          'ALTER TABLE metadata_override_records DROP COLUMN creator_or_studio',
        );
      }
    }
    if (version < 5) {
      database.execute('DROP TABLE metadata_override_records');
      database.execute('DROP TABLE metadata_enrichment_records');
      database.execute('DROP TABLE adapter_reliability_records');
      database.execute('DROP TABLE adapter_configurations');
    }
    if (version < 4) database.execute('DROP TABLE local_asset_records');
    if (version < 3) {
      database.execute('DROP TABLE anime_source_playback_resumes');
    }
    if (version < 2) {
      database.execute('DROP TABLE preferred_media_sources');
      database.execute('DROP TABLE manga_source_page_resumes');
      database.execute('DROP TABLE canonical_merge_audits');
      database.execute('DROP TABLE canonical_media_aliases');
    }
    database.execute('PRAGMA user_version = $version');
  } finally {
    database.dispose();
  }
}
