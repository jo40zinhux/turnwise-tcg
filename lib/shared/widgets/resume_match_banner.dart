import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ResumeMatchBanner extends StatelessWidget {
  final String gameName;
  final VoidCallback onResume;
  final VoidCallback onDismiss;

  const ResumeMatchBanner({
    super.key,
    required this.gameName,
    required this.onResume,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.play_circle_outline, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Partida em andamento',
                    style: AppTypography.cardTitle(context),
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Descartar partida',
                ),
              ],
            ),
            AppSpacing.gapXs,
            Text(
              'Continuar $gameName',
              style: AppTypography.bodyMuted(context),
            ),
            AppSpacing.gapMd,
            ElevatedButton(
              onPressed: onResume,
              child: const Text('Retomar partida'),
            ),
          ],
        ),
      ),
    );
  }
}
