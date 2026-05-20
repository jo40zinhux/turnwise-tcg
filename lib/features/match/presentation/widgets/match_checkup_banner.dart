import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/checkup_reminder.dart';

/// Between-turn / triggered reminder surfaced above match actions.
class MatchCheckupBanner extends StatelessWidget {
  final CheckupReminder reminder;
  final VoidCallback onDismiss;

  const MatchCheckupBanner({
    super.key,
    required this.reminder,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: semantic.infoMuted,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: semantic.info.withOpacity(0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications_active_outlined, color: semantic.info),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.title, style: AppTypography.cardTitle(context)),
                AppSpacing.gapXs,
                Text(
                  reminder.message,
                  style: AppTypography.bodyMuted(context),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Marcar como feito',
          ),
        ],
      ),
    );
  }
}
