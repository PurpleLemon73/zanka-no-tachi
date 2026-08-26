import 'dart:io';

import 'package:flutter/material.dart';

import '../../canonical/domain/media.dart';
import '../product_models.dart';
import '../../app/app_preferences.dart';

abstract final class ZankaSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class ZankaRadius {
  static const card = 20.0;
  static const chip = 12.0;
}

Color zankaAccentColor(ZankaAccent accent) => switch (accent) {
  ZankaAccent.defaultRed => const Color(0xFFB53A32),
  ZankaAccent.orange => const Color(0xFF9A4600),
  ZankaAccent.green => const Color(0xFF386A20),
  ZankaAccent.teal => const Color(0xFF006A60),
  ZankaAccent.blue => const Color(0xFF245FA6),
  ZankaAccent.indigo => const Color(0xFF4D5FA8),
  ZankaAccent.purple => const Color(0xFF7A4E9D),
};

ThemeData zankaTheme(
  Brightness brightness, {
  ZankaAccent accent = ZankaAccent.defaultRed,
}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: zankaAccentColor(accent),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ZankaRadius.card),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ZankaRadius.card),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class ZankaSectionTitle extends StatelessWidget {
  const ZankaSectionTitle(this.title, {super.key, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      ZankaSpace.md,
      ZankaSpace.lg,
      ZankaSpace.md,
      ZankaSpace.sm,
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null) action!,
      ],
    ),
  );
}

class SourceBadge extends StatelessWidget {
  const SourceBadge(this.label, {super.key, this.selected = false});
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(selected ? Icons.check_circle : Icons.hub_outlined, size: 16),
    label: Text(label),
    visualDensity: VisualDensity.compact,
  );
}

class ProductEmptyState extends StatelessWidget {
  const ProductEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(ZankaSpace.xl),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: ZankaSpace.md),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: ZankaSpace.sm),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: ZankaSpace.md),
            action!,
          ],
        ],
      ),
    ),
  );
}

class CoverArt extends StatelessWidget {
  const CoverArt({super.key, this.locator, this.width = 88, this.height = 124});
  final String? locator;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    final uri = locator == null ? null : Uri.tryParse(locator!);
    final placeholder = Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.auto_stories_outlined),
    );
    return Semantics(
      label: 'Cover image',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ZankaRadius.chip),
        child:
            locator != null &&
                (uri?.scheme == 'file' || File(locator!).isAbsolute)
            ? Image.file(
                File(uri?.scheme == 'file' ? uri!.toFilePath() : locator!),
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              )
            : uri == null || !uri.hasScheme || uri.host.endsWith('.invalid')
            ? placeholder
            : Image.network(
                uri.toString(),
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
                loadingBuilder: (context, child, loading) => loading == null
                    ? child
                    : SizedBox(
                        width: width,
                        height: height,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
              ),
      ),
    );
  }
}

class CanonicalMediaCard extends StatelessWidget {
  const CanonicalMediaCard({
    super.key,
    required this.summary,
    required this.onTap,
  });
  final ProductMediaSummary summary;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        '${summary.media.title.value}, ${_mediaLabel(summary.media)}, '
        '${summary.bindings.length} sources${summary.isSaved ? ', in Library' : ''}',
    child: Card(
      child: InkWell(
        key: ValueKey('media-card-${summary.media.id.value}'),
        borderRadius: BorderRadius.circular(ZankaRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(ZankaSpace.sm),
          child: Row(
            children: [
              CoverArt(
                locator: summary.media.coverLocator,
                width: 72,
                height: 100,
              ),
              const SizedBox(width: ZankaSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.media.title.value,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: ZankaSpace.xs),
                    Text(_mediaLabel(summary.media)),
                    const SizedBox(height: ZankaSpace.sm),
                    Wrap(
                      spacing: ZankaSpace.xs,
                      children: [
                        SourceBadge(
                          '${summary.bindings.length} source${summary.bindings.length == 1 ? '' : 's'}',
                        ),
                        if (summary.isSaved)
                          const Chip(label: Text('In Library')),
                        if (summary.isFavorite)
                          const Icon(Icons.favorite, semanticLabel: 'Favorite'),
                        if (summary.hasMissingLocalSource)
                          const Chip(
                            avatar: Icon(Icons.link_off, size: 16),
                            label: Text('Needs repair'),
                          ),
                      ],
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
}

String _mediaLabel(CanonicalMedia media) => switch (media) {
  CanonicalManga() => 'Manga · ${media.status.name}',
  CanonicalAnime(:final format) =>
    '${format.name.toUpperCase()} · ${media.status.name}',
};
