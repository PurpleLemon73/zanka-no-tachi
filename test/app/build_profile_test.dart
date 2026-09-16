import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zanka_no_tachi/app/build_profile.dart';
import 'package:zanka_no_tachi/app/local_diagnostics.dart';
import 'package:zanka_no_tachi/app/presentation_mode.dart';
import 'package:zanka_no_tachi/canonical/domain/bindings.dart';
import 'package:zanka_no_tachi/canonical/domain/identifiers.dart';
import 'package:zanka_no_tachi/canonical/domain/installments.dart';
import 'package:zanka_no_tachi/canonical/domain/media.dart';
import 'package:zanka_no_tachi/canonical/domain/user_state.dart';
import 'package:zanka_no_tachi/canonical/persistence/canonical_database.dart';
import 'package:zanka_no_tachi/live_provider/live_provider_repository.dart';
import 'package:zanka_no_tachi/live_provider/provider_registry.dart';
import 'package:zanka_no_tachi/live_provider/provider_transport.dart';
import 'package:zanka_no_tachi/main.dart';
import 'package:zanka_no_tachi/player/default_playback_engine_registry.dart';
import 'package:zanka_no_tachi/player/playback_engine.dart';
import 'package:zanka_no_tachi/player/playback_domain.dart';
import 'package:zanka_no_tachi/player/playback_preferences_store.dart';
import 'package:zanka_no_tachi/player/sample_anime_installer.dart';
import 'package:zanka_no_tachi/player/ui/playback_engine_preference_selector.dart';
import 'package:zanka_no_tachi/product/product_controller.dart';
import 'package:zanka_no_tachi/product/product_repository.dart';
import 'package:zanka_no_tachi/product/ui/about_screen.dart';
import 'package:zanka_no_tachi/product/ui/details_actions.dart';
import 'package:zanka_no_tachi/product/ui/product_shell.dart';
import 'package:zanka_no_tachi/reader/sample_manga_installer.dart';

const _development = BuildProfile.current == BuildProfile.development;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('compile-time profile and fail-closed defaults are deterministic', () {
    expect(BuildProfile.parse('development'), BuildProfile.development);
    for (final value in [null, '', 'production', 'Development', 'invalid']) {
      expect(BuildProfile.parse(value), BuildProfile.production);
    }
    expect(BuildProfile.current, BuildProfile.parse(appFlavor));
    expect(BuildProfile.current.allowsDemoContent, _development);
    expect(BuildProfile.current.allowsDeveloperTools, _development);
    expect(BuildProfile.current.allowsExperimentalEngines, _development);
    expect(BuildProfile.current.allowsLocalDiagnostics, _development);
    expect(
      BuildProfile.seedShowcase,
      _development && const bool.fromEnvironment('ZANKA_SHOWCASE'),
    );
    expect(
      BuildProfile.forceShowcaseTv,
      _development && const bool.fromEnvironment('ZANKA_SHOWCASE_TV'),
    );
  });

  test('flavor asset bundle includes showcase only for development', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();
    for (final prefix in [
      'assets/sample_anime/',
      'assets/showcase/ashen_blade/',
      'assets/showcase/nova_pulse/',
    ]) {
      expect(
        assets.any((asset) => asset.startsWith(prefix)),
        _development,
        reason: prefix,
      );
    }
  });

  for (final mode in PresentationMode.values) {
    testWidgets('${mode.name} bootstrap and Settings obey compiled profile', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = mode == PresentationMode.tv
          ? const Size(1280, 720)
          : mode == PresentationMode.tablet
          ? const Size(800, 1100)
          : const Size(390, 844);
      addTearDown(tester.view.reset);
      final repository = _repository();
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await repository.dispose();
      });
      await tester.pumpWidget(
        ZankaApp(repository: repository, presentationMode: mode),
      );
      await tester.pumpAndSettle();
      final product = tester
          .widget<ProductShell>(find.byType(ProductShell))
          .controller;
      expect(product.sampleInstaller != null, _development);
      expect(product.sampleAnimeInstaller != null, _development);
      expect(product.localLibrary, isNotNull);
      expect(product.backup, isNotNull);
      expect(
        product.repository.reader!.sources.providerIds,
        contains(const ProviderId('mangaworld')),
      );
      expect(
        product.repository.playback!.sources.providerIds,
        contains(const ProviderId('animeworld')),
      );
      expect(await repository.database.allMedia(), isEmpty);
      for (final tab in ['home', 'search', 'library', 'settings']) {
        await tester.tap(find.byKey(Key('nav-$tab')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await _tap(tester, find.byKey(const Key('settings-sources')));
      expect(
        find.byKey(const Key('setting-provider-mangaworld')),
        findsOneWidget,
      );
      await _tap(tester, find.byKey(const Key('source-address-mangaworld')));
      await tester.enterText(
        find.byKey(const Key('source-address-input')),
        'not a URL',
      );
      await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('source-address-input')),
        'https://catalog.invalid/',
      );
      await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        repository.registry
            .require(const ProviderId('mangaworld'))
            .baseUrl
            .host,
        'catalog.invalid',
      );
      await repository.loadPersistedProviderConfiguration();
      expect(
        repository.registry
            .require(const ProviderId('mangaworld'))
            .baseUrl
            .host,
        'catalog.invalid',
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      if (mode != PresentationMode.tv) {
        expect(
          find.byKey(const Key('settings-samples')),
          _development ? findsOneWidget : findsNothing,
        );
        expect(find.byKey(const Key('open-local-media')), findsOneWidget);
      }
      final about = find.byKey(const Key('open-about'));
      await tester.ensureVisible(about);
      await tester.pumpAndSettle();
      if (mode != PresentationMode.tv) {
        await tester.longPress(about);
        await tester.pumpAndSettle();
      }
      expect(
        find.byKey(const Key('open-developer-tools')),
        _development ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('ADVANCED'),
        _development && mode != PresentationMode.tv
            ? findsOneWidget
            : findsNothing,
      );
      // With no hidden long-press handler, InkWell may resolve this as About's
      // normal tap. It must never enable a development section in production.
      if (find.byType(AboutZankaScreen).evaluate().isEmpty) {
        await _tap(tester, about);
      }
      expect(find.text('Open-source licenses'), findsOneWidget);
      expect(
        find.byKey(const Key('copy-diagnostics')),
        _development ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'production has no diagnostics reads or experimental selector side effects',
    (tester) async {
      final logs = _Diagnostics();
      await tester.pumpWidget(
        MaterialApp(home: AboutZankaScreen(diagnostics: logs)),
      );
      await tester.pumpAndSettle();
      expect(logs.reads > 0, _development);
      expect(
        find.text('Local diagnostics'),
        _development ? findsOneWidget : findsNothing,
      );
      final preferences = _Preferences();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaybackEnginePreferenceSelector(
              preferencesStore: preferences,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(preferences.reads, _development ? 1 : 0);
      expect(preferences.writes, 0);
      expect(
        find.byKey(PlaybackEnginePreferenceSelector.selectorKey),
        _development ? findsOneWidget : findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'production ignores stale experiment preference without fallback labels',
    () async {
      final registry = defaultPlaybackEngineRegistry();
      final automatic = registry.create();
      expect(automatic.engine.kind, PlaybackEngineKind.videoPlayer);
      await automatic.engine.dispose();
      if (!_development) {
        expect(registry.betterPlayerExperimentalBuilder, isNull);
        final selected = registry.create(
          PlaybackEnginePreference.betterPlayerExperimental,
        );
        expect(selected.engine.kind, PlaybackEngineKind.videoPlayer);
        expect(selected.fallbackReason, isNull);
        await selected.engine.dispose();
      }
    },
  );

  testWidgets('Details retains real editing but gates demo menu entries', (
    tester,
  ) async {
    final repository = _repository();
    final product = ProductController(ProductRepository(repository));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      product.dispose();
      await repository.dispose();
    });
    const id = CanonicalMediaId('own-work');
    await repository.database.saveMedia(
      const CanonicalAnime(
        id: id,
        format: AnimeFormat.movie,
        title: SourcedValue(
          value: 'My home animation',
          provenance: FieldProvenance(
            providerId: ProviderId('local-import-video'),
          ),
        ),
      ),
    );
    final details = (await product.repository.details(id))!;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DetailsActions(
            controller: product,
            details: details,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('edit-metadata')));
    expect(find.byType(Dialog), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('metadata-title')),
      'My edited animation',
    );
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('metadata-save')));
    expect(find.byType(Dialog), findsNothing);
    expect(
      (await repository.database.effectiveMedia(id))!.title.value,
      'My edited animation',
    );
    await _tap(tester, find.byKey(const Key('details-more-actions')));
    expect(find.text('Reset title'), findsOneWidget);
    expect(
      find.byKey(const Key('enrich-metadata')),
      _development ? findsOneWidget : findsNothing,
    );
    expect(
      find.byType(PopupMenuDivider),
      _development ? findsOneWidget : findsNothing,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(await repository.database.allMedia(), hasLength(1));
  });

  test('demo install entry points work only in development', () async {
    final repository = _repository();
    final root = await Directory.systemTemp.createTemp('zanka-profile-');
    final product = ProductController(
      ProductRepository(repository),
      sampleInstaller: SampleMangaInstaller(
        repository.database,
        root: Directory('${root.path}/manga'),
      ),
      sampleAnimeInstaller: SampleAnimeInstaller(
        repository.database,
        root: Directory('${root.path}/anime'),
      ),
    );
    addTearDown(() async {
      product.dispose();
      await repository.dispose();
      await root.delete(recursive: true);
    });
    expect(
      await product.installSampleManga(),
      _development ? sampleMangaId : null,
    );
    expect(
      await product.installSampleAnime(),
      _development ? sampleAnimeId : null,
    );
    expect(
      await repository.database.allMedia(),
      hasLength(_development ? 2 : 0),
    );
    if (!_development) expect(await root.list().toList(), isEmpty);
  });

  test(
    'production projections preserve user data and reviewed real-source merges',
    () async {
      final repository = _repository();
      final db = repository.database;
      addTearDown(repository.dispose);
      const mediaId = CanonicalMediaId('user-owned-manga');
      const chapterId = CanonicalChapterId('user-chapter');
      const provider = ProviderId('local-import-manga');
      const provenance = FieldProvenance(providerId: provider);
      final now = DateTime.utc(2026);
      await db.saveMedia(
        const CanonicalManga(
          id: mediaId,
          title: SourcedValue(
            value: 'My original comic',
            provenance: provenance,
          ),
        ),
      );
      await db.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: mediaId,
          providerId: provider,
          externalId: 'owned-comic',
        ),
      );
      await db.saveChapter(
        CanonicalChapter(
          id: chapterId,
          mediaId: mediaId,
          number: ChapterNumber.parse('1'),
        ),
      );
      await db.saveChapterBinding(
        const ChapterSourceBinding(
          canonicalId: chapterId,
          providerId: provider,
          externalId: 'scan',
        ),
      );
      await db.saveLibraryEntry(
        CanonicalLibraryEntry(
          mediaId: mediaId,
          isSaved: true,
          isFavorite: true,
          status: CanonicalLibraryStatus.inProgress,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await db.saveMangaProgress(
        CanonicalMangaProgress(
          mediaId: mediaId,
          chapterId: chapterId,
          pageIndex: 2,
          updatedAt: now,
        ),
      );
      await db.saveMangaSourcePageResume(
        MangaSourcePageResume(
          mediaId: mediaId,
          chapterId: chapterId,
          providerId: provider,
          chapterExternalId: 'scan',
          pageIndex: 2,
          updatedAt: now,
        ),
      );
      await db.saveMedia(
        const CanonicalManga(
          id: sampleMangaId,
          title: SourcedValue(
            value: 'Previously installed showcase',
            provenance: provenance,
          ),
        ),
      );
      await db.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: sampleMangaId,
          providerId: ProviderId('local-folder'),
          externalId: 'zanka-sample-folder',
        ),
      );
      final product = ProductRepository(repository);
      final summaries = await product.persisted();
      expect(summaries.map((item) => item.media.id), contains(mediaId));
      expect(
        summaries.any((item) => item.media.id == sampleMangaId),
        _development,
      );
      expect(await product.details(mediaId), isNotNull);
      expect(
        await product.details(sampleMangaId),
        _development ? isNotNull : isNull,
      );
      expect(await db.allMedia(), hasLength(2));
      expect((await db.libraryEntry(mediaId))!.isFavorite, isTrue);
      expect((await db.mangaProgress(mediaId))!.pageIndex, 2);
      expect((await db.mangaSourcePageResume(provider, 'scan'))!.pageIndex, 2);
      // A reviewed merge may retain a sample ID. Never hide its real binding.
      await db.saveMediaBinding(
        const MediaSourceBinding(
          canonicalId: sampleMangaId,
          providerId: provider,
          externalId: 'real-merged-copy',
        ),
      );
      expect(
        (await product.persisted()).map((item) => item.media.id),
        contains(sampleMangaId),
      );
      expect(await product.details(sampleMangaId), isNotNull);
      await product.enrichWithDeterministicProof(mediaId);
      if (!_development) {
        expect((await db.effectiveMedia(mediaId))!.alternateTitles, isEmpty);
      }
    },
  );
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

LiveProviderRepository _repository() => LiveProviderRepository(
  database: CanonicalDatabase(NativeDatabase.memory()),
  registry: ProviderRegistry.defaults(),
  transport: _Offline(),
);

class _Offline implements ProviderTransport {
  @override
  Future<ProviderResponse> get(Uri uri) async =>
      throw const SocketException('offline profile fixture');
  @override
  void close() {}
}

class _Diagnostics extends LocalDiagnostics {
  int reads = 0;
  @override
  Future<List<DiagnosticRecord>> records() async {
    reads++;
    return [];
  }
}

class _Preferences extends PlaybackPreferencesStore {
  int reads = 0;
  int writes = 0;
  @override
  Future<PlaybackPreferences> load() async {
    reads++;
    return const PlaybackPreferences(
      enginePreference: PlaybackEnginePreference.betterPlayerExperimental,
    );
  }

  @override
  Future<void> save(PlaybackPreferences value) async {
    writes++;
  }
}
