import 'package:flutter/material.dart';

/// The same four destinations, expressed as a touch dock or a remote/keyboard
/// sidebar. Layout is selected by the shell; this widget never infers TV mode.
class ZankaNavigation extends StatelessWidget {
  const ZankaNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.vertical = false,
    this.tv = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool vertical;
  final bool tv;

  static const _destinations = [
    ('Home', Icons.home_outlined, Icons.home_rounded),
    ('Search', Icons.search_rounded, Icons.search_rounded),
    ('Library', Icons.bookmarks_outlined, Icons.bookmarks_rounded),
    ('Settings', Icons.tune_rounded, Icons.tune_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final compact = tv && MediaQuery.sizeOf(context).width < 1100;
    final destinations = [
      for (var index = 0; index < _destinations.length; index++)
        _NavigationItem(
          label: _destinations[index].$1,
          icon: index == selectedIndex
              ? _destinations[index].$3
              : _destinations[index].$2,
          selected: index == selectedIndex,
          vertical: vertical && !compact,
          tv: tv,
          onPressed: () => onSelected(index),
        ),
    ];
    if (vertical) {
      return SizedBox(
        height: double.infinity,
        width: compact
            ? 112
            : tv
            ? 188
            : 204,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            compact ? 8 : 16,
            28,
            compact ? 8 : 16,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(compact ? 0 : 14, 0, 0, 36),
                child: Column(
                  crossAxisAlignment: compact
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      color: scheme.primary,
                      size: 30,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ZANKA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: compact ? 1 : 2,
                        fontSize: compact ? 17 : null,
                      ),
                    ),
                    Text(
                      'NO TACHI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 2,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              for (final destination in destinations) ...[
                destination,
                SizedBox(height: tv ? 12 : 8),
              ],
            ],
          ),
        ),
      );
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Material(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    for (final destination in destinations)
                      Expanded(child: destination),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatefulWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.vertical,
    required this.tv,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final bool vertical;
  final bool tv;
  final VoidCallback onPressed;

  @override
  State<_NavigationItem> createState() => _NavigationItemState();
}

class _NavigationItemState extends State<_NavigationItem> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = focused
        ? scheme.onPrimary
        : widget.selected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final label = Text(
      widget.label,
      style: TextStyle(
        color: foreground,
        fontSize: widget.tv
            ? 18
            : widget.vertical
            ? 15
            : 12,
        fontWeight: widget.selected || focused
            ? FontWeight.w700
            : FontWeight.w500,
      ),
    );
    return Semantics(
      label: widget.label,
      selected: widget.selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('nav-${widget.label.toLowerCase()}'),
          borderRadius: BorderRadius.circular(widget.vertical ? 20 : 22),
          onTap: widget.onPressed,
          onFocusChange: (value) => setState(() => focused = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            constraints: BoxConstraints(minHeight: widget.tv ? 68 : 62),
            padding: EdgeInsets.symmetric(
              horizontal: widget.vertical ? 14 : 4,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: focused
                  ? scheme.primary
                  : widget.selected
                  ? scheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(widget.vertical ? 20 : 22),
              boxShadow: focused
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: .24),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: ExcludeSemantics(
              child: widget.vertical
                  ? Row(
                      children: [
                        Icon(
                          widget.icon,
                          color: foreground,
                          size: widget.tv ? 26 : 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: label),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, color: foreground, size: 24),
                        const SizedBox(height: 4),
                        label,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
