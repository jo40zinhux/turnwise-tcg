import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// One-line product honesty: tracker vs automatic rule enforcement.
class MatchTrackerNotice extends StatelessWidget {
  final VoidCallback onDismiss;

  const MatchTrackerNotice({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.track_changes_outlined,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Tracker de turno. Ações com ícone de info pedem confirmação '
                'manual no tabuleiro.',
                style: AppTypography.caption(context).copyWith(height: 1.35),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: onDismiss,
              icon: Icon(
                Icons.close_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
