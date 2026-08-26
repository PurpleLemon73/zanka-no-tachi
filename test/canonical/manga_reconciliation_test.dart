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
    'reviewed manga merge reconciles overlap and undo restores providers',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      await _seedManga(database);
      final service = CanonicalReconciliationService(database);
      final candidates = await service.candidatesFor(
        const CanonicalMediaId('berserk-a'),
      );
      expect(candidates.single.confidence, MatchConfidence.ambiguousCandidate);
      expect(candidates.single.mayAutoMerge, isFalse);

      final result = await service.mergeCanonicalMedia(
        sourceId: const CanonicalMediaId('berserk-b'),
        targetId: const CanonicalMediaId('berserk-a'),
        reason: MergeReason.reviewedUserDecision,
      );

      expect(result.survivingId, const CanonicalMediaId('berserk-a'));
      expect(
        await database.resolveCanonicalId(const CanonicalMediaId('berserk-b')),
        const CanonicalMediaId('berserk-a'),
      );
      expect(await database.allMedia(), hasLength(1));
      final availability = await SourceAvailabilityRepository(
        database,
      ).chapters(const CanonicalMediaId('berserk-a'));
      expect(availability, hasLength(4));
      expect(_providersFor(availability, '140'), {'provider-a'});
      expect(_providersFor(availability, '141'), {'provider-a', 'provider-b'});
      expect(_providersFor(availability, '142'), {'provider-b'});
      expect(_providersFor(availability, '143'), {'provider-a', 'provider-b'});
      expect(
        (await database.libraryEntry(
          const CanonicalMediaId('berserk-a'),
        ))?.isFavorite,
        isTrue,
      );
      final progress = await database.mangaProgress(
        const CanonicalMediaId('berserk-a'),
      );
      expect(progress?.chapterId, const CanonicalChapterId('b-142'));
      expect(progress?.pageIndex, 7);

      await database.setPreferredProvider(
        const CanonicalMediaId('berserk-a'),
        const ProviderId('provider-b'),
      );
      final selected = await PreferredSourceSelector(database).chapterBinding(
        const CanonicalMediaId('berserk-a'),
        const CanonicalChapterId('b-142'),
      );
      expect(selected?.providerId, const ProviderId('provider-b'));
      final sourceResume = await database.mangaSourcePageResume(
        const ProviderId('provider-b'),
        'b-ext-142',
      );
      expect(sourceResume?.pageIndex, 19);
      expect(
        await database.mangaSourcePageResume(
          const ProviderId('provider-a'),
          'a-ext-141',
        ),
        isNull,
      );

      await database.setPreferredProvider(
        const CanonicalMediaId('berserk-a'),
        null,
      );
      await service.undoMerge(result.auditId);
      expect(
        await database.resolveCanonicalId(const CanonicalMediaId('berserk-b')),
        const CanonicalMediaId('berserk-b'),
      );
      expect(await database.allMedia(), hasLength(2));
      expect(
        (await database.mediaBindingsFor(
          const CanonicalMediaId('berserk-b'),
        )).single.providerId,
        const ProviderId('provider-b'),
      );
      expect(
        await database.chaptersFor(const CanonicalMediaId('berserk-b')),
        hasLength(3),
      );
      expect(
        (await database.mangaProgress(
          const CanonicalMediaId('berserk-b'),
        ))?.chapterId,
        const CanonicalChapterId('b-142'),
      );
      expect(
        (await database.mangaSourcePageResume(
          const ProviderId('provider-b'),
          'b-ext-142',
        ))?.mediaId,
        const CanonicalMediaId('berserk-b'),
      );
      await database.close();
    },
  );

  test('decimal and special chapters are not reconciled blindly', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    await _media(database, 'a', 'provider-a');
    await _media(database, 'b', 'provider-b');
    await _chapter(database, 'a-142', 'a', '142', 'provider-a');
    await _chapter(database, 'a-1425', 'a', '142.5', 'provider-a');
    await _chapter(database, 'a-extra', 'a', 'Extra', 'provider-a');
    await _chapter(database, 'b-142', 'b', '142', 'provider-b');
    await _chapter(database, 'b-1425', 'b', '142.5', 'provider-b');
    await _chapter(database, 'b-extra', 'b', 'Extra', 'provider-b');
    final result = await CanonicalReconciliationService(database)
        .mergeCanonicalMedia(
          sourceId: const CanonicalMediaId('b'),
          targetId: const CanonicalMediaId('a'),
          reason: MergeReason.reviewedUserDecision,
        );
    final availability = await SourceAvailabilityRepository(
      database,
    ).chapters(const CanonicalMediaId('a'));
    expect(availability, hasLength(4));
    expect(_providersFor(availability, '142'), {'provider-a', 'provider-b'});
    expect(_providersFor(availability, '142.5'), {'provider-a', 'provider-b'});
    expect(
      availability.where((item) => item.chapter.number.rawLabel == 'Extra'),
      hasLength(2),
    );
    expect(
      result.conflicts.any(
        (conflict) => conflict.kind == MergeConflictKind.ambiguousInstallment,
      ),
      isTrue,
    );
    await database.close();
  });

  test('conflicting known volume labels preserve both chapters', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    await _media(database, 'a', 'provider-a');
    await _media(database, 'b', 'provider-b');
    await _chapter(database, 'a-10', 'a', '10', 'provider-a', volume: '1');
    await _chapter(database, 'b-10', 'b', '10', 'provider-b', volume: '2');

    final result = await CanonicalReconciliationService(database)
        .mergeCanonicalMedia(
          sourceId: const CanonicalMediaId('b'),
          targetId: const CanonicalMediaId('a'),
          reason: MergeReason.reviewedUserDecision,
        );

    expect(
      await database.chaptersFor(const CanonicalMediaId('a')),
      hasLength(2),
    );
    expect(
      result.conflicts.any(
        (conflict) => conflict.kind == MergeConflictKind.ambiguousInstallment,
      ),
      isTrue,
    );
    await database.close();
  });
}

Set<String> _providersFor(
  List<CanonicalChapterAvailability> availability,
  String label,
) => availability
    .singleWhere((item) => item.chapter.number.normalizedNumber == label)
    .sourceBindings
    .map((binding) => binding.providerId.value)
    .toSet();

Future<void> _seedManga(CanonicalDatabase database) async {
  await _media(database, 'berserk-a', 'provider-a');
  await _media(database, 'berserk-b', 'provider-b');
  for (final number in ['140', '141', '143']) {
    await _chapter(database, 'a-$number', 'berserk-a', number, 'provider-a');
  }
  for (final number in ['141', '142', '143']) {
    await _chapter(database, 'b-$number', 'berserk-b', number, 'provider-b');
  }
  final now = DateTime.utc(2026, 8, 25);
  await database.saveLibraryEntry(
    CanonicalLibraryEntry(
      mediaId: const CanonicalMediaId('berserk-a'),
      isSaved: true,
      isFavorite: true,
      status: CanonicalLibraryStatus.inProgress,
      createdAt: now,
      updatedAt: now,
    ),
  );
  await database.saveMangaProgress(
    CanonicalMangaProgress(
      mediaId: const CanonicalMediaId('berserk-b'),
      chapterId: const CanonicalChapterId('b-142'),
      pageIndex: 7,
      updatedAt: now,
    ),
  );
  await database.saveMangaSourcePageResume(
    MangaSourcePageResume(
      mediaId: const CanonicalMediaId('berserk-b'),
      chapterId: const CanonicalChapterId('b-142'),
      providerId: const ProviderId('provider-b'),
      chapterExternalId: 'b-ext-142',
      pageIndex: 19,
      totalPages: 42,
      updatedAt: now,
    ),
  );
}

Future<void> _media(
  CanonicalDatabase database,
  String id,
  String provider,
) async {
  await database.saveMedia(
    CanonicalManga(
      id: CanonicalMediaId(id),
      title: SourcedValue(
        value: id.startsWith('berserk') ? 'Berserk' : 'Same Manga',
        provenance: FieldProvenance(providerId: ProviderId(provider)),
      ),
    ),
  );
  await database.saveMediaBinding(
    MediaSourceBinding(
      canonicalId: CanonicalMediaId(id),
      providerId: ProviderId(provider),
      externalId: '$provider-media-$id',
    ),
  );
}

Future<void> _chapter(
  CanonicalDatabase database,
  String id,
  String mediaId,
  String label,
  String provider, {
  String? volume,
}) async {
  await database.saveChapter(
    CanonicalChapter(
      id: CanonicalChapterId(id),
      mediaId: CanonicalMediaId(mediaId),
      number: ChapterNumber.parse(label),
      volumeLabel: volume,
    ),
  );
  await database.saveChapterBinding(
    ChapterSourceBinding(
      canonicalId: CanonicalChapterId(id),
      providerId: ProviderId(provider),
      externalId: '${provider[provider.length - 1]}-ext-$label',
    ),
  );
}
