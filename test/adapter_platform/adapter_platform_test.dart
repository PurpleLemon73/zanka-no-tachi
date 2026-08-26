import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:zanka_no_tachi/adapter_platform/adapter_descriptor.dart';
import 'package:zanka_no_tachi/adapter_platform/adapter_errors.dart';
import 'package:zanka_no_tachi/adapter_platform/adapter_registry.dart';
import 'package:zanka_no_tachi/adapter_platform/adapter_sdk.dart';
import 'package:zanka_no_tachi/adapter_platform/adapter_diagnostics.dart';
import 'package:zanka_no_tachi/adapter_platform/local_media_tools.dart';
import 'package:zanka_no_tachi/adapter_platform/metadata_enrichment_service.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_adapter.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/local_library/local_library_service.dart';
import 'package:zanka_no_tachi/product/product_models.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';

void main() {
  group('adapter declarations', () {
    final descriptors = AdapterRegistry.coreDescriptors();

    test('existing sources declare exact product capabilities', () {
      AdapterDescriptor named(String id) =>
          descriptors.singleWhere((value) => value.id.value == id);
      expect(
        named('mangaworld').supports(AdapterCapability.chapterMetadata),
        isTrue,
      );
      expect(
        named('mangaworld').supports(AdapterCapability.readerManifest),
        isTrue,
      );
      expect(
        named('animeworld').supports(AdapterCapability.episodeMetadata),
        isTrue,
      );
      expect(
        named('animeworld').supports(AdapterCapability.playbackManifest),
        isTrue,
      );
      expect(
        named('local-import-manga').supports(AdapterCapability.readerManifest),
        isTrue,
      );
      expect(
        named(
          'local-import-video',
        ).supports(AdapterCapability.playbackManifest),
        isTrue,
      );
    });

    test('registry rejects inconsistent and unsupported capability access', () {
      const descriptor = AdapterDescriptor(
        id: AdapterId('fake'),
        displayName: 'Fake',
        scope: AdapterMediaScope.mixed,
        capabilities: {AdapterCapability.catalog},
      );
      expect(
        () => AdapterRegistry(const [
          AdapterRegistration(descriptor: descriptor),
        ]),
        throwsStateError,
      );
      final registry = AdapterRegistry(const [
        AdapterRegistration(
          descriptor: AdapterDescriptor(
            id: AdapterId('empty'),
            displayName: 'Empty',
            scope: AdapterMediaScope.mixed,
            capabilities: {},
          ),
        ),
      ]);
      expect(
        () => registry.requireCapability<SearchAdapter>(
          const AdapterId('empty'),
          AdapterCapability.search,
        ),
        throwsA(isA<AdapterUnsupportedCapability>()),
      );
    });
  });

  test(
    'provider configuration and reliability survive database reopen',
    () async {
      final file = File(
        '${Directory.systemTemp.path}/zanka-m8-${DateTime.now().microsecondsSinceEpoch}.sqlite',
      );
      var database = CanonicalDatabase(NativeDatabase(file));
      var repository = LiveProviderRepository(
        registry: ProviderRegistry.defaults(),
        database: database,
        transport: _Routes({'/archive': '<html><h1>drift</h1></html>'}),
      );
      final manga = repository.registry.require(const ProviderId('mangaworld'));
      await repository.persistProvider(
        manga.copyWith(
          baseUrl: Uri.parse('https://replacement.invalid/'),
          enabled: false,
        ),
      );
      await database.recordAdapterCheck(
        const AdapterId('mangaworld'),
        success: false,
        parserMismatch: true,
        error: 'fixture drift',
      );
      await repository.dispose();

      database = CanonicalDatabase(NativeDatabase(file));
      repository = LiveProviderRepository(
        registry: ProviderRegistry.defaults(),
        database: database,
        transport: _Routes(const {}),
      );
      await repository.loadPersistedProviderConfiguration();
      expect(
        repository.registry.require(const ProviderId('mangaworld')).enabled,
        isFalse,
      );
      expect(
        repository.registry
            .require(const ProviderId('mangaworld'))
            .baseUrl
            .host,
        'replacement.invalid',
      );
      final reliability = await database.adapterReliability(
        const AdapterId('mangaworld'),
      );
      expect(reliability?.consecutiveFailures, 1);
      expect(reliability?.lastParserMismatchAt, isNotNull);
      await repository.dispose();
      await file.delete();
    },
  );

  test(
    'reviewed enrichment has provenance and user override wins after refresh',
    () async {
      final database = CanonicalDatabase(NativeDatabase.memory());
      const id = CanonicalMediaId('media');
      CanonicalManga source(String title) => CanonicalManga(
        id: id,
        title: SourcedValue(
          value: title,
          provenance: const FieldProvenance(providerId: ProviderId('source')),
        ),
        status: CanonicalMediaStatus.ongoing,
      );
      await database.saveMedia(source('Source title'));
      const adapter = DeterministicEnrichmentAdapter();
      await MetadataEnrichmentService(database, const [
        adapter,
      ]).enrichReviewed(id, adapter.descriptor.id);
      expect(
        (await database.enrichmentsFor(id)).single.adapterId,
        adapter.descriptor.id,
      );
      await database.saveMetadataOverride(
        const MetadataOverride(mediaId: id, displayTitle: 'My title'),
      );
      await database.saveMedia(source('Refreshed source title'));
      final effective = await database.effectiveMedia(id);
      expect(effective?.title.value, 'My title');
      expect(effective?.title.provenance.providerId.value, 'user-override');
      await database.close();
    },
  );

  test(
    'CBZ probing, thumbnail cache, batch order correction and import work',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'zanka-m8-local-',
      );
      final one = await _cbz(temporary, 'chapter10.cbz', [1, 2]);
      final two = await _cbz(temporary, 'chapter2.cbz', [3]);
      const probes = LocalMediaProbeService();
      final probe = await probes.probe(one.path);
      expect(probe.pageCount, 2);
      expect(probe.imageFormats, contains('png'));
      final thumbnails = LocalThumbnailService(
        Directory('${temporary.path}/thumbnail-cache'),
        maximumEntries: 2,
      );
      final first = await thumbnails.cbzThumbnail(one.path, 'asset-one');
      final again = await thumbnails.cbzThumbnail(one.path, 'asset-one');
      expect(again.path, first.path);

      final database = CanonicalDatabase(NativeDatabase.memory());
      final library = LocalLibraryService(
        database,
        root: Directory('${temporary.path}/library'),
      );
      final batches = LocalBatchImportService(library, probes);
      final preview = await batches.preview([one.path, two.path]);
      expect(p.basename(preview.first.sourcePath), 'chapter2.cbz');
      final corrected = [
        preview[1].copyWith(label: '1'),
        preview[0].copyWith(label: '2'),
      ];
      final mediaId = await batches.importManga(
        reviewedTitle: 'Reviewed manga',
        items: corrected,
      );
      expect(
        (await database.chaptersFor(
          mediaId,
        )).map((value) => value.number.rawLabel),
        containsAll(['1', '2']),
      );
      expect(await database.mediaBindingsFor(mediaId), hasLength(1));
      await database.close();
      await temporary.delete(recursive: true);
    },
  );

  test(
    'batch video probing and import use canonical source bindings',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'zanka-m8-video-',
      );
      final episode10 = File('${temporary.path}/episode10.mp4')
        ..writeAsBytesSync([1]);
      final episode2 = File('${temporary.path}/episode2.mp4')
        ..writeAsBytesSync([2]);
      final database = CanonicalDatabase(NativeDatabase.memory());
      final batch = LocalBatchImportService(
        LocalLibraryService(
          database,
          root: Directory('${temporary.path}/library'),
        ),
        const LocalMediaProbeService(),
      );
      final preview = await batch.preview([episode10.path, episode2.path]);
      expect(p.basename(preview.first.sourcePath), 'episode2.mp4');
      expect(preview.first.probe.container, 'mp4');
      final mediaId = await batch.importVideos(
        reviewedTitle: 'Reviewed anime',
        items: [
          preview[1].copyWith(label: 'Episode 1'),
          preview[0].copyWith(label: 'Episode 2'),
        ],
      );
      expect(await database.episodesFor(mediaId), hasLength(2));
      expect(
        (await database.mediaBindingsFor(mediaId)).single.providerId,
        importedVideoProviderId,
      );
      await database.close();
      await temporary.delete(recursive: true);
    },
  );

  test('cross-page source duplicates collapse', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    final live = LiveProviderRepository(
      registry: ProviderRegistry(const []),
      database: database,
      transport: const _Routes({}),
    );
    final repository = ProductRepository(live);
    const listing = ProviderListingItem(
      providerId: ProviderId('fake'),
      externalId: 'same',
      relativeLocator: '/same',
      title: 'Same',
      mediaKind: CanonicalMediaKind.manga,
    );
    final values = repository.deduplicateResults(const [
      ProductSearchResult(
        title: 'Same',
        kind: CanonicalMediaKind.manga,
        sources: [listing],
      ),
      ProductSearchResult(
        title: 'Same again',
        kind: CanonicalMediaKind.manga,
        sources: [listing],
      ),
    ]);
    expect(values, hasLength(1));
    await live.dispose();
  });

  test('diagnostics model reports capabilities, config and health', () async {
    final database = CanonicalDatabase(NativeDatabase.memory());
    final live = LiveProviderRepository(
      registry: ProviderRegistry.defaults(),
      database: database,
      transport: const _Routes({}),
    );
    final config = live.registry.require(const ProviderId('mangaworld'));
    await live.persistProvider(config.copyWith(enabled: false));
    await database.recordAdapterCheck(
      const AdapterId('mangaworld'),
      success: false,
      parserMismatch: false,
      error: 'offline',
    );
    final entry = (await AdapterDiagnosticsService(live).snapshot())
        .singleWhere((value) => value.descriptor.id.value == 'mangaworld');
    expect(entry.configuration?.enabled, isFalse);
    expect(entry.reliability?.lastError, 'offline');
    expect(entry.paginationEnabled, isTrue);
    await live.dispose();
  });
}

Future<File> _cbz(Directory root, String name, List<int> pages) async {
  final archive = Archive();
  for (final page in pages) {
    archive.add(ArchiveFile.bytes('$page.png', [page, page + 1, page + 2]));
  }
  final file = File('${root.path}/$name');
  await file.writeAsBytes(ZipEncoder().encode(archive));
  return file;
}

class _Routes implements ProviderTransport {
  const _Routes(this.routes);
  final Map<String, String> routes;
  @override
  Future<ProviderResponse> get(Uri uri) async => ProviderResponse(
    statusCode: routes.containsKey(uri.path) ? 200 : 404,
    body: routes[uri.path] ?? '',
    finalUri: uri,
  );
  @override
  void close() {}
}
