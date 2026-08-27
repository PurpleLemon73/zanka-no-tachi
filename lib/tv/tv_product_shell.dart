import 'package:flutter/material.dart';

import '../app/app_preferences.dart';
import '../canonical/domain/identifiers.dart';
import '../canonical/domain/media.dart';
import '../product/product_controller.dart';
import '../product/product_models.dart';
import '../product/smart_resume.dart';
import '../product/ui/design_system.dart';
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
            SizedBox(
              width: TvTokens.railWidth,
              child: NavigationRail(
                extended: false,
                selectedIndex: controller.selectedTab,
                onDestinationSelected: controller.selectTab,
                labelType: NavigationRailLabelType.all,
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
                    icon: Icon(Icons.video_library_outlined),
                    selectedIcon: Icon(Icons.video_library),
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
            Expanded(
              child: switch (controller.selectedTab) {
                0 => TvHomeScreen(controller: controller),
                1 => TvSearchScreen(controller: controller),
                2 => TvLibraryScreen(controller: controller),
                _ => TvSettingsScreen(
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
    final hero = controller.continueItems
        .where((item) => item.media is CanonicalAnime)
        .firstOrNull;
    final fallback = hero ?? controller.library.firstOrNull;
    return CustomScrollView(
      key: const PageStorageKey('tv-home-scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            TvTokens.safeHorizontal,
            TvTokens.safeVertical,
            TvTokens.safeHorizontal,
            0,
          ),
          sliver: SliverList.list(
            children: [
              if (fallback != null)
                _TvHero(
                  item: fallback,
                  target: controller.smartResumeFor(fallback.media.id),
                  onOpen: () => _openDetails(
                    context,
                    controller,
                    fallback.media.id,
                    autofocusResume: true,
                  ),
                )
              else
                SizedBox(
                  height: TvTokens.heroHeight,
                  child: Row(
                    children: [
                      const Expanded(
                        child: ProductEmptyState(
                          icon: Icons.live_tv,
                          title: 'Your TV home is ready',
                          message:
                              'Browse the public catalog or add lawful local media.',
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TvFocusable(
                          key: const Key('tv-empty-browse'),
                          autofocus: true,
                          onPressed: () => controller.selectTab(1),
                          semanticLabel: 'Browse anime',
                          child: const ListTile(
                            leading: Icon(Icons.search),
                            title: Text('Browse anime'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: TvTokens.sectionGap),
              if (controller.continueItems.isNotEmpty)
                _TvSummaryRail(
                  title: 'Continue',
                  items: controller.continueItems,
                  controller: controller,
                ),
              if (controller.library.isNotEmpty)
                _TvSummaryRail(
                  title: 'Anime Library',
                  items: controller.library
                      .where((item) => item.media is CanonicalAnime)
                      .toList(),
                  controller: controller,
                ),
              if (controller.discoverAnime.isNotEmpty)
                _TvSearchRail(
                  title: 'Discover Anime',
                  items: controller.discoverAnime,
                  controller: controller,
                ),
              if (controller.library.any(
                (item) => item.media is CanonicalManga,
              ))
                _TvSummaryRail(
                  title: 'Manga',
                  items: controller.library
                      .where((item) => item.media is CanonicalManga)
                      .toList(),
                  controller: controller,
                ),
              const SizedBox(height: TvTokens.safeVertical),
            ],
          ),
        ),
      ],
    );
  }
}

class _TvHero extends StatelessWidget {
  const _TvHero({
    required this.item,
    required this.target,
    required this.onOpen,
  });
  final ProductMediaSummary item;
  final SmartResumeTarget? target;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: TvTokens.heroHeight,
    child: Row(
      children: [
        CoverArt(locator: item.media.coverLocator, width: 180, height: 260),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.media.title.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 10),
              Text(
                item.media is CanonicalAnime ? 'Anime' : 'Manga',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (item.media.description?.value case final description?) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: 310,
                child: TvFocusable(
                  key: const Key('tv-hero-action'),
                  autofocus: true,
                  onPressed: onOpen,
                  semanticLabel: target?.label ?? 'Open details',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_arrow),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            target?.label ?? 'Open details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
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
  Widget build(BuildContext context) => _TvRail(
    title: title,
    itemCount: items.length,
    builder: (context, index) {
      final item = items[index];
      final target = controller.smartResumeFor(item.media.id);
      return _TvMediaCard(
        title: item.media.title.value,
        subtitle: target?.label ?? item.progressLabel ?? '',
        cover: item.media.coverLocator,
        onPressed: () => _openDetails(context, controller, item.media.id),
      );
    },
  );
}

class _TvSearchRail extends StatelessWidget {
  const _TvSearchRail({
    required this.title,
    required this.items,
    required this.controller,
  });
  final String title;
  final List<ProductSearchResult> items;
  final ProductController controller;

  @override
  Widget build(BuildContext context) => _TvRail(
    title: title,
    itemCount: items.length,
    builder: (context, index) {
      final item = items[index];
      return _TvMediaCard(
        title: item.title,
        subtitle: item.subtitle ?? '${item.sources.length} source(s)',
        cover: item.coverUrl?.toString(),
        onPressed: () => _openResult(context, controller, item),
      );
    },
  );
}

class _TvRail extends StatelessWidget {
  const _TvRail({
    required this.title,
    required this.itemCount,
    required this.builder,
  });
  final String title;
  final int itemCount;
  final NullableIndexedWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: TvTokens.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TvSectionTitle(title),
          SizedBox(
            height: TvTokens.cardHeight + 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: builder,
              separatorBuilder: (_, _) => const SizedBox(width: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _TvMediaCard extends StatelessWidget {
  const _TvMediaCard({
    required this.title,
    required this.subtitle,
    required this.cover,
    required this.onPressed,
    this.focusNode,
  });
  final String title;
  final String subtitle;
  final String? cover;
  final VoidCallback onPressed;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: TvTokens.cardWidth,
    child: TvFocusable(
      focusNode: focusNode,
      onPressed: onPressed,
      semanticLabel: [
        title,
        subtitle,
      ].where((value) => value.isNotEmpty).join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverArt(
            locator: cover,
            width: TvTokens.cardWidth,
            height: TvTokens.cardHeight,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: TvTokens.safeHorizontal,
      vertical: TvTokens.safeVertical,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 20),
        TextField(
          key: const Key('tv-search-field'),
          controller: text,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search manga and anime',
          ),
          onChanged: widget.controller.scheduleSearch,
          onSubmitted: (value) async {
            await widget.controller.submitSearch(value);
            if (mounted && widget.controller.searchResults.isNotEmpty) {
              firstResultFocus.requestFocus();
            }
          },
        ),
        const SizedBox(height: 18),
        Row(
          children: CanonicalMediaKind.values
              .map(
                (kind) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(
                      kind == CanonicalMediaKind.anime ? 'Anime' : 'Manga',
                    ),
                    selected: widget.controller.searchKinds.contains(kind),
                    onSelected: (enabled) =>
                        widget.controller.setSearchKind(kind, enabled),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: GridView.builder(
            key: const Key('tv-search-results'),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisExtent: TvTokens.cardHeight + 72,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: widget.controller.searchResults.length,
            itemBuilder: (context, index) {
              final result = widget.controller.searchResults[index];
              return _TvMediaCard(
                focusNode: index == 0 ? firstResultFocus : null,
                title: result.title,
                subtitle:
                    result.subtitle ?? '${result.sources.length} source(s)',
                cover: result.coverUrl?.toString(),
                onPressed: () =>
                    _openResult(context, widget.controller, result),
              );
            },
          ),
        ),
      ],
    ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TvTokens.safeHorizontal,
        vertical: TvTokens.safeVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Library', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            children: [
              for (final value in _TvLibraryFilter.values)
                FilterChip(
                  label: Text(switch (value) {
                    _TvLibraryFilter.all => 'All',
                    _TvLibraryFilter.anime => 'Anime',
                    _TvLibraryFilter.manga => 'Manga',
                  }),
                  selected: filter == value,
                  onSelected: (_) => setState(() => filter = value),
                ),
              FilterChip(
                label: const Text('A–Z'),
                selected: alphabetical,
                onSelected: (value) => setState(() => alphabetical = value),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: values.isEmpty
                ? const ProductEmptyState(
                    icon: Icons.video_library_outlined,
                    title: 'Your Library is empty',
                    message:
                        'Saved media remains available here even if a source is offline.',
                  )
                : GridView.builder(
                    key: const Key('tv-library-grid'),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          mainAxisExtent: TvTokens.cardHeight + 72,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                    itemCount: values.length,
                    itemBuilder: (context, index) {
                      final item = values[index];
                      return _TvMediaCard(
                        title: item.media.title.value,
                        subtitle: item.hasMissingLocalSource
                            ? 'Needs repair'
                            : widget.controller
                                      .smartResumeFor(item.media.id)
                                      ?.label ??
                                  item.progressLabel ??
                                  '',
                        cover: item.media.coverLocator,
                        onPressed: () => _openDetails(
                          context,
                          widget.controller,
                          item.media.id,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TvSettingsScreen extends StatelessWidget {
  const TvSettingsScreen({
    super.key,
    required this.developerBuilder,
    required this.aboutBuilder,
    required this.appearance,
    required this.onAppearanceChanged,
  });
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
      Text('Settings', style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 24),
      const TvSectionTitle('Appearance'),
      Wrap(
        spacing: 14,
        runSpacing: 14,
        children: ZankaThemeMode.values
            .map(
              (mode) => ChoiceChip(
                label: Text(
                  mode.name[0].toUpperCase() + mode.name.substring(1),
                ),
                selected: appearance.themeMode == mode,
                onSelected: (_) => onAppearanceChanged(mode, appearance.accent),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 14,
        runSpacing: 14,
        children: ZankaAccent.values
            .map(
              (accent) => ChoiceChip(
                label: Text(accent.name),
                selected: appearance.accent == accent,
                onSelected: (_) =>
                    onAppearanceChanged(appearance.themeMode, accent),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 32),
      SizedBox(
        width: 360,
        child: TvFocusable(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: aboutBuilder)),
          child: const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About Zanka'),
          ),
        ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: 360,
        child: TvFocusable(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: developerBuilder)),
          child: const ListTile(
            leading: Icon(Icons.developer_mode),
            title: Text('Developer'),
          ),
        ),
      ),
    ],
  );
}

Future<void> _openDetails(
  BuildContext context,
  ProductController controller,
  CanonicalMediaId id, {
  bool autofocusResume = false,
}) async {
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
  final details = await controller.openResult(result);
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(
        name: '/tv/media/${details.summary.media.id.value}',
      ),
      builder: (_) => TvMediaDetailsScreen(
        controller: controller,
        mediaId: details.summary.media.id,
        initialDetails: details,
      ),
    ),
  );
}
