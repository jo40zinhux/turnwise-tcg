import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../providers/achievements_providers.dart';

class AchievementTile extends StatelessWidget {
  final AchievementProgress progress;

  const AchievementTile({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final definition = progress.definition;

    return Card(
      elevation: 0,
      color: progress.isUnlocked
          ? theme.colorScheme.primaryContainer.withOpacity(0.2)
          : theme.colorScheme.surfaceContainerHighest.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              getIconFromString(definition.iconCode),
              color: progress.isUnlocked
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.35),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(definition.title, style: AppTypography.label(context)),
                  Text(
                    progress.isUnlocked
                        ? 'Desbloqueada'
                        : '${progress.current}/${definition.target}',
                    style: AppTypography.caption(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
