import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';

/// One-line product honesty: tracker vs automatic rule enforcement.
class MatchTrackerNotice extends StatelessWidget {
  final VoidCallback onDismiss;

  const MatchTrackerNotice({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
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
              color: AppTheme.onSurfaceMuted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Tracker de turno. Ações com ícone de info pedem confirmação '
                'manual no tabuleiro.',
                style: AppTypography.caption(context).copyWith(height: 1.35),
              ),
            ),
            Tooltip(
              message: 'Fechar aviso',
              child: Semantics(
                button: true,
                label: 'Fechar aviso do tracker',
                child: IconButton(
                  onPressed: onDismiss,
                  iconSize: 18,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
