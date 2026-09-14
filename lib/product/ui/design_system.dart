import 'dart:io';

import 'package:flutter/material.dart';

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
  static const feature = 28.0;
}

/// Editorial framing for the product shell, Settings and content details.
/// Kept local to these surfaces rather than restyling reader/player controls.
class ZankaPageHeading extends StatelessWidget {
  const ZankaPageHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
    this.trailing,
    this.tv = false,
  });

  final String eyebrow;
  final String title;
  final String? description;
  final Widget? trailing;
  final bool tv;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: tv ? 16 : null,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    (tv
                            ? theme.textTheme.displayMedium
                            : theme.textTheme.headlineLarge)
                        ?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
              ),
              if (description != null) ...[
                const SizedBox(height: 10),
                Text(
                  description!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: tv ? 20 : null,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 16), trailing!],
      ],
    );
  }
}

class ZankaSurface extends StatelessWidget {
  const ZankaSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.emphasis = false,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool emphasis;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius:
            borderRadius ?? BorderRadius.circular(ZankaRadius.feature),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            emphasis
                ? Color.alphaBlend(
                    scheme.primary.withValues(alpha: .13),
                    scheme.surfaceContainerLow,
                  )
                : scheme.surfaceContainerLow,
            scheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
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
  const CoverArt({
    super.key,
    this.locator,
    this.width = 88,
    this.height = 124,
    this.cacheWidth,
  });
  final String? locator;
  final double width;
  final double height;
  final int? cacheWidth;
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
                cacheWidth: cacheWidth,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              )
            : uri == null || !uri.hasScheme || uri.host.endsWith('.invalid')
            ? placeholder
            : Image.network(
                uri.toString(),
                cacheWidth: cacheWidth,
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
