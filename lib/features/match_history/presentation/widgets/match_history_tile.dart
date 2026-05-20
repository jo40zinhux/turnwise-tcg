import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_format.dart';
import '../../domain/match_outcome.dart';
import '../../domain/match_outcome_labels.dart';
import '../../domain/match_record.dart';

class MatchHistoryTile extends StatelessWidget {
  final String gameName;
  final MatchRecord record;

  const MatchHistoryTile({
    super.key,
    required this.gameName,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    gameName,
                    style: AppTypography.cardTitle(context),
                  ),
                ),
                _OutcomeChip(outcome: record.outcome),
              ],
            ),
            AppSpacing.gapSm,
            Text(
              _formatEndedAt(record.endedAt),
              style: AppTypography.caption(context),
            ),
            AppSpacing.gapXs,
            Text(
              'Duração: ${DurationFormat.short(record.duration)}',
              style: AppTypography.caption(context),
            ),
            if (record.notes != null) ...[
              AppSpacing.gapSm,
              Text(
                record.notes!,
                style: AppTypography.bodyMuted(context),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatEndedAt(DateTime date) {
  const months = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.day} ${months[date.month - 1]} ${date.year} · $hour:$minute';
}

class _OutcomeChip extends StatelessWidget {
  final MatchOutcome outcome;

  const _OutcomeChip({required this.outcome});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;

    final (background, foreground) = switch (outcome) {
      MatchOutcome.playerWin => (semantic.successMuted, semantic.success),
      MatchOutcome.playerLoss => (semantic.dangerMuted, semantic.danger),
      MatchOutcome.draw => (semantic.infoMuted, semantic.info),
      MatchOutcome.abandoned => (
          theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
          semantic.warning,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        MatchOutcomeLabels.label(outcome),
        style: AppTypography.caption(context).copyWith(
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
