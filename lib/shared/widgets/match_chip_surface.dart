import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';

/// Visual presets shared by board flags, action chips, and effect chips.
class MatchChipStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide borderSide;

  const MatchChipStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderSide,
  });

  static MatchChipStyle idle(ThemeData theme) {
    return MatchChipStyle(
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      borderSide: BorderSide(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
    );
  }

  static MatchChipStyle selected(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    return MatchChipStyle(
      backgroundColor: primary.withValues(alpha: 0.18),
      foregroundColor: primary,
      borderSide: BorderSide(color: primary.withValues(alpha: 0.6), width: 1.5),
    );
  }

  static MatchChipStyle exhausted(ThemeData theme) {
    return MatchChipStyle(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.6),
      foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.45),
      borderSide: BorderSide(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.18),
      ),
    );
  }

  static MatchChipStyle accent({
    required Color accent,
    required Color accentMuted,
  }) {
    return MatchChipStyle(
      backgroundColor: accentMuted,
      foregroundColor: accent,
      borderSide: BorderSide(color: accent.withValues(alpha: 0.45)),
    );
  }
}

/// Shared bordered chip surface used across the match screen.
class MatchChipSurface extends StatelessWidget {
  final Color backgroundColor;
  final BorderSide borderSide;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final double minHeight;
  final bool expand;
  final bool animate;

  const MatchChipSurface({
    super.key,
    required this.backgroundColor,
    required this.borderSide,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.minHeight = 44,
    this.expand = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: AppRadius.smAll,
      border: Border.fromBorderSide(borderSide),
    );

    final interactive = onTap != null || onLongPress != null;
    final body = interactive
        ? Material(
            color: Colors.transparent,
            borderRadius: AppRadius.smAll,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              borderRadius: AppRadius.smAll,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Padding(padding: padding, child: child),
              ),
            ),
          )
        : ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(padding: padding, child: child),
          );

    final surface = animate && !reduceMotion
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: decoration,
            child: body,
          )
        : DecoratedBox(
            decoration: decoration,
            child: body,
          );

    return SizedBox(
      width: expand ? double.infinity : null,
      child: surface,
    );
  }
}
