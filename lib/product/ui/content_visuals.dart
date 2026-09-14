import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../canonical/domain/media.dart';
import '../../tv/tv_design_system.dart';
import '../product_models.dart';
import 'design_system.dart';

/// Content-only visuals shared by the touch shell and semantic TV shell.
/// Navigation, source requests and saved state remain with their callers.
class StoryTile extends StatelessWidget {
  const StoryTile({
    super.key,
    required this.title,
    required this.kind,
    required this.onOpen,
    required this.actionKey,
    this.cover,
    this.metadata = '',
    this.status = '',
    this.favorite = false,
    this.saved = false,
    this.needsRepair = false,
    this.tv = false,
    this.focusNode,
  });

  final String title;
  final CanonicalMediaKind kind;
  final VoidCallback onOpen;
  final Key actionKey;
  final String? cover;
  final String metadata;
  final String status;
  final bool favorite, saved, needsRepair, tv;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context);
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              StoryArtwork(locator: cover, title: title, kind: kind),
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .76),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: Text(
                          kind == CanonicalMediaKind.manga ? 'MANGA' : 'ANIME',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: tv ? 14 : 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (favorite || saved)
                      DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            favorite
                                ? Icons.favorite_rounded
                                : Icons.bookmark_rounded,
                            color: Colors.white,
                            size: tv ? 20 : 16,
                            semanticLabel: favorite ? 'Favorite' : 'In Library',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(tv ? 12 : 4, 12, tv ? 12 : 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: textScale.scale(tv ? 21 : 16) * 2.4,
                ),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: tv ? 21 : 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -.3,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: textScale.scale(tv ? 16 : 12) * 2.6,
                ),
                child: Text(
                  metadata,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: tv ? 16 : 12,
                    color: scheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                needsRepair ? 'Needs repair' : status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: tv ? 16 : 12,
                  fontWeight: FontWeight.w600,
                  color: needsRepair ? scheme.error : scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return _StoryAction(
      actionKey: actionKey,
      tv: tv,
      focusNode: focusNode,
      onOpen: onOpen,
      label: [
        title,
        kind.name,
        metadata,
        if (needsRepair) 'Needs repair' else status,
        if (favorite) 'Favorite',
        if (saved) 'In Library',
      ].where((s) => s.isNotEmpty).join(', '),
      child: child,
    );
  }
}

class StoryArtwork extends StatelessWidget {
  const StoryArtwork({
    super.key,
    required this.title,
    required this.kind,
    this.locator,
  });
  final String title;
  final CanonicalMediaKind kind;
  final String? locator;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (locator != null && locator!.isNotEmpty) {
          return CoverArt(
            locator: locator,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            cacheWidth:
                (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                    .round()
                    .clamp(1, 1024),
          );
        }
        final scheme = Theme.of(context).colorScheme;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primaryContainer, scheme.surfaceContainerHigh],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 16,
                top: 52,
                bottom: 18,
                child: Container(
                  width: 2,
                  color: scheme.primary.withValues(alpha: .25),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title.trim().isEmpty
                          ? 'Z'
                          : title.trim().characters.first.toUpperCase(),
                      style: TextStyle(
                        fontSize: 104,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'serif',
                        color: scheme.onPrimaryContainer.withValues(alpha: .55),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: Icon(
                  kind == CanonicalMediaKind.manga
                      ? Icons.auto_stories_outlined
                      : Icons.play_circle_outline,
                  size: 28,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class StoryFeature extends StatelessWidget {
  const StoryFeature({
    super.key,
    required this.item,
    required this.onOpen,
    required this.actionKey,
    required this.label,
    this.detail = '',
    this.tv = false,
    this.autofocus = false,
  });
  final ProductMediaSummary item;
  final VoidCallback onOpen;
  final Key actionKey;
  final String label, detail;
  final bool tv, autofocus;

  @override
  Widget build(BuildContext context) => _StoryAction(
    actionKey: actionKey,
    tv: tv,
    autofocus: autofocus,
    onOpen: onOpen,
    label: '${item.media.title.value}, $label, $detail',
    child: ZankaSurface(
      emphasis: true,
      padding: EdgeInsets.all(tv ? 24 : 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(
            tv ? 170.0 : 112.0,
            constraints.maxWidth * .32,
          );
          return Row(
            children: [
              SizedBox(
                width: width,
                height: width * 1.4,
                child: StoryArtwork(
                  title: item.media.title.value,
                  kind: item.media.kind,
                  locator: item.media.coverLocator,
                ),
              ),
              SizedBox(width: tv ? 28 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.media.kind == CanonicalMediaKind.manga
                          ? 'BACK TO THE PAGE'
                          : 'BACK TO THE STORY',
                      style: TextStyle(
                        fontSize: tv ? 15 : 10,
                        letterSpacing: 1.2,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.media.title.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: tv ? 32 : 21,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.6,
                      ),
                    ),
                    if (detail.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        detail,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: tv ? 20 : 13,
                          height: 1.4,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Icon(
                          item.media.kind == CanonicalMediaKind.manga
                              ? Icons.menu_book_rounded
                              : Icons.play_arrow_rounded,
                          size: tv ? 28 : 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: tv ? 20 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _StoryAction extends StatelessWidget {
  const _StoryAction({
    required this.actionKey,
    required this.tv,
    required this.onOpen,
    required this.label,
    required this.child,
    this.focusNode,
    this.autofocus = false,
  });
  final Key actionKey;
  final bool tv, autofocus;
  final VoidCallback onOpen;
  final String label;
  final Widget child;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) => tv
      ? TvFocusable(
          key: actionKey,
          onPressed: onOpen,
          semanticLabel: label,
          focusNode: focusNode,
          autofocus: autofocus,
          borderRadius: 20,
          child: ExcludeSemantics(child: child),
        )
      : Semantics(
          button: true,
          label: label,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: actionKey,
              onTap: onOpen,
              borderRadius: BorderRadius.circular(20),
              child: ExcludeSemantics(child: child),
            ),
          ),
        );
}

double storyTileHeight(BuildContext context, double width, {bool tv = false}) {
  final scale = MediaQuery.textScalerOf(context);
  return width * 1.22 +
      scale.scale(tv ? 21 : 16) * 2.4 +
      scale.scale(tv ? 16 : 12) * 4 +
      44;
}

class StorySliverGrid extends StatelessWidget {
  const StorySliverGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.tv = false,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool tv;
  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      final scale = (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(
        1.0,
        1.4,
      );
      final gap = tv ? 24.0 : 16.0;
      final columns =
          ((constraints.crossAxisExtent + gap) /
                  ((tv ? 230 : 140) * scale + gap))
              .floor()
              .clamp(1, tv ? 6 : 8);
      final width =
          (constraints.crossAxisExtent - gap * (columns - 1)) / columns;
      return SliverGrid.builder(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
          mainAxisExtent: storyTileHeight(context, width, tv: tv),
        ),
      );
    },
  );
}

class StoryRail extends StatelessWidget {
  const StoryRail({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.tv = false,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final bool tv;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = (MediaQuery.textScalerOf(context).scale(16) / 16).clamp(
        1.0,
        1.3,
      );
      final width = math.min(
        (tv ? 230 : 166) * scale,
        constraints.maxWidth * .8,
      );
      return SizedBox(
        height: storyTileHeight(context, width, tv: tv) + 20,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: tv ? 12 : 24, vertical: 10),
          itemCount: itemCount,
          separatorBuilder: (_, _) => SizedBox(width: tv ? 24 : 16),
          itemBuilder: (context, index) =>
              SizedBox(width: width, child: itemBuilder(context, index)),
        ),
      );
    },
  );
}

class StorySection extends StatelessWidget {
  const StorySection(this.title, {super.key, this.action, this.tv = false});
  final String title;
  final Widget? action;
  final bool tv;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(tv ? 12 : 24, 28, tv ? 12 : 24, 12),
    child: Row(
      children: [
        Container(
          width: 3,
          height: tv ? 26 : 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: tv ? 27 : 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -.4,
            ),
          ),
        ),
        if (action != null) action!,
      ],
    ),
  );
}

class StoryNotice extends StatelessWidget {
  const StoryNotice({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.icon = Icons.auto_stories_outlined,
    this.tv = false,
    this.compact = false,
  });
  final String title, message;
  final Widget? action;
  final IconData icon;
  final bool tv, compact;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: ZankaSurface(
      padding: EdgeInsets.all(compact ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: tv ? 32 : 24,
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: tv ? (compact ? 20 : 28) : (compact ? 15 : 22),
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: tv ? 20 : 15,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...[SizedBox(height: compact ? 4 : 16), action!],
        ],
      ),
    ),
  );
}

String storySources(int count) => '$count source${count == 1 ? '' : 's'}';
String storyMetadata(ProductMediaSummary item) => [
  if (item.media case CanonicalAnime(:final format)) format.name.toUpperCase(),
  item.media.status.name,
  storySources(item.bindings.length),
].join(' · ');
String storyLibraryStatus(ProductMediaSummary item) =>
    switch (item.library?.status.name) {
      'inProgress' => 'In progress',
      final String value => value[0].toUpperCase() + value.substring(1),
      _ => '',
    };
