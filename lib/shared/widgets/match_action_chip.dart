import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_semantic_colors.dart';
import '../../core/theme/app_typography.dart';
import 'match_chip_surface.dart';

/// Action chip used inside the match screen.
///
/// Visual states:
/// - **idle**: outlined surface, ready to be tapped.
/// - **used**: primary tint, check icon, still tappable (action allows reuse).
/// - **exhausted**: dimmed; tap may undo (max=1) or trigger [onExhaustedTap].
class MatchActionChip extends StatelessWidget {
  final String label;
  final bool isUsed;
  final bool isExhausted;
  final bool canUndoOnTap;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final VoidCallback? onExhaustedTap;
  final bool expand;
  final bool showReminderBadge;

  const MatchActionChip({
    super.key,
    required this.label,
    required this.isUsed,
    required this.isExhausted,
    this.canUndoOnTap = false,
    required this.onPressed,
    this.onLongPress,
    this.onExhaustedTap,
    this.expand = false,
    this.showReminderBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final semantic = context.semantic;

    final style = _resolveStyle(theme);
    final iconColor = isUsed && (!isExhausted || canUndoOnTap)
        ? primary
        : semantic.success;

    void handleTap() {
      if (canUndoOnTap) {
        HapticFeedback.lightImpact();
        onPressed();
        return;
      }
      if (isExhausted) {
        onExhaustedTap?.call();
        return;
      }
      onPressed();
    }

    void handleLongPress() {
      HapticFeedback.mediumImpact();
      onLongPress?.call();
    }

    final chip = MatchChipSurface(
      backgroundColor: style.backgroundColor,
      borderSide: style.borderSide,
      onTap: handleTap,
      onLongPress: onLongPress != null ? handleLongPress : null,
      expand: expand,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (isUsed) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.check_circle,
                size: 16,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              label,
              softWrap: true,
              style: AppTypography.label(context).copyWith(
                fontWeight: isUsed ? FontWeight.w600 : FontWeight.w500,
                color: style.foregroundColor,
                height: 1.3,
              ),
            ),
          ),
          if (isExhausted && !canUndoOnTap)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 2),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: style.foregroundColor,
              ),
            )
          else if (showReminderBadge)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 2),
              child: Icon(
                Icons.info_outline_rounded,
                size: 14,
                  color: theme.colorScheme.primary.withValues(alpha: 0.85),
              ),
            ),
        ],
      ),
    );

    final accessible = Semantics(
      label: label,
      enabled: !isExhausted || canUndoOnTap,
      button: true,
      child: chip,
    );

    final tooltip = _tooltipMessage();
    if (tooltip == null) return accessible;
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: accessible,
    );
  }

  MatchChipStyle _resolveStyle(ThemeData theme) {
    if (isExhausted && !canUndoOnTap) {
      return MatchChipStyle.exhausted(theme);
    }
    if (isUsed) {
      return MatchChipStyle.selected(theme);
    }
    return MatchChipStyle.idle(theme);
  }

  String? _tooltipMessage() {
    if (canUndoOnTap) return 'Toca para desfazer';
    if (onLongPress != null && isUsed) {
      return 'Mantém pressionado para desfazer';
    }
    if (onLongPress != null && showReminderBadge) {
      return 'Mantém pressionado para ver a regra';
    }
    if (isExhausted) return 'Limite atingido neste turno';
    if (showReminderBadge) {
      return 'Regista a ação e confirma a regra no tabuleiro';
    }
    return null;
  }
}
