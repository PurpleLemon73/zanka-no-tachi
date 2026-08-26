import 'package:flutter/material.dart';

import '../../canonical/domain/identifiers.dart';
import '../../canonical/domain/media.dart';
import '../../canonical/domain/user_state.dart';
import '../product_controller.dart';
import '../product_models.dart';
import 'design_system.dart';
import 'media_details_screen.dart';
import 'local_media_screen.dart';
import '../../app/app_preferences.dart';
import '../smart_resume.dart';

class ProductShell extends StatelessWidget {
  const ProductShell({
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
  Widget build(BuildContext context) => AnimatedBuilder(
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
      const destinations = [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        NavigationDestination(
          icon: Icon(Icons.bookmarks_outlined),
          selectedIcon: Icon(Icons.bookmarks),
          label: 'Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
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
                    child: NavigationRail(
                      labelType: NavigationRailLabelType.all,
                      selectedIndex: controller.selectedTab,
                      onDestinationSelected: controller.selectTab,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.search),
                          label: Text('Search'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.bookmarks_outlined),
                          selectedIcon: Icon(Icons.bookmarks),
                          label: Text('Library'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings_outlined),
                          selectedIcon: Icon(Icons.settings),
                          label: Text('Settings'),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: content),
                ],
              ),
            );
          }
          return Scaffold(
            body: content,
            bottomNavigationBar: NavigationBar(
              selectedIndex: controller.selectedTab,
              onDestinationSelected: controller.selectTab,
              destinations: destinations,
            ),
          );
        },
      );
    },
  );
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
        SliverAppBar.large(
          title: const Text('Zanka'),
          actions: [
            IconButton(
              tooltip: 'Search',
              onPressed: () => controller.selectTab(1),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        if (controller.loadingLocal)
          const SliverToBoxAdapter(child: LinearProgressIndicator())
        else ...[
          if (controller.continueItems.isNotEmpty) ...[
            const SliverToBoxAdapter(child: ZankaSectionTitle('Continue')),
            SliverToBoxAdapter(
              child: _HorizontalSummaries(
                items: controller.continueItems,
                controller: controller,
                showProgress: true,
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: ZankaSectionTitle(
              'Your Library',
              action: TextButton(
                onPressed: () => controller.selectTab(2),
                child: const Text('View all'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: controller.library.isEmpty
                ? ProductEmptyState(
                    icon: Icons.bookmark_add_outlined,
                    title: 'Your library starts here',
                    message:
                        'Search for a title and save it for offline access to its metadata.',
                    action: FilledButton(
                      onPressed: () => controller.selectTab(1),
                      child: const Text('Find media'),
                    ),
                  )
                : _HorizontalSummaries(
                    items: controller.library.take(8).toList(),
                    controller: controller,
                  ),
          ),
          if (controller.persisted.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: ZankaSectionTitle('On this device'),
            ),
            SliverToBoxAdapter(
              child: _HorizontalSummaries(
                items: controller.persisted.take(8).toList(),
                controller: controller,
              ),
            ),
          ],
        ],
        const SliverToBoxAdapter(child: ZankaSectionTitle('Discover Manga')),
        SliverToBoxAdapter(
          child: _DiscoverSection(
            loading: controller.loadingDiscover,
            items: controller.discoverManga,
            controller: controller,
            emptyMessage:
                'Manga discovery is unavailable. Your local library still works.',
          ),
        ),
        const SliverToBoxAdapter(child: ZankaSectionTitle('Discover Anime')),
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
            child: Padding(
              padding: const EdgeInsets.all(ZankaSpace.md),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.cloud_off_outlined),
                  title: const Text('Some sources are unavailable'),
                  subtitle: Text(
                    controller.discoverFailures.values.toSet().join(' '),
                  ),
                  trailing: IconButton(
                    tooltip: 'Retry discovery',
                    onPressed: controller.refreshDiscover,
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              ),
            ),
          ),
        if (controller.discoverCursors.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ZankaSpace.md),
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
        const SliverToBoxAdapter(child: SizedBox(height: ZankaSpace.xl)),
      ],
    ),
  );
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
      const SliverAppBar.large(title: Text('Search')),
      SliverPadding(
        padding: const EdgeInsets.all(ZankaSpace.md),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: [
              SearchBar(
                key: const Key('product-search-field'),
                controller: textController,
                hintText: 'Search manga and anime',
                leading: const Icon(Icons.search),
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
              const SizedBox(height: ZankaSpace.sm),
              Wrap(
                spacing: ZankaSpace.sm,
                children: CanonicalMediaKind.values
                    .map(
                      (kind) => FilterChip(
                        key: ValueKey('scope-${kind.name}'),
                        label: Text(kind.name == 'manga' ? 'Manga' : 'Anime'),
                        selected: widget.controller.searchKinds.contains(kind),
                        onSelected: (enabled) =>
                            widget.controller.setSearchKind(kind, enabled),
                      ),
                    )
                    .toList(),
              ),
              if (widget.controller.searching) const LinearProgressIndicator(),
              if (widget.controller.searchFailures.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: ZankaSpace.sm),
                  child: Text(
                    widget.controller.searchResults.isEmpty
                        ? widget.controller.searchFailures.values.toSet().join(
                            ' ',
                          )
                        : 'Some sources could not be searched. Showing available results.',
                  ),
                ),
            ],
          ),
        ),
      ),
      if (widget.controller.searchQuery.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: widget.controller.recentSearches.isEmpty
              ? const ProductEmptyState(
                  icon: Icons.manage_search,
                  title: 'Search every enabled source',
                  message:
                      'Results remain separate unless canonical identity has been reviewed and merged.',
                )
              : Padding(
                  padding: const EdgeInsets.all(ZankaSpace.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Recent searches',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: widget.controller.clearRecentSearches,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: ZankaSpace.sm,
                        children: widget.controller.recentSearches
                            .map(
                              (query) => ActionChip(
                                label: Text(query),
                                onPressed: () {
                                  textController.text = query;
                                  widget.controller.submitSearch(query);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
        )
      else if (!widget.controller.searching &&
          widget.controller.searchResults.isEmpty)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: ProductEmptyState(
            icon: Icons.search_off,
            title: 'No results',
            message: 'Try another title or enable another media scope.',
          ),
        )
      else
        SliverList.builder(
          itemCount:
              widget.controller.searchResults.length +
              (widget.controller.searchCursors.isEmpty ? 0 : 1),
          itemBuilder: (context, index) {
            if (index == widget.controller.searchResults.length) {
              return Padding(
                padding: const EdgeInsets.all(ZankaSpace.md),
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
              );
            }
            return _SearchResultCard(
              result: widget.controller.searchResults[index],
              controller: widget.controller,
            );
          },
        ),
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
        SliverAppBar.large(
          title: const Text('Library'),
          actions: [
            PopupMenuButton<LibrarySort>(
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
          ],
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: ZankaSpace.md),
            child: Row(
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
                const SizedBox(width: ZankaSpace.sm),
                ChoiceChip(
                  label: const Text('Manga'),
                  selected: kind == CanonicalMediaKind.manga,
                  onSelected: (_) => setState(
                    () => kind = kind == CanonicalMediaKind.manga
                        ? null
                        : CanonicalMediaKind.manga,
                  ),
                ),
                const SizedBox(width: ZankaSpace.sm),
                ChoiceChip(
                  label: const Text('Anime'),
                  selected: kind == CanonicalMediaKind.anime,
                  onSelected: (_) => setState(
                    () => kind = kind == CanonicalMediaKind.anime
                        ? null
                        : CanonicalMediaKind.anime,
                  ),
                ),
                const SizedBox(width: ZankaSpace.sm),
                ChoiceChip(
                  label: const Text('Favorites'),
                  selected: favoritesOnly,
                  onSelected: (value) => setState(() => favoritesOnly = value),
                ),
                const SizedBox(width: ZankaSpace.sm),
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
            child: ProductEmptyState(
              icon: Icons.bookmarks_outlined,
              title: 'Nothing here yet',
              message: 'Add media from Search, or adjust the active filters.',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(ZankaSpace.sm),
            sliver: SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => CanonicalMediaCard(
                summary: items[index],
                onTap: () => _openDetails(
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

class SettingsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) => CustomScrollView(
    key: const PageStorageKey('settings-scroll'),
    slivers: [
      const SliverAppBar.large(title: Text('Settings')),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(ZankaSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
              SegmentedButton<ZankaThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ZankaThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment(
                    value: ZankaThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ZankaThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {appearance.themeMode},
                onSelectionChanged: (value) =>
                    onAppearanceChanged(value.first, appearance.accent),
              ),
              const SizedBox(height: ZankaSpace.md),
              Text(
                'Accent color',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: ZankaSpace.sm,
                runSpacing: ZankaSpace.sm,
                children: [
                  for (final accent in ZankaAccent.values)
                    ChoiceChip(
                      key: ValueKey('accent-${accent.name}'),
                      avatar: CircleAvatar(
                        backgroundColor: zankaAccentColor(accent),
                      ),
                      label: Text(_accentLabel(accent)),
                      selected: appearance.accent == accent,
                      onSelected: (_) =>
                          onAppearanceChanged(appearance.themeMode, accent),
                    ),
                ],
              ),
              const SizedBox(height: ZankaSpace.lg),
              Text('Sources', style: Theme.of(context).textTheme.titleLarge),
              ...controller.providers.map(
                (provider) => SwitchListTile(
                  key: ValueKey('setting-provider-${provider.id.value}'),
                  title: Text(provider.displayName),
                  subtitle: Text(
                    '${provider.mediaKind.name} · ${provider.baseUrl.host}',
                  ),
                  value: provider.enabled,
                  onChanged: (value) =>
                      controller.setProviderEnabled(provider.id, value),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.low_priority),
                title: Text('Source fallback'),
                subtitle: Text(
                  'Per-media preference first, then available sources in stable order.',
                ),
              ),
              ListTile(
                key: const Key('install-reader-sample'),
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Install offline reader sample'),
                subtitle: const Text(
                  'Generated local folder and CBZ chapters for lawful, deterministic reader testing.',
                ),
                trailing: const Icon(Icons.download_for_offline_outlined),
                onTap: controller.sampleInstaller == null
                    ? null
                    : () async {
                        final id = await controller.installSampleManga();
                        if (!context.mounted || id == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Offline reader sample installed.'),
                          ),
                        );
                        await _openDetails(context, controller, id);
                      },
              ),
              ListTile(
                key: const Key('install-player-sample'),
                leading: const Icon(Icons.ondemand_video_outlined),
                title: const Text('Install offline player sample'),
                subtitle: const Text(
                  'Generated local MP4 episodes with alternate encodes for lawful playback testing.',
                ),
                trailing: const Icon(Icons.download_for_offline_outlined),
                onTap: controller.sampleAnimeInstaller == null
                    ? null
                    : () async {
                        final id = await controller.installSampleAnime();
                        if (!context.mounted || id == null) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Offline player sample installed.'),
                          ),
                        );
                        await _openDetails(context, controller, id);
                      },
              ),
              const SizedBox(height: ZankaSpace.lg),
              ListTile(
                key: const Key('open-local-media'),
                leading: const Icon(Icons.folder_copy_outlined),
                title: const Text('Local media'),
                subtitle: const Text(
                  'Import, repair, remove, inspect storage, backup and restore.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap:
                    controller.localLibrary == null || controller.backup == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          settings: const RouteSettings(
                            name: '/settings/local-media',
                          ),
                          builder: (_) =>
                              LocalMediaScreen(controller: controller),
                        ),
                      ),
              ),
              Text('About', style: Theme.of(context).textTheme.titleLarge),
              ListTile(
                key: const Key('open-about'),
                leading: Icon(Icons.info_outline),
                title: Text('Zanka no Tachi'),
                subtitle: Text(
                  'About, help, privacy, licenses and local diagnostics.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    settings: const RouteSettings(name: '/settings/about'),
                    builder: aboutBuilder,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                key: const Key('open-developer-tools'),
                leading: const Icon(Icons.developer_mode),
                title: const Text('Developer'),
                subtitle: const Text(
                  'Provider health, parser diagnostics, ingestion and reconciliation.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    settings: const RouteSettings(name: '/settings/developer'),
                    builder: developerBuilder,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
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
  Widget build(BuildContext context) => SizedBox(
    height: showProgress ? 190 : 170,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: ZankaSpace.md),
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(width: ZankaSpace.sm),
      itemBuilder: (context, index) {
        final item = items[index];
        return SizedBox(
          width: 250,
          child: Card(
            child: InkWell(
              key: ValueKey('home-${item.media.id.value}'),
              onTap: () => _openDetails(context, controller, item.media.id),
              borderRadius: BorderRadius.circular(ZankaRadius.card),
              child: Padding(
                padding: const EdgeInsets.all(ZankaSpace.sm),
                child: Row(
                  children: [
                    CoverArt(
                      locator: item.media.coverLocator,
                      width: 76,
                      height: 108,
                    ),
                    const SizedBox(width: ZankaSpace.sm),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.media.title.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: ZankaSpace.sm),
                          if (showProgress)
                            Text(
                              _progressLabel(
                                item,
                                controller.smartResumeFor(item.media.id),
                              ),
                            ),
                          Text(
                            '${item.bindings.length} source${item.bindings.length == 1 ? '' : 's'}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

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
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (items.isEmpty) {
      return ProductEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Discovery unavailable',
        message: emptyMessage,
      );
    }
    return SizedBox(
      height: 178,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: ZankaSpace.md),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: ZankaSpace.sm),
        itemBuilder: (context, index) => SizedBox(
          width: 140,
          child: _CompactResult(result: items[index], controller: controller),
        ),
      ),
    );
  }
}

class _CompactResult extends StatelessWidget {
  const _CompactResult({required this.result, required this.controller});
  final ProductSearchResult result;
  final ProductController controller;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      key: ValueKey(
        'discover-${result.sources.first.providerId.value}-${result.sources.first.externalId}',
      ),
      borderRadius: BorderRadius.circular(ZankaRadius.card),
      onTap: () => _openResult(context, controller, result),
      child: Padding(
        padding: const EdgeInsets.all(ZankaSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CoverArt(
                locator: result.coverUrl?.toString(),
                width: double.infinity,
                height: 100,
              ),
            ),
            const SizedBox(height: ZankaSpace.xs),
            Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    ),
  );
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result, required this.controller});
  final ProductSearchResult result;
  final ProductController controller;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(
      horizontal: ZankaSpace.md,
      vertical: ZankaSpace.xs,
    ),
    child: ListTile(
      key: ValueKey(
        'search-result-${result.sources.first.providerId.value}-${result.sources.first.externalId}',
      ),
      leading: CoverArt(
        locator: result.coverUrl?.toString(),
        width: 48,
        height: 64,
      ),
      title: Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          _searchMediaLabel(result),
          if (result.subtitle != null) result.subtitle!,
          '${result.sources.length} source${result.sources.length == 1 ? '' : 's'}',
          if (result.persisted?.isSaved ?? false) 'In Library',
        ].join(' · '),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openResult(context, controller, result),
    ),
  );
}

Future<void> _openResult(
  BuildContext context,
  ProductController controller,
  ProductSearchResult result,
) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final details = await controller.openResult(result);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(
          name: '/media/${details.summary.media.id.value}',
        ),
        builder: (_) => MediaDetailsScreen(
          controller: controller,
          mediaId: details.summary.media.id,
          initialDetails: details,
        ),
      ),
    );
  } on Object {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This title could not be opened. Try again later.'),
      ),
    );
  }
}

Future<void> _openDetails(
  BuildContext context,
  ProductController controller,
  CanonicalMediaId mediaId,
) async {
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

String _accentLabel(ZankaAccent accent) => switch (accent) {
  ZankaAccent.defaultRed => 'Default',
  ZankaAccent.orange => 'Orange',
  ZankaAccent.green => 'Green',
  ZankaAccent.teal => 'Teal',
  ZankaAccent.blue => 'Blue',
  ZankaAccent.indigo => 'Indigo',
  ZankaAccent.purple => 'Purple',
};
