import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'match_chip_surface.dart';
import '../../core/theme/app_typography.dart';

/// Toggle chip for board target flags inside [MatchBoardPanel].
///
/// Matches the match action chip vocabulary with a 44pt minimum hit area.
class BoardFlagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const BoardFlagChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = isSelected
        ? MatchChipStyle.selected(theme)
        : MatchChipStyle.idle(theme);

    void handleTap() {
      HapticFeedback.selectionClick();
      onPressed();
    }

    return Tooltip(
      message: isSelected ? 'Toca para desmarcar' : 'Toca para marcar',
      preferBelow: false,
      child: Semantics(
        button: true,
        toggled: isSelected,
        label: isSelected ? '$label, marcado' : label,
        child: MatchChipSurface(
          backgroundColor: style.backgroundColor,
          borderSide: style.borderSide,
          onTap: handleTap,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isSelected) ...[
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: style.foregroundColor,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  softWrap: true,
                  style: AppTypography.label(context).copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: style.foregroundColor,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
