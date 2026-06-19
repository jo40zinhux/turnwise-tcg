import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Turn position in the pinned header: "Fase X de N" and a linear progress bar.
///
/// Phase names and descriptions live on [PhaseTile] in the scroll body —
/// this widget only answers where you are in the sequence.
class MatchPhaseProgress extends StatelessWidget {
  final int currentPhase;
  final int totalPhases;

  const MatchPhaseProgress({
    super.key,
    required this.currentPhase,
    required this.totalPhases,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeTotal = totalPhases <= 0 ? 1 : totalPhases;
    final progress = ((currentPhase + 1) / safeTotal).clamp(0.0, 1.0);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: 'Fase ${currentPhase + 1} de $totalPhases',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Fase ${currentPhase + 1} de $totalPhases',
            style: AppTypography.label(context).copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          AppSpacing.gapXs,
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: reduceMotion
                ? LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.6),
                    color: theme.colorScheme.primary,
                  )
                : TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: theme.colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.6),
                        color: theme.colorScheme.primary,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
