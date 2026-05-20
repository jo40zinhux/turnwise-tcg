import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/icon_mapper.dart';
import '../../features/match/domain/turn_phase.dart';

class PhaseTile extends StatelessWidget {
  final TurnPhase phase;
  final bool isCurrent;
  final bool isPast;

  const PhaseTile({
    super.key,
    required this.phase,
    required this.isCurrent,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor = theme.colorScheme.surface;
    Color iconColor = theme.colorScheme.onSurface.withOpacity(0.54);
    TextStyle titleStyle = AppTypography.body(context).copyWith(
      fontWeight: FontWeight.w500,
      color: iconColor,
      decoration: isPast ? TextDecoration.lineThrough : null,
    );

    if (isCurrent) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.15);
      iconColor = theme.colorScheme.primary;
      titleStyle = AppTypography.body(context).copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      );
    } else if (isPast) {
      iconColor = theme.colorScheme.primary.withOpacity(0.5);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.mdAll,
        border: isCurrent
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 1.5,
              )
            : Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              isPast ? Icons.check_circle_rounded : getIconFromString(phase.iconCode),
              key: ValueKey(isPast),
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase.title, style: titleStyle),
                if (isCurrent) ...[
                  AppSpacing.gapXs,
                  Text(phase.description, style: AppTypography.caption(context)),
                ],
              ],
            ),
          ),
          if (isCurrent)
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, size: 20),
              color: theme.colorScheme.primary,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(phase.title, style: AppTypography.title(ctx)),
                    content: Text(
                      phase.description,
                      style: AppTypography.bodyMuted(ctx),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Entendi'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
