import 'package:flutter/material.dart';

import '../../app/app_preferences.dart';
import '../../tv/tv_design_system.dart';
import 'design_system.dart';

/// Settings-specific category entry, shared by touch and remote layouts.
class SettingsCategoryPanel extends StatelessWidget {
  const SettingsCategoryPanel({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
    this.emphasis = false,
    this.tv = false,
    this.autofocus = false,
    this.detail,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool emphasis;
  final bool tv;
  final bool autofocus;
  final Widget? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final content = Padding(
      padding: EdgeInsets.all(tv ? 28 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: tv ? 32 : 28, color: scheme.primary),
              const Spacer(),
              Icon(Icons.arrow_outward_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
          SizedBox(height: tv ? 30 : 20),
          Text(
            title,
            style:
                (tv
                        ? theme.textTheme.headlineSmall
                        : theme.textTheme.titleLarge)
                    ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: (tv ? theme.textTheme.bodyLarge : theme.textTheme.bodyMedium)
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (detail != null) ...[const SizedBox(height: 18), detail!],
        ],
      ),
    );
    if (tv) {
      return TvFocusable(
        autofocus: autofocus,
        onPressed: onPressed,
        borderRadius: 28,
        child: content,
      );
    }
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              emphasis ? scheme.primaryContainer : scheme.surfaceContainerLow,
              scheme.surfaceContainerLow,
            ],
          ),
        ),
        child: InkWell(onTap: onPressed, child: content),
      ),
    );
  }
}

class SettingsAction extends StatelessWidget {
  const SettingsAction({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.tv = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool tv;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: tv ? 24 : 20),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: tv ? 30 : 24),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tv
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
    if (tv) {
      return TvFocusable(
        onPressed: onPressed,
        borderRadius: 24,
        child: content,
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        onLongPress: onLongPress,
        child: content,
      ),
    );
  }
}

/// A real route: system Back returns to the category landing, not out of Settings.
class SettingsDetailPage extends StatelessWidget {
  const SettingsDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.child,
    this.tv = false,
  });

  final String title;
  final String description;
  final Widget child;
  final bool tv;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tv ? 1100 : 860),
          child: ListView(
            padding: EdgeInsets.all(tv ? 40 : 24),
            children: [
              const Align(alignment: Alignment.centerLeft, child: BackButton()),
              const SizedBox(height: 16),
              ZankaPageHeading(
                eyebrow: 'SETTINGS',
                title: title,
                description: description,
                tv: tv,
              ),
              const SizedBox(height: 30),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({
    super.key,
    required this.appearance,
    required this.onAppearanceChanged,
    this.tv = false,
  });

  final AppPreferences appearance;
  final Future<void> Function(ZankaThemeMode, ZankaAccent) onAppearanceChanged;
  final bool tv;

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  late AppPreferences appearance = widget.appearance;
  bool saving = false;

  Future<void> _change(ZankaThemeMode mode, ZankaAccent accent) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await widget.onAppearanceChanged(mode, accent);
      if (mounted) {
        setState(
          () =>
              appearance = appearance.copyWith(themeMode: mode, accent: accent),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SettingsDetailPage(
      title: 'Appearance',
      description: 'Set the mood. Your look stays on this device.',
      tv: widget.tv,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Light & shade', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 430;
              final options = [
                for (final mode in ZankaThemeMode.values)
                  SizedBox(
                    width: compact
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 24) / 3,
                    child: _AppearanceOption(
                      key: ValueKey('theme-${mode.name}'),
                      label: switch (mode) {
                        ZankaThemeMode.system => 'System',
                        ZankaThemeMode.light => 'Light',
                        ZankaThemeMode.dark => 'Dark',
                      },
                      icon: switch (mode) {
                        ZankaThemeMode.system => Icons.brightness_auto_outlined,
                        ZankaThemeMode.light => Icons.light_mode_outlined,
                        ZankaThemeMode.dark => Icons.dark_mode_outlined,
                      },
                      selected: appearance.themeMode == mode,
                      tv: widget.tv,
                      onPressed: saving
                          ? null
                          : () => _change(mode, appearance.accent),
                    ),
                  ),
              ];
              return Wrap(spacing: 12, runSpacing: 12, children: options);
            },
          ),
          const SizedBox(height: 36),
          Text('Accent color', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'One quiet signature across Zanka.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final accent in ZankaAccent.values)
                _AppearanceOption(
                  key: ValueKey('accent-${accent.name}'),
                  label: settingsAccentLabel(accent),
                  color: zankaAccentColor(accent),
                  selected: appearance.accent == accent,
                  tv: widget.tv,
                  onPressed: saving
                      ? null
                      : () => _change(appearance.themeMode, accent),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.tv,
    this.icon,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final bool tv;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: tv ? 22 : 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (color != null)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          else
            Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: tv
                  ? theme.textTheme.titleLarge
                  : theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 20,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ],
      ),
    );
    return Semantics(
      selected: selected,
      child: tv
          ? TvFocusable(onPressed: onPressed, borderRadius: 20, child: body)
          : Material(
              color: selected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onPressed,
                child: body,
              ),
            ),
    );
  }
}

String settingsAccentLabel(ZankaAccent accent) => switch (accent) {
  ZankaAccent.defaultRed => 'Zanka red',
  ZankaAccent.orange => 'Orange',
  ZankaAccent.green => 'Green',
  ZankaAccent.teal => 'Teal',
  ZankaAccent.blue => 'Blue',
  ZankaAccent.indigo => 'Indigo',
  ZankaAccent.purple => 'Purple',
};
