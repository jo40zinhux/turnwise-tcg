import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Progress indicator showing "Fase X de N · Title" with a linear bar.
///
/// Lives above the phase list so the player always knows where they are
/// in the turn — addresses I6 from the UI/UX review.
class MatchPhaseProgress extends StatelessWidget {
  final int currentPhase;
  final int totalPhases;
  final String currentPhaseTitle;

  const MatchPhaseProgress({
    super.key,
    required this.currentPhase,
    required this.totalPhases,
    required this.currentPhaseTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeTotal = totalPhases <= 0 ? 1 : totalPhases;
    final progress = ((currentPhase + 1) / safeTotal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Fase ${currentPhase + 1} de $totalPhases',
              style: AppTypography.label(context).copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                currentPhaseTitle,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: AppTypography.caption(context),
              ),
            ),
          ],
        ),
        AppSpacing.gapXs,
        ClipRRect(
          borderRadius: AppRadius.smAll,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.6),
                color: theme.colorScheme.primary,
              );
            },
          ),
        ),
      ],
    );
  }
}
