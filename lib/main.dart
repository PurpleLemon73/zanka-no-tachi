import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'canonical/domain/identifiers.dart';
import 'canonical/domain/media.dart';
import 'canonical/persistence/canonical_database.dart';
import 'canonical/persistence/canonical_database_connection.dart';
import 'live_provider/developer_sources_controller.dart';
import 'live_provider/live_provider_repository.dart';
import 'live_provider/provider_registry.dart';
import 'live_provider/provider_transport.dart';
import 'product/product_controller.dart';
import 'product/product_repository.dart';
import 'product/search_history_store.dart';
import 'product/ui/design_system.dart';
import 'product/ui/product_shell.dart';
import 'reader/local_reader_sources.dart';
import 'reader/reader_preferences_store.dart';
import 'reader/reader_repository.dart';
import 'reader/reader_source.dart';
import 'reader/sample_manga_installer.dart';
import 'player/local_playback_source.dart';
import 'player/playback_preferences_store.dart';
import 'player/playback_repository.dart';
import 'player/playback_source.dart';
import 'player/sample_anime_installer.dart';
import 'local_library/local_library_service.dart';
import 'local_library/backup_service.dart';
import 'adapter_platform/adapter_diagnostics.dart';
import 'adapter_platform/adapter_descriptor.dart';
import 'app/app_identity.dart';
import 'app/app_preferences.dart';
import 'app/local_diagnostics.dart';
import 'app/presentation_mode.dart';
import 'product/ui/about_screen.dart';
import 'product/ui/onboarding_screen.dart';
import 'live_media/live_media_transport.dart';
import 'live_media/mangaworld_reader_source.dart';
import 'live_media/animeworld_playback_source.dart';

const _showcaseSeedEnabled = bool.fromEnvironment('ZANKA_SHOWCASE');
const _showcaseTvEnabled = bool.fromEnvironment('ZANKA_SHOWCASE_TV');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final diagnostics = LocalDiagnostics();
  final previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (details) {
    unawaited(diagnostics.captureFlutterError(details));
    previousFlutterHandler?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(diagnostics.captureUncaught(error));
    return false;
  };
  await diagnostics.record(
    LocalLogLevel.info,
    'lifecycle',
    '${AppIdentity.displayName} ${AppIdentity.version}+${AppIdentity.buildNumber} started',
  );
  final presentationMode = _showcaseTvEnabled
      ? PresentationMode.tv
      : await const PresentationModeDetector().detect();
  runApp(
    ZankaApp(diagnostics: diagnostics, presentationMode: presentationMode),
  );
}

class ZankaApp extends StatefulWidget {
  const ZankaApp({
    super.key,
    this.repository,
    this.preferences,
    this.diagnostics,
    this.enableOnboarding,
    this.liveMediaTransport,
    this.presentationMode = PresentationMode.mobile,
  });
  final LiveProviderRepository? repository;
  final AppPreferencesStore? preferences;
  final LocalDiagnostics? diagnostics;
  final bool? enableOnboarding;
  final LiveMediaTransport? liveMediaTransport;
  final PresentationMode presentationMode;
  @override
  State<ZankaApp> createState() => _ZankaAppState();
}

class _ZankaAppState extends State<ZankaApp> {
  late final LiveProviderRepository repository;
  late final DeveloperSourcesController controller;
  late final ProductController productController;
  late final ReaderRepository readerRepository;
  late final PlaybackRepository playbackRepository;
  late final LocalLibraryService localLibraryService;
  late final bool ownsRepository;
  late final AppPreferencesStore preferences;
  late final LocalDiagnostics diagnostics;
  late final LiveMediaTransport liveMediaTransport;
  AppPreferences? appPreferences;

  @override
  void initState() {
    super.initState();
    ownsRepository = widget.repository == null;
    preferences = widget.preferences ?? AppPreferencesStore();
    diagnostics = widget.diagnostics ?? LocalDiagnostics();
    liveMediaTransport =
        widget.liveMediaTransport ??
        (ownsRepository
            ? HttpLiveMediaTransport()
            : _UnavailableLiveMediaTransport());
    repository =
        widget.repository ??
        LiveProviderRepository(
          registry: ProviderRegistry.defaults(),
          database: CanonicalDatabase(openCanonicalConnection()),
          transport: HttpProviderTransport(),
        );
    controller = DeveloperSourcesController(repository)..initialize();
    final readerPreferences = ReaderPreferencesStore();
    final playerPreferences = PlaybackPreferencesStore();
    readerRepository = ReaderRepository(
      database: repository.database,
      sources: ReaderSourceRegistry([
        MangaWorldReaderSource.fromRegistry(
          registry: repository.registry,
          transport: liveMediaTransport,
        ),
        const LocalFolderReaderSource(),
        const LocalFolderReaderSource(
          id: localFolderAlternateProviderId,
          displayName: 'Local folder alternate',
        ),
        const LocalCbzReaderSource(),
        const LocalCbzReaderSource(
          id: importedMangaProviderId,
          displayName: 'Imported CBZ',
        ),
      ]),
      preferencesStore: readerPreferences,
    );
    playbackRepository = PlaybackRepository(
      database: repository.database,
      sources: PlaybackSourceRegistry([
        AnimeWorldPlaybackSource.fromRegistry(
          registry: repository.registry,
          transport: liveMediaTransport,
        ),
        const LocalVideoPlaybackSource(localVideoProviderId, 'Local video'),
        const LocalVideoPlaybackSource(
          localVideoAlternateProviderId,
          'Local alternate encode',
        ),
        const LocalVideoPlaybackSource(
          importedVideoProviderId,
          'Imported video',
        ),
      ]),
      preferencesStore: playerPreferences,
    );
    repository.adapters.validateSourceRegistries(
      readerProviderIds: readerRepository.sources.providerIds,
      playbackProviderIds: playbackRepository.sources.providerIds,
    );
    localLibraryService = LocalLibraryService(repository.database);
    final backupService = ZankaBackupService(
      database: repository.database,
      readerPreferences: readerPreferences,
      playerPreferences: playerPreferences,
    );
    productController = ProductController(
      ProductRepository(
        repository,
        reader: readerRepository,
        playback: playbackRepository,
      ),
      sampleInstaller: SampleMangaInstaller(repository.database),
      sampleAnimeInstaller: SampleAnimeInstaller(repository.database),
      localLibrary: localLibraryService,
      backup: backupService,
      searchHistoryStore: ownsRepository
          ? SearchHistoryStore()
          : SearchHistoryStore.memory(),
    )..initialize();
    if (_showcaseSeedEnabled) unawaited(_installShowcaseSamples());
    if (widget.enableOnboarding ?? ownsRepository) {
      unawaited(_loadOnboarding());
    } else {
      appPreferences = const AppPreferences(onboardingComplete: true);
    }
  }

  Future<void> _installShowcaseSamples() async {
    await productController.sampleAnimeInstaller!.install();
    await productController.sampleInstaller!.install();
    await productController.refreshLocal();
  }

  Future<void> _loadOnboarding() async {
    var value = await preferences.load();
    if ((widget.presentationMode == PresentationMode.tv ||
            _showcaseSeedEnabled) &&
        !value.onboardingComplete) {
      await preferences.completeOnboarding();
      value = value.copyWith(onboardingComplete: true);
    }
    if (mounted) setState(() => appPreferences = value);
  }

  Future<void> _finishOnboarding() async {
    await preferences.completeOnboarding();
    if (mounted) {
      setState(
        () =>
            appPreferences = appPreferences?.copyWith(onboardingComplete: true),
      );
    }
  }

  Future<void> _setAppearance(
    ZankaThemeMode themeMode,
    ZankaAccent accent,
  ) async {
    await preferences.saveAppearance(themeMode: themeMode, accent: accent);
    if (mounted) {
      setState(
        () => appPreferences = (appPreferences ?? const AppPreferences())
            .copyWith(themeMode: themeMode, accent: accent),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    productController.dispose();
    liveMediaTransport.close();
    if (ownsRepository) unawaited(repository.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = appPreferences;
    return MaterialApp(
      title: AppIdentity.displayName,
      debugShowCheckedModeBanner: false,
      theme: zankaTheme(
        Brightness.light,
        accent: current?.accent ?? ZankaAccent.defaultRed,
      ),
      darkTheme: zankaTheme(
        Brightness.dark,
        accent: current?.accent ?? ZankaAccent.defaultRed,
      ),
      themeMode: switch (current?.themeMode ?? ZankaThemeMode.system) {
        ZankaThemeMode.system => ThemeMode.system,
        ZankaThemeMode.light => ThemeMode.light,
        ZankaThemeMode.dark => ThemeMode.dark,
      },
      home: current == null
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : current.onboardingComplete == false
          ? OnboardingScreen(onComplete: _finishOnboarding)
          : ProductShell(
              controller: productController,
              developerBuilder: (_) => DeveloperSourcesScreen(
                controller: controller,
                diagnostics: diagnostics,
              ),
              aboutBuilder: (_) => AboutZankaScreen(diagnostics: diagnostics),
              appearance: current,
              onAppearanceChanged: _setAppearance,
              presentationMode: widget.presentationMode,
            ),
    );
  }
}

class _UnavailableLiveMediaTransport implements LiveMediaTransport {
  @override
  Future<LiveMediaResponse> get(
    Uri uri, {
    Map<String, String> headers = const {},
  }) => Future.error(
    StateError('Live media transport is disabled in this composition.'),
  );

  @override
  void close() {}
}

class DeveloperSourcesScreen extends StatefulWidget {
  const DeveloperSourcesScreen({
    super.key,
    required this.controller,
    required this.diagnostics,
  });
  final DeveloperSourcesController controller;
  final LocalDiagnostics diagnostics;
  @override
  State<DeveloperSourcesScreen> createState() => _DeveloperSourcesScreenState();
}

class _DeveloperSourcesScreenState extends State<DeveloperSourcesScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Developer Sources'),
        bottom: widget.controller.busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'M3 validation harness — public metadata only',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...widget.controller.providers.map(
            (provider) => ProviderPanel(
              key: ValueKey('provider-${provider.id.value}'),
              provider: provider,
              health: widget.controller.health[provider.id],
              controller: widget.controller,
            ),
          ),
          const SizedBox(height: 16),
          SearchPanel(
            controller: widget.controller,
            textController: searchController,
          ),
          if (widget.controller.diagnostic case final diagnostic?) ...[
            const SizedBox(height: 12),
            SelectableText(diagnostic, key: const Key('diagnostic')),
          ],
          const SizedBox(height: 20),
          Text('Results', style: Theme.of(context).textTheme.titleLarge),
          ...widget.controller.results.map(
            (item) => ListTile(
              key: ValueKey(
                'result-${item.providerId.value}-${item.externalId}',
              ),
              title: Text(item.title),
              subtitle: Text(
                '${item.providerId.value} · ${item.externalId}'
                '${item.subtitle == null ? '' : ' · ${item.subtitle}'}',
              ),
              trailing: const Icon(Icons.download_for_offline_outlined),
              onTap: () => widget.controller.ingest(item),
            ),
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Persisted canonical media',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                key: const Key('reload-persisted'),
                tooltip: 'Reload persisted media',
                onPressed: widget.controller.reloadPersisted,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (widget.controller.persisted.isEmpty)
            const Text('No canonical items ingested yet.')
          else
            ...widget.controller.persisted.map(
              (media) => ListTile(
                key: ValueKey('persisted-${media.id.value}'),
                title: Text(media.title.value),
                subtitle: Text('${media.kind.name} · ${media.id.value}'),
                onTap: () => widget.controller.inspect(media.id),
              ),
            ),
          const Divider(height: 32),
          ReconciliationPanel(controller: widget.controller),
          if (widget.controller.inspection case final inspection?) ...[
            const Divider(height: 32),
            InspectionPanel(inspection: inspection),
          ],
          const Divider(height: 32),
          ListTile(
            key: const Key('open-adapter-diagnostics'),
            leading: const Icon(Icons.monitor_heart_outlined),
            title: const Text('Adapter Diagnostics'),
            subtitle: const Text(
              'Capabilities, configuration and bounded reliability history.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AdapterDiagnosticsScreen(
                  repository: widget.controller.repository,
                  diagnostics: widget.diagnostics,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class AdapterDiagnosticsScreen extends StatelessWidget {
  const AdapterDiagnosticsScreen({
    super.key,
    required this.repository,
    required this.diagnostics,
  });
  final LiveProviderRepository repository;
  final LocalDiagnostics diagnostics;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Adapter Diagnostics')),
    body: FutureBuilder<List<AdapterDiagnosticEntry>>(
      future: AdapterDiagnosticsService(repository).snapshot(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Bounded snapshot only. Zanka does not poll adapters in the background.',
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<DiagnosticRecord>>(
              future: diagnostics.records(),
              builder: (context, logs) => ListTile(
                leading: const Icon(Icons.bug_report_outlined),
                title: Text(
                  '${logs.data?.length ?? 0} local diagnostic record(s)',
                ),
                subtitle: const Text(
                  'Redacted, bounded and never sent automatically.',
                ),
                trailing: Wrap(
                  children: [
                    IconButton(
                      tooltip: 'Copy redacted diagnostics',
                      onPressed: () async => Clipboard.setData(
                        ClipboardData(text: await diagnostics.redactedReport()),
                      ),
                      icon: const Icon(Icons.copy),
                    ),
                    IconButton(
                      tooltip: 'Clear diagnostics',
                      onPressed: diagnostics.clear,
                      icon: const Icon(Icons.delete_sweep_outlined),
                    ),
                  ],
                ),
              ),
            ),
            for (final entry in snapshot.data!)
              ExpansionTile(
                key: ValueKey('adapter-${entry.descriptor.id.value}'),
                title: Text(entry.descriptor.displayName),
                subtitle: Text(
                  '${entry.descriptor.scope.name} · ${AdapterStatus.ready.name}',
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Capabilities: ${entry.descriptor.capabilities.map((value) => value.name).join(', ')}',
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enabled: ${entry.configuration?.enabled ?? 'runtime default'} · '
                      'Authority: ${_sanitizedAuthority(entry.configuration?.baseUrl)}',
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pagination: ${entry.paginationEnabled ? 'user-driven' : 'none'} · '
                      'Last checked: ${entry.reliability?.lastCheckedAt ?? 'never'} · '
                      'Failures: ${entry.reliability?.consecutiveFailures ?? 0}',
                    ),
                  ),
                  if (entry.reliability?.lastParserMismatchAt case final at?)
                    Text('Last parser mismatch: $at'),
                  if (entry.liveManifest case final manifest?)
                    Text(
                      [
                        'Media manifest: ${manifest.state.name}',
                        'type: ${manifest.mediaType ?? 'not observed'}',
                        'last success: ${manifest.lastSuccessAt ?? 'never'}',
                        'last failure: ${manifest.lastFailureAt ?? 'never'}',
                        'failure class: ${manifest.failureClass ?? 'none'}',
                        'parser drift: ${manifest.lastParserMismatchAt ?? 'never'}',
                        'fresh retry recovered: ${manifest.freshRetryRecovered ? 'yes' : 'no'}',
                        manifest.summary ?? 'Open an installment to validate',
                      ].join(' · '),
                    ),
                  if (entry.reliability?.lastError case final error?)
                    SelectableText('Last error: $error'),
                ],
              ),
          ],
        );
      },
    ),
  );
}

String _sanitizedAuthority(Uri? uri) {
  if (uri == null) return 'local / runtime default';
  return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
}

class ReconciliationPanel extends StatelessWidget {
  const ReconciliationPanel({super.key, required this.controller});
  final DeveloperSourcesController controller;

  @override
  Widget build(BuildContext context) => Card(
    key: const Key('reconciliation-panel'),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reviewed canonical reconciliation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'The source identity is retired; the explicitly selected target survives. '
            'Title similarity only proposes review.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('seed-m3-scenarios'),
            onPressed: controller.seedSyntheticScenarios,
            icon: const Icon(Icons.science_outlined),
            label: const Text('Seed synthetic M3 scenarios'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<CanonicalMediaId>(
            key: ValueKey('merge-source-${controller.mergeSourceId?.value}'),
            initialValue: controller.mergeSourceId,
            items: controller.persisted
                .map(
                  (media) => DropdownMenuItem(
                    value: media.id,
                    child: Text('${media.title.value} · ${media.id.value}'),
                  ),
                )
                .toList(),
            onChanged: controller.selectMergeSource,
            decoration: const InputDecoration(labelText: 'Source ID to retire'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<CanonicalMediaId>(
            key: ValueKey('merge-target-${controller.mergeTargetId?.value}'),
            initialValue: controller.mergeTargetId,
            items: controller.persisted
                .map(
                  (media) => DropdownMenuItem(
                    value: media.id,
                    child: Text('${media.title.value} · ${media.id.value}'),
                  ),
                )
                .toList(),
            onChanged: controller.selectMergeTarget,
            decoration: const InputDecoration(labelText: 'Surviving target ID'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                key: const Key('show-candidates'),
                onPressed: controller.showCandidates,
                child: const Text('Show candidates'),
              ),
              FilledButton(
                key: const Key('reviewed-merge'),
                onPressed: controller.mergeSelected,
                child: const Text('Reviewed merge'),
              ),
              OutlinedButton(
                key: const Key('undo-merge'),
                onPressed: controller.lastMerge == null
                    ? null
                    : controller.undoLastMerge,
                child: const Text('Undo last merge'),
              ),
            ],
          ),
          ...controller.candidates.map(
            (candidate) => ListTile(
              key: ValueKey('candidate-${candidate.rightId.value}'),
              title: Text(
                '${candidate.rightId.value} · ${candidate.confidence.name}',
              ),
              subtitle: Text(
                candidate.evidence.map((item) => item.description).join(' · '),
              ),
              trailing: candidate.requiresReview
                  ? const Icon(Icons.rate_review_outlined)
                  : null,
            ),
          ),
        ],
      ),
    ),
  );
}

class ProviderPanel extends StatefulWidget {
  const ProviderPanel({
    super.key,
    required this.provider,
    required this.health,
    required this.controller,
  });
  final ProviderConfig provider;
  final ProviderHealth? health;
  final DeveloperSourcesController controller;
  @override
  State<ProviderPanel> createState() => _ProviderPanelState();
}

class _ProviderPanelState extends State<ProviderPanel> {
  late final TextEditingController urlController;
  @override
  void initState() {
    super.initState();
    urlController = TextEditingController(
      text: widget.provider.baseUrl.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ProviderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider.baseUrl != widget.provider.baseUrl) {
      urlController.text = widget.provider.baseUrl.toString();
    }
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(widget.provider.displayName),
            subtitle: Text(
              '${widget.provider.mediaKind.name} · '
              '${widget.health?.state.name ?? 'not checked'}',
              key: ValueKey('health-${widget.provider.id.value}'),
            ),
            value: widget.provider.enabled,
            onChanged: (value) =>
                widget.controller.setEnabled(widget.provider.id, value),
          ),
          TextField(
            key: ValueKey('base-url-${widget.provider.id.value}'),
            controller: urlController,
            decoration: const InputDecoration(
              labelText: 'Configured base URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                key: ValueKey('apply-url-${widget.provider.id.value}'),
                onPressed: () => widget.controller.configureBaseUrl(
                  widget.provider.id,
                  urlController.text,
                ),
                child: const Text('Apply URL'),
              ),
              FilledButton.tonal(
                key: ValueKey('check-${widget.provider.id.value}'),
                onPressed: widget.provider.enabled
                    ? () => widget.controller.check(widget.provider.id)
                    : null,
                child: const Text('Check'),
              ),
              FilledButton.tonal(
                key: ValueKey('catalog-${widget.provider.id.value}'),
                onPressed: widget.provider.enabled
                    ? () => widget.controller.loadCatalog(widget.provider.id)
                    : null,
                child: const Text('Catalog'),
              ),
            ],
          ),
          if (widget.health?.diagnostic case final diagnostic?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(diagnostic),
            ),
        ],
      ),
    ),
  );
}

class SearchPanel extends StatelessWidget {
  const SearchPanel({
    super.key,
    required this.controller,
    required this.textController,
  });
  final DeveloperSourcesController controller;
  final TextEditingController textController;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DropdownButtonFormField<ProviderId>(
        key: const Key('provider-selector'),
        initialValue: controller.selectedProvider,
        items: controller.providers
            .map(
              (provider) => DropdownMenuItem(
                value: provider.id,
                child: Text(provider.displayName),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) controller.selectProvider(value);
        },
        decoration: const InputDecoration(labelText: 'Search provider'),
      ),
      const SizedBox(height: 8),
      TextField(
        key: const Key('developer-search-field'),
        controller: textController,
        decoration: InputDecoration(
          labelText: 'Public catalog query',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            key: const Key('developer-search'),
            tooltip: 'Search',
            onPressed: () => controller.search(textController.text),
            icon: const Icon(Icons.search),
          ),
        ),
        onSubmitted: controller.search,
      ),
    ],
  );
}

class InspectionPanel extends StatelessWidget {
  const InspectionPanel({super.key, required this.inspection});
  final CanonicalMediaInspection inspection;

  @override
  Widget build(BuildContext context) {
    final media = inspection.media;
    final format = media is CanonicalAnime ? media.format.name : 'manga';
    return Card(
      key: const Key('detail-inspection'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              media.title.value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SelectableText('Canonical ID: ${media.id.value}'),
            if (inspection.followedAlias)
              Text(
                'Alias: ${inspection.requestedId!.value} → ${media.id.value}',
                key: const Key('alias-resolution'),
              ),
            Text('Kind/format: ${media.kind.name} / $format'),
            Text('Status: ${media.status.name}'),
            Text(
              'Title provenance: ${media.title.provenance.providerId.value}',
            ),
            Text('Cover: ${media.coverLocator ?? 'unknown'}'),
            Text('Chapters: ${inspection.chapters.length}'),
            Text('Episodes: ${inspection.episodes.length}'),
            const SizedBox(height: 8),
            ...inspection.bindings.map(
              (binding) => Text(
                'Binding: ${binding.providerId.value} / '
                '${binding.externalId} → '
                '${binding.relativeLocator ?? 'no locator'}',
              ),
            ),
            ...inspection.chapterAvailability.map(
              (item) => Text(
                'Chapter ${item.chapter.number.rawLabel}: '
                '${item.sourceBindings.map((binding) => binding.providerId.value).join(', ')}',
              ),
            ),
            ...inspection.episodeAvailability.map(
              (item) => Text(
                'Episode ${item.episode.label.rawLabel}: '
                '${item.sourceBindings.map((binding) => binding.providerId.value).join(', ')}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
