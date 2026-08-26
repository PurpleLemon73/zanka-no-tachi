import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/matching.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/canonical/reconciliation/canonical_reconciliation_service.dart';

void main() {
  test('alias resolution follows chains and cycles are rejected', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    await _media(database, 'a', 'provider-a');
    await _media(database, 'b', 'provider-b');
    await database.saveCanonicalAlias(
      historicalId: const CanonicalMediaId('a'),
      targetId: const CanonicalMediaId('b'),
      mergeAuditId: 'first',
      createdAt: DateTime.utc(2026),
    );
    expect(
      await database.resolveCanonicalId(const CanonicalMediaId('a')),
      const CanonicalMediaId('b'),
    );
    await expectLater(
      database.saveCanonicalAlias(
        historicalId: const CanonicalMediaId('b'),
        targetId: const CanonicalMediaId('a'),
        mergeAuditId: 'cycle',
        createdAt: DateTime.utc(2026),
      ),
      throwsStateError,
    );
    await database.close();
  });

  test('duplicate provider conflict rolls the whole merge back', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    await _media(database, 'a', 'same-provider', externalId: 'one');
    await _media(database, 'b', 'same-provider', externalId: 'two');

    await expectLater(
      CanonicalReconciliationService(database).mergeCanonicalMedia(
        sourceId: const CanonicalMediaId('b'),
        targetId: const CanonicalMediaId('a'),
        reason: MergeReason.reviewedUserDecision,
      ),
      throwsA(
        isA<ReconciliationException>().having(
          (error) => error.conflicts.single.kind,
          'conflict kind',
          MergeConflictKind.duplicateProviderBinding,
        ),
      ),
    );

    expect(await database.allMedia(), hasLength(2));
    expect(
      (await database.mediaBindingsFor(
        const CanonicalMediaId('a'),
      )).single.externalId,
      'one',
    );
    expect(
      await database.resolveCanonicalId(const CanonicalMediaId('b')),
      const CanonicalMediaId('b'),
    );
    expect(await database.select(database.canonicalMergeAudits).get(), isEmpty);
    await database.close();
  });

  test('merged state and old-ID redirect survive database reopen', () async {
    final directory = await Directory.systemTemp.createTemp('zanka-m3-reopen-');
    final file = File('${directory.path}/canonical.sqlite');
    var database = CanonicalDatabase(NativeDatabase(file));
    await _media(database, 'a', 'provider-a');
    await _media(database, 'b', 'provider-b');
    final result = await CanonicalReconciliationService(database)
        .mergeCanonicalMedia(
          sourceId: const CanonicalMediaId('b'),
          targetId: const CanonicalMediaId('a'),
          reason: MergeReason.reviewedUserDecision,
        );
    await database.close();

    database = CanonicalDatabase(NativeDatabase(file));
    expect(await database.allMedia(), hasLength(1));
    expect(
      await database.resolveCanonicalId(const CanonicalMediaId('b')),
      const CanonicalMediaId('a'),
    );
    expect(
      (await database.mediaBindingsFor(
        const CanonicalMediaId('a'),
      )).map((binding) => binding.providerId.value).toSet(),
      {'provider-a', 'provider-b'},
    );
    await CanonicalReconciliationService(database).undoMerge(result.auditId);
    expect(await database.allMedia(), hasLength(2));
    await database.close();
    await directory.delete(recursive: true);
  });
}

Future<void> _media(
  CanonicalDatabase database,
  String id,
  String provider, {
  String? externalId,
}) async {
  await database.saveMedia(
    CanonicalManga(
      id: CanonicalMediaId(id),
      title: SourcedValue(
        value: 'Same title',
        provenance: FieldProvenance(providerId: ProviderId(provider)),
      ),
    ),
  );
  await database.saveMediaBinding(
    MediaSourceBinding(
      canonicalId: CanonicalMediaId(id),
      providerId: ProviderId(provider),
      externalId: externalId ?? '$provider-media',
    ),
  );
}
