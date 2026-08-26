import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';

void main() {
  test(
    'product library and source preference survive database reopen offline',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'zanka-m4-product-',
      );
      final file = File('${directory.path}/canonical.sqlite');
      var live = _repository(CanonicalDatabase(NativeDatabase(file)));
      await live.seedSyntheticReconciliationScenarios();
      final now = DateTime.utc(2026, 8, 25);
      await live.database.saveLibraryEntry(
        CanonicalLibraryEntry(
          mediaId: const CanonicalMediaId('m3-berserk-a'),
          isSaved: true,
          isFavorite: true,
          status: CanonicalLibraryStatus.paused,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await live.database.setPreferredProvider(
        const CanonicalMediaId('m3-berserk-a'),
        const ProviderId('synthetic-manga-a'),
      );
      await live.dispose();

      live = _repository(CanonicalDatabase(NativeDatabase(file)));
      final product = ProductRepository(live);
      final library = (await product.persisted())
          .where((item) => item.isSaved)
          .toList();
      expect(library.single.media.title.value, 'Berserk (M3 synthetic)');
      expect(library.single.isFavorite, isTrue);
      expect(library.single.library?.status, CanonicalLibraryStatus.paused);
      expect(
        (await product.details(
          const CanonicalMediaId('m3-berserk-a'),
        ))?.preferredProvider,
        const ProviderId('synthetic-manga-a'),
      );
      await live.dispose();
      await directory.delete(recursive: true);
    },
  );
}

LiveProviderRepository _repository(CanonicalDatabase database) =>
    LiveProviderRepository(
      registry: ProviderRegistry([
        ProviderConfig(
          id: const ProviderId('mangaworld'),
          displayName: 'MangaWorld',
          baseUrl: Uri.parse('https://fixture.invalid/'),
          mediaKind: CanonicalMediaKind.manga,
        ),
      ]),
      database: database,
      transport: const _OfflineTransport(),
    );

class _OfflineTransport implements ProviderTransport {
  const _OfflineTransport();
  @override
  Future<ProviderResponse> get(Uri uri) =>
      Future.error(const SocketException('offline'));
  @override
  void close() {}
}
