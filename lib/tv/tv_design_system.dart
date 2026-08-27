import 'package:flutter/material.dart';

abstract final class TvTokens {
  static const safeHorizontal = 48.0;
  static const safeVertical = 32.0;
  static const railWidth = 112.0;
  static const cardWidth = 190.0;
  static const cardHeight = 270.0;
  static const heroHeight = 300.0;
  static const sectionGap = 28.0;
  static const focusScale = 1.055;
  static const focusBorder = 3.0;
  static const animation = Duration(milliseconds: 140);
}

class TvFocusable extends StatefulWidget {
  const TvFocusable({
    super.key,
    required this.child,
    required this.onPressed,
    this.autofocus = false,
    this.semanticLabel,
    this.borderRadius = 16,
    this.padding = EdgeInsets.zero,
    this.focusNode,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool autofocus;
  final String? semanticLabel;
  final double borderRadius;
  final EdgeInsets padding;
  final FocusNode? focusNode;

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: widget.onPressed != null,
      label: widget.semanticLabel,
      child: AnimatedScale(
        scale: focused ? TvTokens.focusScale : 1,
        duration: TvTokens.animation,
        child: AnimatedContainer(
          duration: TvTokens.animation,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: focused
                ? scheme.primaryContainer.withValues(alpha: 0.88)
                : scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: focused ? scheme.primary : Colors.transparent,
              width: TvTokens.focusBorder,
            ),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.4),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                : const [],
          ),
          child: InkWell(
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            canRequestFocus: widget.onPressed != null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onFocusChange: (value) {
              setState(() => focused = value);
              if (value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Scrollable.ensureVisible(
                      context,
                      alignment: 0.5,
                      duration: TvTokens.animation,
                    );
                  }
                });
              }
            },
            onTap: widget.onPressed,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class TvSectionTitle extends StatelessWidget {
  const TvSectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
  );
}
