import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';

void main() {
  test(
    '1000-item Library and large installment availability stay correct',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      final now = DateTime.utc(2026, 8, 25);
      await database.batch((batch) {
        for (var index = 0; index < 1000; index++) {
          final anime = index == 1;
          final id = 'large-$index';
          batch.insert(
            database.canonicalMediaRecords,
            CanonicalMediaRecordsCompanion.insert(
              id: id,
              kind: anime
                  ? CanonicalMediaKind.anime.name
                  : CanonicalMediaKind.manga.name,
              title: 'Synthetic ${index.toString().padLeft(4, '0')}',
              titleProviderId: 'synthetic-a',
              status: CanonicalMediaStatus.unknown.name,
              animeFormat: anime ? const Value('tv') : const Value.absent(),
            ),
          );
          batch.insert(
            database.canonicalLibraryRecords,
            CanonicalLibraryRecordsCompanion.insert(
              mediaId: id,
              isSaved: true,
              isFavorite: index.isEven,
              status: 'planned',
              createdAt: now,
              updatedAt: now.add(Duration(seconds: index)),
            ),
          );
          batch.insert(
            database.canonicalMediaBindings,
            CanonicalMediaBindingsCompanion.insert(
              canonicalId: id,
              providerId: 'synthetic-a',
              externalId: 'a-$index',
            ),
          );
        }
        for (var index = 0; index < 5000; index++) {
          final id = 'chapter-$index';
          batch.insert(
            database.canonicalChapterRecords,
            CanonicalChapterRecordsCompanion.insert(
              id: id,
              mediaId: 'large-0',
              rawLabel: '${index + 1}',
            ),
          );
          for (final provider in ['synthetic-a', 'synthetic-b']) {
            batch.insert(
              database.canonicalChapterBindings,
              CanonicalChapterBindingsCompanion.insert(
                canonicalId: id,
                providerId: provider,
                externalId: '$provider-$index',
              ),
            );
          }
        }
        for (var index = 0; index < 1000; index++) {
          batch.insert(
            database.canonicalEpisodeRecords,
            CanonicalEpisodeRecordsCompanion.insert(
              id: 'episode-$index',
              mediaId: 'large-1',
              rawLabel: '${index + 1}',
              number: Value(index + 1.0),
            ),
          );
        }
      });
      final live = LiveProviderRepository(
        registry: ProviderRegistry([
          ProviderConfig(
            id: const ProviderId('synthetic-a'),
            displayName: 'Synthetic',
            baseUrl: Uri.parse('https://synthetic.invalid/'),
            mediaKind: CanonicalMediaKind.manga,
          ),
        ]),
        database: database,
        transport: const _OfflineTransport(),
      );
      final product = ProductRepository(live);
      final watch = Stopwatch()..start();
      final summaries = await product.persisted();
      final manga = await live.availability.chapters(
        const CanonicalMediaId('large-0'),
      );
      final anime = await live.availability.episodes(
        const CanonicalMediaId('large-1'),
      );
      watch.stop();
      // Kept visible in verbose CI output as a profiling breadcrumb.
      // ignore: avoid_print
      print('M9 large-library read: ${watch.elapsedMilliseconds} ms');

      expect(summaries, hasLength(1000));
      expect(summaries.where((item) => item.isFavorite), hasLength(500));
      expect(manga, hasLength(5000));
      expect(manga.first.sourceBindings, hasLength(2));
      expect(anime, hasLength(1000));
      // A generous regression ceiling catches accidental per-row queries without
      // turning ordinary CI variance into a benchmark failure.
      expect(watch.elapsed, lessThan(const Duration(seconds: 15)));
      await live.dispose();
    },
  );
}

class _OfflineTransport implements ProviderTransport {
  const _OfflineTransport();
  @override
  Future<ProviderResponse> get(Uri uri) =>
      throw const SocketException('offline');
  @override
  void close() {}
}
