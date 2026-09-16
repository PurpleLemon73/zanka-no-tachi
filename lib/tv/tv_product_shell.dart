import 'package:flutter/material.dart';

import '../app/app_preferences.dart';
import '../app/build_profile.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../product/product_controller.dart';
import '../product/product_models.dart';
import '../product/ui/design_system.dart';
import '../product/ui/content_visuals.dart';
import '../product/ui/settings_visuals.dart';
import '../product/ui/source_settings_page.dart';
import '../product/ui/product_navigation.dart';
import 'tv_design_system.dart';
import 'tv_media_details_screen.dart';

class TvProductShell extends StatelessWidget {
  const TvProductShell({
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
  Widget build(BuildContext context) => FocusTraversalGroup(
    policy: ReadingOrderTraversalPolicy(),
    child: Scaffold(
      key: const Key('tv-product-shell'),
      body: SafeArea(
        child: Row(
          children: [
            ZankaNavigation(
              key: const Key('product-primary-navigation'),
              vertical: true,
              tv: true,
              selectedIndex: controller.selectedTab,
              onSelected: controller.selectTab,
            ),
            Expanded(
              child: switch (controller.selectedTab) {
                0 => TvHomeScreen(controller: controller),
                1 => TvSearchScreen(controller: controller),
                2 => TvLibraryScreen(controller: controller),
                _ => TvSettingsScreen(
                  controller: controller,
                  developerBuilder: developerBuilder,
                  aboutBuilder: aboutBuilder,
                  appearance: appearance,
                  onAppearanceChanged: onAppearanceChanged,
                ),
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class TvHomeScreen extends StatelessWidget {
  const TvHomeScreen({super.key, required this.controller});
  final ProductController controller;
  @override
  Widget build(BuildContext context) {
    final hero =
        controller.continueItems
            .where((item) => item.media is CanonicalAnime)
            .firstOrNull ??
        controller.library.firstOrNull;
    return CustomScrollView(
      key: const PageStorageKey('tv-home-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ZankaPageHeading(
                  eyebrow: 'Zanka no Tachi',
                  title: 'Your stories.',
                  tv: true,
                ),
                const SizedBox(height: 24),
                if (controller.loadingLocal)
                  const LinearProgressIndicator()
                else if (hero != null)
                  StoryFeature(
                    item: hero,
                    tv: true,
                    autofocus: true,
                    actionKey: const Key('tv-hero-action'),
                    label:
                        controller.smartResumeFor(hero.media.id)?.label ??
                        'Open details',
                    detail: hero.progressLabel ?? storyMetadata(hero),
                    onOpen: () => _openDetails(
                      context,
                      controller,
                      hero.media.id,
                      autofocusResume: true,
                    ),
                  )
                else
                  StoryNotice(
                    tv: true,
                    title: 'Your TV home is ready',
                    message:
                        'Manga to read. Anime to watch. Browse the catalog or add your own local stories.',
                    icon: Icons.live_tv_rounded,
                    action: TvFocusable(
                      key: const Key('tv-empty-browse'),
                      autofocus: true,
                      semanticLabel: 'Browse anime',
                      onPressed: () => controller.selectTab(1),
                      child: const Padding(
                        padding: EdgeInsets.all(18),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_rounded),
                            SizedBox(width: 12),
                            Text(
                              'Browse anime',
                              style: TextStyle(fontSize: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        for (final kind in CanonicalMediaKind.values)
          if (controller.continueItems.any((item) => item.media.kind == kind))
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: _TvSummaryRail(
                  title: kind == CanonicalMediaKind.manga
                      ? 'Continue reading'
                      : 'Continue watching',
                  items: controller.continueItems
                      .where((item) => item.media.kind == kind)
                      .toList(),
                  controller: controller,
                ),
              ),
            ),
        if (controller.library.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: _TvSummaryRail(
                title: 'Your Library',
                items: controller.library,
                controller: controller,
              ),
            ),
          ),
        for (final kind in CanonicalMediaKind.values) ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: StorySection(
                kind == CanonicalMediaKind.manga
                    ? 'Discover Manga'
                    : 'Discover Anime',
                tv: true,
              ),
            ),
          ),
          if (controller.loadingDiscover)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: LinearProgressIndicator(),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: _TvSearchRail(
                  items: kind == CanonicalMediaKind.manga
                      ? controller.discoverManga
                      : controller.discoverAnime,
                  controller: controller,
                ),
              ),
            ),
        ],
        if (controller.discoverFailures.isNotEmpty)
          SliverToBoxAdapter(
            child: StoryNotice(
              tv: true,
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
              padding: const EdgeInsets.all(32),
              child: OutlinedButton(
                key: const Key('discover-load-more'),
                onPressed: controller.loadingMoreDiscover
                    ? null
                    : controller.loadMoreDiscover,
                child: Text(
                  controller.loadingMoreDiscover
                      ? 'Loading…'
                      : 'Load more discovery',
                ),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _TvSummaryRail extends StatelessWidget {
  const _TvSummaryRail({
    required this.title,
    required this.items,
    required this.controller,
  });
  final String title;
  final List<ProductMediaSummary> items;
  final ProductController controller;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      StorySection(title, tv: true),
      StoryRail(
        tv: true,
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _tvSummary(context, controller, items[index], prefix: 'tv-home'),
      ),
    ],
  );
}

Widget _tvSummary(
  BuildContext context,
  ProductController controller,
  ProductMediaSummary item, {
  String prefix = 'tv-library',
}) => StoryTile(
  tv: true,
  actionKey: ValueKey('$prefix-${item.media.id.value}'),
  title: item.media.title.value,
  kind: item.media.kind,
  cover: item.media.coverLocator,
  metadata: storyMetadata(item),
  status:
      controller.smartResumeFor(item.media.id)?.label ??
      item.progressLabel ??
      storyLibraryStatus(item),
  favorite: item.isFavorite,
  needsRepair: item.hasMissingLocalSource,
  onOpen: () => _openDetails(context, controller, item.media.id),
);

class _TvSearchRail extends StatelessWidget {
  const _TvSearchRail({required this.items, required this.controller});
  final List<ProductSearchResult> items;
  final ProductController controller;
  @override
  Widget build(BuildContext context) => items.isEmpty
      ? const StoryNotice(
          tv: true,
          title: 'Discovery unavailable',
          message: 'Your saved collection is still available.',
          icon: Icons.cloud_off_outlined,
        )
      : StoryRail(
          tv: true,
          itemCount: items.length,
          itemBuilder: (context, index) => _tvResult(
            context,
            controller,
            items[index],
            prefix: 'tv-discover',
          ),
        );
}

Widget _tvResult(
  BuildContext context,
  ProductController controller,
  ProductSearchResult result, {
  FocusNode? focusNode,
  String prefix = 'tv-search',
}) => StoryTile(
  tv: true,
  focusNode: focusNode,
  actionKey: ValueKey(
    '$prefix-${result.sources.first.providerId.value}-${result.sources.first.externalId}',
  ),
  title: result.title,
  kind: result.kind,
  cover: result.coverUrl?.toString(),
  metadata: storySources(result.sources.length),
  status: result.subtitle ?? '',
  saved: result.persisted?.isSaved == true,
  favorite: result.persisted?.isFavorite == true,
  onOpen: () => _openResult(context, controller, result),
);

class TvSearchScreen extends StatefulWidget {
  const TvSearchScreen({super.key, required this.controller});
  final ProductController controller;

  @override
  State<TvSearchScreen> createState() => _TvSearchScreenState();
}

class _TvSearchScreenState extends State<TvSearchScreen> {
  late final TextEditingController text = TextEditingController(
    text: widget.controller.searchQuery,
  );
  final FocusNode firstResultFocus = FocusNode(
    debugLabel: 'First TV search result',
  );

  @override
  void dispose() {
    text.dispose();
    firstResultFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomScrollView(
    key: const PageStorageKey('tv-search-scroll'),
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ZankaPageHeading(
                eyebrow: 'Find your next story',
                title: 'Search',
                tv: true,
              ),
              const SizedBox(height: 24),
              TextField(
                key: const Key('tv-search-field'),
                controller: text,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: const TextStyle(fontSize: 24),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search manga and anime',
                ),
                onChanged: widget.controller.scheduleSearch,
                onSubmitted: (value) async {
                  await widget.controller.submitSearch(value);
                  if (mounted &&
                      widget.controller.searchQuery == value.trim() &&
                      widget.controller.searchResults.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted &&
                          ModalRoute.of(context)?.isCurrent == true &&
                          widget.controller.searchQuery == value.trim()) {
                        firstResultFocus.requestFocus();
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: CanonicalMediaKind.values
                    .map(
                      (kind) => FilterChip(
                        label: Text(
                          kind == CanonicalMediaKind.anime ? 'Anime' : 'Manga',
                          style: const TextStyle(fontSize: 20),
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
                  padding: EdgeInsets.only(top: 18),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
      if (widget.controller.searchFailures.isNotEmpty)
        SliverToBoxAdapter(
          child: StoryNotice(
            tv: true,
            title: 'Some sources could not be searched',
            compact: widget.controller.searchResults.isNotEmpty,
            message: widget.controller.searchResults.isEmpty
                ? widget.controller.searchFailures.values.toSet().join(' ')
                : 'Showing available results. Your saved collection is unchanged.',
            action: TextButton.icon(
              onPressed: () => widget.controller.submitSearch(text.text),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry search'),
            ),
          ),
        ),
      if (widget.controller.searchQuery.isEmpty)
        const SliverToBoxAdapter(
          child: StoryNotice(
            tv: true,
            title: 'A title. A new beginning.',
            message: 'Search for manga or anime across your enabled sources.',
            icon: Icons.travel_explore_rounded,
          ),
        )
      else if (!widget.controller.searching &&
          widget.controller.searchResults.isEmpty &&
          widget.controller.searchFailures.isEmpty)
        const SliverToBoxAdapter(
          child: StoryNotice(
            tv: true,
            title: 'No results',
            message: 'Try another title or enable another media scope.',
            icon: Icons.search_off,
          ),
        )
      else if (widget.controller.searchResults.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: StorySection(
            '${widget.controller.searchResults.length} titles',
            tv: true,
          ),
        ),
        SliverPadding(
          key: const Key('tv-search-results'),
          padding: const EdgeInsets.all(32),
          sliver: StorySliverGrid(
            tv: true,
            itemCount: widget.controller.searchResults.length,
            itemBuilder: (context, index) => _tvResult(
              context,
              widget.controller,
              widget.controller.searchResults[index],
              focusNode: index == 0 ? firstResultFocus : null,
            ),
          ),
        ),
      ],
      if (widget.controller.searchCursors.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: OutlinedButton(
              key: const Key('search-load-more'),
              onPressed: widget.controller.loadingMoreSearch
                  ? null
                  : widget.controller.loadMoreSearch,
              child: Text(
                widget.controller.loadingMoreSearch
                    ? 'Loading…'
                    : 'Load more results',
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 32)),
    ],
  );
}

enum _TvLibraryFilter { all, anime, manga }

class TvLibraryScreen extends StatefulWidget {
  const TvLibraryScreen({super.key, required this.controller});
  final ProductController controller;

  @override
  State<TvLibraryScreen> createState() => _TvLibraryScreenState();
}

class _TvLibraryScreenState extends State<TvLibraryScreen> {
  _TvLibraryFilter filter = _TvLibraryFilter.all;
  bool alphabetical = false;

  @override
  Widget build(BuildContext context) {
    final values = widget.controller.library
        .where(
          (item) => switch (filter) {
            _TvLibraryFilter.all => true,
            _TvLibraryFilter.anime =>
              item.media.kind == CanonicalMediaKind.anime,
            _TvLibraryFilter.manga =>
              item.media.kind == CanonicalMediaKind.manga,
          },
        )
        .toList();
    if (alphabetical) {
      values.sort(
        (a, b) => a.media.title.value.toLowerCase().compareTo(
          b.media.title.value.toLowerCase(),
        ),
      );
    }
    return CustomScrollView(
      key: const PageStorageKey('tv-library-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ZankaPageHeading(
                  eyebrow: 'Your collection',
                  title: 'Library',
                  description: '${values.length} titles in this view',
                  tv: true,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    for (final value in _TvLibraryFilter.values)
                      FilterChip(
                        label: Text(switch (value) {
                          _TvLibraryFilter.all => 'All',
                          _TvLibraryFilter.anime => 'Anime',
                          _TvLibraryFilter.manga => 'Manga',
                        }, style: const TextStyle(fontSize: 20)),
                        selected: filter == value,
                        onSelected: (_) => setState(() => filter = value),
                      ),
                    FilterChip(
                      label: const Text('A–Z', style: TextStyle(fontSize: 20)),
                      selected: alphabetical,
                      onSelected: (value) =>
                          setState(() => alphabetical = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (widget.controller.loadingLocal)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: LinearProgressIndicator(),
            ),
          )
        else if (values.isEmpty)
          const SliverToBoxAdapter(
            child: StoryNotice(
              tv: true,
              title: 'Your Library is empty',
              message:
                  'Saved media remains available here even if a source is offline.',
              icon: Icons.video_library_outlined,
            ),
          )
        else
          SliverPadding(
            key: const Key('tv-library-grid'),
            padding: const EdgeInsets.all(32),
            sliver: StorySliverGrid(
              tv: true,
              itemCount: values.length,
              itemBuilder: (context, index) =>
                  _tvSummary(context, widget.controller, values[index]),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class TvSettingsScreen extends StatelessWidget {
  const TvSettingsScreen({
    super.key,
    this.controller,
    required this.developerBuilder,
    required this.aboutBuilder,
    required this.appearance,
    required this.onAppearanceChanged,
  });
  final ProductController? controller;
  final WidgetBuilder developerBuilder;
  final WidgetBuilder aboutBuilder;
  final AppPreferences appearance;
  final Future<void> Function(ZankaThemeMode, ZankaAccent) onAppearanceChanged;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.symmetric(
      horizontal: TvTokens.safeHorizontal,
      vertical: TvTokens.safeVertical,
    ),
    children: [
      const ZankaPageHeading(
        eyebrow: 'MAKE IT YOURS',
        title: 'Settings',
        description: 'A quieter backdrop. A look of your own.',
        tv: true,
      ),
      const SizedBox(height: 30),
      SettingsCategoryPanel(
        key: const Key('settings-appearance'),
        title: 'Appearance',
        description: 'System, Light or Dark. Seven accent colors.',
        icon: Icons.contrast_rounded,
        tv: true,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: '/settings/appearance'),
            builder: (_) => AppearanceSettingsPage(
              appearance: appearance,
              onAppearanceChanged: onAppearanceChanged,
              tv: true,
            ),
          ),
        ),
      ),
      if (controller != null) ...[
        const SizedBox(height: 24),
        SettingsCategoryPanel(
          key: const Key('settings-sources'),
          title: 'Sources',
          description: 'Discovery and source addresses.',
          icon: Icons.travel_explore_rounded,
          tv: true,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SourceSettingsPage(controller: controller!),
            ),
          ),
        ),
      ],
      const SizedBox(height: 24),
      SettingsAction(
        key: const Key('open-about'),
        title: 'About Zanka',
        description: BuildProfile.current.allowsLocalDiagnostics
            ? 'Help, privacy, licenses and local diagnostics.'
            : 'Help, privacy and licenses.',
        icon: Icons.info_outline_rounded,
        tv: true,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: aboutBuilder)),
      ),
      if (BuildProfile.current.allowsDeveloperTools) ...[
        const SizedBox(height: 14),
        SettingsAction(
          key: const Key('open-developer-tools'),
          title: 'Developer',
          description: 'Advanced controls and source diagnostics.',
          icon: Icons.developer_mode_rounded,
          tv: true,
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: developerBuilder)),
        ),
      ],
    ],
  );
}

Future<void> _openDetails(
  BuildContext context,
  ProductController controller,
  CanonicalMediaId id, {
  bool autofocusResume = false,
}) async {
  if (ModalRoute.of(context)?.isCurrent != true) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: '/tv/media/${id.value}'),
      builder: (_) => TvMediaDetailsScreen(
        controller: controller,
        mediaId: id,
        autofocusResume: autofocusResume,
      ),
    ),
  );
  await controller.refreshLocal();
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
            ? '/tv/media/source-details'
            : '/tv/media/${result.canonicalId!.value}',
      ),
      builder: (_) => TvMediaDetailsScreen(
        controller: controller,
        mediaId: result.canonicalId,
        searchResult: result,
      ),
    ),
  );
  if (context.mounted) await controller.refreshLocal();
}
