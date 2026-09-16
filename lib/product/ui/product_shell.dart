import 'package:flutter/material.dart';

import '../../canonical/domain/identifiers.dart';
import '../../canonical/domain/media.dart';
import '../../canonical/domain/user_state.dart';
import '../product_controller.dart';
import '../product_models.dart';
import 'design_system.dart';
import 'content_visuals.dart';
import 'product_navigation.dart';
import 'media_details_screen.dart';
import 'local_media_screen.dart';
import 'settings_visuals.dart';
import 'source_settings_page.dart';
import '../../app/app_preferences.dart';
import '../../app/build_profile.dart';
import '../smart_resume.dart';
import '../../app/presentation_mode.dart';
import '../../tv/tv_product_shell.dart';

class ProductShell extends StatelessWidget {
  const ProductShell({
    super.key,
    required this.controller,
    required this.developerBuilder,
    required this.aboutBuilder,
    required this.appearance,
    required this.onAppearanceChanged,
    this.presentationMode = PresentationMode.mobile,
  });
  final ProductController controller;
  final WidgetBuilder developerBuilder;
  final WidgetBuilder aboutBuilder;
  final AppPreferences appearance;
  final Future<void> Function(ZankaThemeMode, ZankaAccent) onAppearanceChanged;
  final PresentationMode presentationMode;

  @override
  Widget build(BuildContext context) {
    if (presentationMode == PresentationMode.tv) {
      return AnimatedBuilder(
        animation: controller,
        builder: (context, _) => TvProductShell(
          controller: controller,
          developerBuilder: developerBuilder,
          aboutBuilder: aboutBuilder,
          appearance: appearance,
          onAppearanceChanged: onAppearanceChanged,
        ),
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final pages = <Widget>[
          HomeScreen(controller: controller),
          SearchScreen(controller: controller),
          LibraryScreen(controller: controller),
          SettingsScreen(
            controller: controller,
            developerBuilder: developerBuilder,
            aboutBuilder: aboutBuilder,
            appearance: appearance,
            onAppearanceChanged: onAppearanceChanged,
          ),
        ];
        final content = SafeArea(
          child: IndexedStack(index: controller.selectedTab, children: pages),
        );
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 840) {
              return Scaffold(
                body: Row(
                  children: [
                    SafeArea(
                      child: ZankaNavigation(
                        key: const Key('product-primary-navigation'),
                        vertical: true,
                        selectedIndex: controller.selectedTab,
                        onSelected: controller.selectTab,
                      ),
                    ),
                    Expanded(child: content),
                  ],
                ),
              );
            }
            return Scaffold(
              body: content,
              bottomNavigationBar: ZankaNavigation(
                key: const Key('product-primary-navigation'),
                selectedIndex: controller.selectedTab,
                onSelected: controller.selectTab,
              ),
            );
          },
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});
  final ProductController controller;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () async {
      await controller.refreshLocal();
      await controller.refreshDiscover();
    },
    child: CustomScrollView(
      key: const PageStorageKey('home-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: ZankaPageHeading(
              eyebrow: 'Zanka no Tachi',
              title: 'Your stories.',
              description: 'Manga to read. Anime to watch.',
              trailing: IconButton.filledTonal(
                tooltip: 'Search',
                onPressed: () => controller.selectTab(1),
                icon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),
        if (controller.loadingLocal)
          const SliverToBoxAdapter(child: LinearProgressIndicator())
        else ...[
          if (controller.continueItems.isNotEmpty)
            SliverToBoxAdapter(child: _ContinueStories(controller: controller)),
          SliverToBoxAdapter(
            child: StorySection(
              'Your Library',
              action: TextButton(
                onPressed: () => controller.selectTab(2),
                child: const Text('View all'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: controller.library.isEmpty
                ? StoryNotice(
                    title: 'Your library starts here',
                    message:
                        'Find a manga or anime you love. Save it here so it is easy to return to.',
                    action: FilledButton.icon(
                      onPressed: () => controller.selectTab(1),
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Find media'),
                    ),
                  )
                : _HorizontalSummaries(
                    items: controller.library.take(8).toList(),
                    controller: controller,
                  ),
          ),
          if (controller.persisted.isNotEmpty) ...[
            const SliverToBoxAdapter(child: StorySection('On this device')),
            SliverToBoxAdapter(
              child: _HorizontalSummaries(
                items: controller.persisted.take(8).toList(),
                controller: controller,
              ),
            ),
          ],
        ],
        const SliverToBoxAdapter(child: StorySection('Discover Manga')),
        SliverToBoxAdapter(
          child: _DiscoverSection(
            loading: controller.loadingDiscover,
            items: controller.discoverManga,
            controller: controller,
            emptyMessage:
                'Manga discovery is unavailable. Your local library still works.',
          ),
        ),
        const SliverToBoxAdapter(child: StorySection('Discover Anime')),
        SliverToBoxAdapter(
          child: _DiscoverSection(
            loading: controller.loadingDiscover,
            items: controller.discoverAnime,
            controller: controller,
            emptyMessage:
                'Anime discovery is unavailable. Your local library still works.',
          ),
        ),
        if (controller.discoverFailures.isNotEmpty)
          SliverToBoxAdapter(
            child: StoryNotice(
              title: 'Some sources are unavailable',
              message: controller.discoverFailures.values.toSet().join(' '),
              icon: Icons.cloud_off_outlined,
              action: TextButton.icon(
                onPressed: controller.refreshDiscover,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry discovery'),
              ),
            ),
          ),
        if (controller.discoverCursors.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: OutlinedButton.icon(
                key: const Key('discover-load-more'),
                onPressed: controller.loadingMoreDiscover
                    ? null
                    : controller.loadMoreDiscover,
                icon: controller.loadingMoreDiscover
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more),
                label: const Text('Load more discovery'),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    ),
  );
}

class _ContinueStories extends StatelessWidget {
  const _ContinueStories({required this.controller});
  final ProductController controller;
  @override
  Widget build(BuildContext context) {
    final groups = [
      for (final kind in CanonicalMediaKind.values)
        controller.continueItems
            .where((item) => item.media.kind == kind)
            .toList(),
    ].where((items) => items.isNotEmpty).toList();
    Widget group(List<ProductMediaSummary> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StorySection(
          items.first.media.kind == CanonicalMediaKind.manga
              ? 'Continue reading'
              : 'Continue watching',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: StoryFeature(
            item: items.first,
            actionKey: ValueKey('home-${items.first.media.id.value}'),
            label:
                controller.smartResumeFor(items.first.media.id)?.label ??
                'Open details',
            detail: _progressLabel(items.first),
            onOpen: () =>
                _openDetails(context, controller, items.first.media.id),
          ),
        ),
        if (items.length > 1)
          _HorizontalSummaries(
            items: items.skip(1).toList(),
            controller: controller,
            showProgress: true,
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900 && groups.length == 2) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: groups
                .map((items) => Expanded(child: group(items)))
                .toList(),
          );
        }
        return Column(children: groups.map(group).toList());
      },
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.controller});
  final ProductController controller;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController textController;
  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.controller.searchQuery);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: const PageStorageKey('search-scroll'),
    slivers: [
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: ZankaPageHeading(
            eyebrow: 'Find your next story',
            title: 'Search',
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBar(
                key: const Key('product-search-field'),
                controller: textController,
                hintText: 'Search manga and anime',
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.surfaceContainerHigh,
                ),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 16),
                ),
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (textController.text.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        textController.clear();
                        widget.controller.scheduleSearch('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
                ],
                onChanged: widget.controller.scheduleSearch,
                onSubmitted: widget.controller.submitSearch,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: CanonicalMediaKind.values
                    .map(
                      (kind) => FilterChip(
                        key: ValueKey('scope-${kind.name}'),
                        label: Text(
                          kind == CanonicalMediaKind.manga ? 'Manga' : 'Anime',
                        ),
                        selected: widget.controller.searchKinds.contains(kind),
                        onSelected: (enabled) =>
                            widget.controller.setSearchKind(kind, enabled),
                      ),
                    )
                    .toList(),
              ),
              if (widget.controller.searching)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      if (widget.controller.searchFailures.isNotEmpty)
        SliverToBoxAdapter(
          child: StoryNotice(
            icon: Icons.cloud_off_outlined,
            title: 'Some sources could not be searched',
            compact: widget.controller.searchResults.isNotEmpty,
            message: widget.controller.searchResults.isEmpty
                ? widget.controller.searchFailures.values.toSet().join(' ')
                : 'Showing available results. Your saved collection is unchanged.',
            action: TextButton.icon(
              onPressed: () =>
                  widget.controller.submitSearch(textController.text),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry search'),
            ),
          ),
        ),
      if (widget.controller.searchQuery.isEmpty) ...[
        if (widget.controller.recentSearches.isEmpty)
          const SliverToBoxAdapter(
            child: StoryNotice(
              title: 'A title. A new beginning.',
              message: 'Search for manga or anime across your enabled sources.',
              icon: Icons.travel_explore_rounded,
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent searches',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      TextButton(
                        onPressed: widget.controller.clearRecentSearches,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  for (final query in widget.controller.recentSearches)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history_rounded),
                      title: Text(
                        query,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.north_west_rounded),
                      onTap: () {
                        textController.text = query;
                        widget.controller.submitSearch(query);
                      },
                    ),
                ],
              ),
            ),
          ),
      ] else if (!widget.controller.searching &&
          widget.controller.searchResults.isEmpty &&
          widget.controller.searchFailures.isEmpty)
        const SliverToBoxAdapter(
          child: StoryNotice(
            title: 'No results',
            message: 'Try another title or enable another media scope.',
            icon: Icons.search_off,
          ),
        )
      else if (widget.controller.searchResults.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: StorySection(
            '${widget.controller.searchResults.length} titles',
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: StorySliverGrid(
            itemCount: widget.controller.searchResults.length,
            itemBuilder: (context, index) => _SearchResultCard(
              result: widget.controller.searchResults[index],
              controller: widget.controller,
            ),
          ),
        ),
      ],
      if (widget.controller.searchCursors.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: OutlinedButton.icon(
              key: const Key('search-load-more'),
              onPressed: widget.controller.loadingMoreSearch
                  ? null
                  : widget.controller.loadMoreSearch,
              icon: widget.controller.loadingMoreSearch
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more),
              label: const Text('Load more results'),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ],
  );
}

enum LibrarySort { title, updated }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.controller});
  final ProductController controller;
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  CanonicalMediaKind? kind;
  CanonicalLibraryStatus? status;
  bool favoritesOnly = false;
  LibrarySort sort = LibrarySort.updated;

  @override
  Widget build(BuildContext context) {
    final items =
        widget.controller.library.where((item) {
          if (kind != null && item.media.kind != kind) return false;
          if (status != null && item.library?.status != status) return false;
          if (favoritesOnly && !item.isFavorite) return false;
          return true;
        }).toList()..sort(
          (a, b) => sort == LibrarySort.title
              ? a.media.title.value.toLowerCase().compareTo(
                  b.media.title.value.toLowerCase(),
                )
              : (b.library?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                    .compareTo(
                      a.library?.updatedAt ??
                          DateTime.fromMillisecondsSinceEpoch(0),
                    ),
        );
    return CustomScrollView(
      key: const PageStorageKey('library-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: ZankaPageHeading(
              eyebrow: 'Your collection',
              title: 'Library',
              description: '${items.length} titles in this view',
              trailing: PopupMenuButton<LibrarySort>(
                tooltip: 'Sort library',
                initialValue: sort,
                onSelected: (value) => setState(() => sort = value),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: LibrarySort.updated,
                    child: Text('Recently updated'),
                  ),
                  PopupMenuItem(value: LibrarySort.title, child: Text('Title')),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: kind == null && status == null && !favoritesOnly,
                  onSelected: (_) => setState(() {
                    kind = null;
                    status = null;
                    favoritesOnly = false;
                  }),
                ),
                ChoiceChip(
                  label: const Text('Manga'),
                  selected: kind == CanonicalMediaKind.manga,
                  onSelected: (_) => setState(
                    () => kind = kind == CanonicalMediaKind.manga
                        ? null
                        : CanonicalMediaKind.manga,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Anime'),
                  selected: kind == CanonicalMediaKind.anime,
                  onSelected: (_) => setState(
                    () => kind = kind == CanonicalMediaKind.anime
                        ? null
                        : CanonicalMediaKind.anime,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Favorites'),
                  selected: favoritesOnly,
                  onSelected: (value) => setState(() => favoritesOnly = value),
                ),
                PopupMenuButton<CanonicalLibraryStatus>(
                  tooltip: 'Filter library status',
                  onSelected: (value) => setState(() => status = value),
                  itemBuilder: (_) => CanonicalLibraryStatus.values
                      .map(
                        (value) => PopupMenuItem(
                          value: value,
                          child: Text(value.name),
                        ),
                      )
                      .toList(),
                  child: Chip(label: Text(status?.name ?? 'Status')),
                ),
              ],
            ),
          ),
        ),
        if (widget.controller.loadingLocal)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: StoryNotice(
              icon: Icons.bookmarks_outlined,
              title: 'Nothing here yet',
              message: 'Add media from Search, or adjust the active filters.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: StorySliverGrid(
              itemCount: items.length,
              itemBuilder: (context, index) => StoryTile(
                actionKey: ValueKey(
                  'media-card-${items[index].media.id.value}',
                ),
                title: items[index].media.title.value,
                kind: items[index].media.kind,
                cover: items[index].media.coverLocator,
                metadata: storyMetadata(items[index]),
                status: controllerStatus(widget.controller, items[index]),
                favorite: items[index].isFavorite,
                needsRepair: items[index].hasMissingLocalSource,
                onOpen: () => _openDetails(
                  context,
                  widget.controller,
                  items[index].media.id,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.developerBuilder,
    required this.aboutBuilder,
    required this.appearance,
    required this.onAppearanceChanged,
  });
  final ProductController controller;
  final WidgetBuilder developerBuilder;
  final WidgetBuilder aboutBuilder;
  final AppPreferences appearance;
  final Future<void> Function(ZankaThemeMode, ZankaAccent) onAppearanceChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _developerToolsEnabled = false;

  ProductController get controller => widget.controller;

  void _openCategory(String name, WidgetBuilder builder) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/settings/$name'),
        builder: builder,
      ),
    );
  }

  Widget _sources() => SourceSettingsPage(controller: controller);

  Widget _samples() => SettingsDetailPage(
    title: 'Offline samples',
    description: 'Try reading and watching with generated local content.',
    child: Column(
      children: [
        SettingsAction(
          key: const Key('install-reader-sample'),
          icon: Icons.menu_book_outlined,
          title: 'Install offline reader sample',
          description: 'Local folder and CBZ chapters. No connection needed.',
          onPressed: controller.sampleInstaller == null
              ? null
              : () async {
                  final id = await controller.installSampleManga();
                  if (!mounted || id == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offline reader sample installed.'),
                    ),
                  );
                  await _openDetails(context, controller, id);
                },
        ),
        const SizedBox(height: 12),
        SettingsAction(
          key: const Key('install-player-sample'),
          icon: Icons.ondemand_video_outlined,
          title: 'Install offline player sample',
          description: 'Local MP4 episodes, with alternate encodes to try.',
          onPressed: controller.sampleAnimeInstaller == null
              ? null
              : () async {
                  final id = await controller.installSampleAnime();
                  if (!mounted || id == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offline player sample installed.'),
                    ),
                  );
                  await _openDetails(context, controller, id);
                },
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      key: const PageStorageKey('settings-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ZankaPageHeading(
                      eyebrow: 'MAKE IT YOURS',
                      title: 'Settings',
                      description: 'Your space. Your sources. Your pace.',
                    ),
                    const SizedBox(height: 28),
                    SettingsCategoryPanel(
                      key: const Key('settings-appearance'),
                      title: 'Appearance',
                      description:
                          'Light, shade and a color that feels like you.',
                      icon: Icons.contrast_rounded,
                      emphasis: true,
                      onPressed: () => _openCategory(
                        'appearance',
                        (_) => AppearanceSettingsPage(
                          appearance: widget.appearance,
                          onAppearanceChanged: widget.onAppearanceChanged,
                        ),
                      ),
                      detail: Row(
                        children: [
                          for (final accent in ZankaAccent.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: zankaAccentColor(accent),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 520;
                        final width = wide
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: width,
                              child: SettingsCategoryPanel(
                                key: const Key('settings-sources'),
                                title: 'Sources',
                                description:
                                    '${controller.providers.where((provider) => provider.enabled).length} enabled · discovery & availability',
                                icon: Icons.travel_explore_rounded,
                                onPressed: () =>
                                    _openCategory('sources', (_) => _sources()),
                              ),
                            ),
                            SizedBox(
                              width: width,
                              child: SettingsCategoryPanel(
                                key: const Key('open-local-media'),
                                title: 'Local media',
                                description:
                                    'Import, repair, storage & backup.',
                                icon: Icons.folder_copy_outlined,
                                onPressed:
                                    controller.localLibrary == null ||
                                        controller.backup == null
                                    ? null
                                    : () => _openCategory(
                                        'local-media',
                                        (_) => LocalMediaScreen(
                                          controller: controller,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'EXPLORE & SUPPORT',
                      style: theme.textTheme.labelMedium?.copyWith(
                        letterSpacing: 1.5,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (BuildProfile.current.allowsDemoContent)
                      SettingsAction(
                        key: const Key('settings-samples'),
                        icon: Icons.offline_bolt_outlined,
                        title: 'Offline samples',
                        description:
                            'A ready-to-read, ready-to-watch first try.',
                        onPressed: () =>
                            _openCategory('samples', (_) => _samples()),
                      ),
                    SettingsAction(
                      key: const Key('open-about'),
                      icon: Icons.info_outline_rounded,
                      title: 'Zanka no Tachi',
                      description: BuildProfile.current.allowsLocalDiagnostics
                          ? 'About, help, privacy, licenses and local diagnostics.'
                          : 'About, help, privacy and licenses.',
                      onPressed: () =>
                          _openCategory('about', widget.aboutBuilder),
                      onLongPress: !BuildProfile.current.allowsDeveloperTools
                          ? null
                          : () {
                              setState(() => _developerToolsEnabled = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Developer tools enabled.'),
                                ),
                              );
                            },
                    ),
                    if (BuildProfile.current.allowsDeveloperTools &&
                        _developerToolsEnabled) ...[
                      const SizedBox(height: 20),
                      Text(
                        'ADVANCED',
                        style: theme.textTheme.labelMedium?.copyWith(
                          letterSpacing: 1.5,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SettingsAction(
                        key: const Key('open-developer-tools'),
                        icon: Icons.developer_mode_rounded,
                        title: 'Developer tools',
                        description: 'Source and adapter diagnostics.',
                        onPressed: () =>
                            _openCategory('developer', widget.developerBuilder),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalSummaries extends StatelessWidget {
  const _HorizontalSummaries({
    required this.items,
    required this.controller,
    this.showProgress = false,
  });
  final List<ProductMediaSummary> items;
  final ProductController controller;
  final bool showProgress;
  @override
  Widget build(BuildContext context) => StoryRail(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return StoryTile(
        actionKey: ValueKey('home-${item.media.id.value}'),
        title: item.media.title.value,
        kind: item.media.kind,
        cover: item.media.coverLocator,
        metadata: storyMetadata(item),
        status: showProgress
            ? _progressLabel(item, controller.smartResumeFor(item.media.id))
            : controllerStatus(controller, item),
        favorite: item.isFavorite,
        needsRepair: item.hasMissingLocalSource,
        onOpen: () => _openDetails(context, controller, item.media.id),
      );
    },
  );
}

String controllerStatus(
  ProductController controller,
  ProductMediaSummary item,
) =>
    controller.smartResumeFor(item.media.id)?.label ??
    item.progressLabel ??
    storyLibraryStatus(item);

class _DiscoverSection extends StatelessWidget {
  const _DiscoverSection({
    required this.loading,
    required this.items,
    required this.controller,
    required this.emptyMessage,
  });
  final bool loading;
  final List<ProductSearchResult> items;
  final ProductController controller;
  final String emptyMessage;
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: LinearProgressIndicator(),
      );
    }
    if (items.isEmpty) {
      return StoryNotice(
        icon: Icons.cloud_off_outlined,
        title: 'Discovery unavailable',
        message: emptyMessage,
      );
    }
    return StoryRail(
      itemCount: items.length,
      itemBuilder: (context, index) => _SearchResultCard(
        result: items[index],
        controller: controller,
        discovery: true,
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.result,
    required this.controller,
    this.discovery = false,
  });
  final ProductSearchResult result;
  final ProductController controller;
  final bool discovery;
  @override
  Widget build(BuildContext context) => StoryTile(
    actionKey: ValueKey(
      '${discovery ? 'discover' : 'search-result'}-${result.sources.first.providerId.value}-${result.sources.first.externalId}',
    ),
    title: result.title,
    kind: result.kind,
    cover: result.coverUrl?.toString(),
    metadata: [
      _searchMediaLabel(result),
      storySources(result.sources.length),
    ].join(' · '),
    status:
        result.subtitle ??
        (result.persisted?.isSaved == true ? 'In Library' : ''),
    saved: result.persisted?.isSaved == true,
    favorite: result.persisted?.isFavorite == true,
    onOpen: () => _openResult(context, controller, result),
  );
}

Future<void> _openResult(
  BuildContext context,
  ProductController controller,
  ProductSearchResult result,
) async {
  if (ModalRoute.of(context)?.isCurrent != true) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(
        name: result.canonicalId == null
            ? '/media/source-details'
            : '/media/${result.canonicalId!.value}',
      ),
      builder: (_) => MediaDetailsScreen(
        controller: controller,
        mediaId: result.canonicalId,
        searchResult: result,
      ),
    ),
  );
  if (context.mounted) await controller.refreshLocal();
}

Future<void> _openDetails(
  BuildContext context,
  ProductController controller,
  CanonicalMediaId mediaId,
) async {
  if (ModalRoute.of(context)?.isCurrent != true) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: '/media/${mediaId.value}'),
      builder: (_) =>
          MediaDetailsScreen(controller: controller, mediaId: mediaId),
    ),
  );
  await controller.refreshLocal();
}

String _progressLabel(ProductMediaSummary item, [SmartResumeTarget? target]) {
  final action = target?.label;
  if (item.mangaProgress case final progress?) {
    final total = progress.totalPages;
    final page = total == null
        ? 'Page ${progress.pageIndex + 1}'
        : 'Page ${progress.pageIndex + 1} of $total';
    return [
      if (action != null) action,
      item.progressLabel ?? 'Chapter',
      page,
    ].join(' · ');
  }
  if (item.animeProgress case final progress?) {
    final minutes = progress.position.inMinutes;
    final seconds = progress.position.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return [
      if (action != null) action,
      item.progressLabel ?? 'Episode',
      '$minutes:$seconds',
    ].join(' · ');
  }
  return '';
}

String _searchMediaLabel(ProductSearchResult result) {
  final media = result.persisted?.media;
  if (media == null) return result.kind.name;
  return switch (media) {
    CanonicalManga() => 'manga · ${media.status.name}',
    CanonicalAnime(:final format) => '${format.name} · ${media.status.name}',
  };
}
