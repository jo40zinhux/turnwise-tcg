import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_semantic_colors.dart';
import '../../core/theme/app_typography.dart';

/// Action chip used inside the match screen.
///
/// Visual states:
/// - **idle**: outlined surface, ready to be tapped.
/// - **used**: primary tint, check icon, still tappable (action allows reuse).
/// - **exhausted**: dimmed, ripple disabled. Tapping triggers [onExhaustedTap]
///   for soft feedback (haptic) without firing an engine error snackbar.
class MatchActionChip extends StatelessWidget {
  final String label;
  final bool isUsed;
  final bool isExhausted;
  final VoidCallback onPressed;
  final VoidCallback? onExhaustedTap;
  final bool expand;

  const MatchActionChip({
    super.key,
    required this.label,
    required this.isUsed,
    required this.isExhausted,
    required this.onPressed,
    this.onExhaustedTap,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final semantic = context.semantic;

    Color backgroundColor = theme.colorScheme.surface;
    Color foregroundColor = theme.colorScheme.onSurface;
    BorderSide borderSide = BorderSide(
      color: theme.colorScheme.outlineVariant.withOpacity(0.3),
    );

    if (isExhausted) {
      backgroundColor = theme.colorScheme.surface.withOpacity(0.6);
      foregroundColor = theme.colorScheme.onSurface.withOpacity(0.45);
      borderSide = BorderSide(
        color: theme.colorScheme.outlineVariant.withOpacity(0.18),
      );
    } else if (isUsed) {
      backgroundColor = primary.withOpacity(0.18);
      foregroundColor = primary;
      borderSide = BorderSide(color: primary.withOpacity(0.6), width: 1.5);
    }

    final tooltip = isExhausted ? 'Limite atingido neste turno' : null;
    final iconColor = isUsed && !isExhausted ? primary : semantic.success;

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.smAll,
        border: Border.fromBorderSide(borderSide),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: isExhausted ? onExhaustedTap : onPressed,
          borderRadius: AppRadius.smAll,
          excludeFromSemantics: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
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
                      color: foregroundColor,
                      height: 1.3,
                    ),
                  ),
                ),
                if (isExhausted)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 2),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: foregroundColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    final accessible = Semantics(
      label: label,
      enabled: !isExhausted,
      button: true,
      child: SizedBox(
        width: expand ? double.infinity : null,
        child: chip,
      ),
    );

    if (tooltip == null) return accessible;
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: accessible,
    );
  }
}
