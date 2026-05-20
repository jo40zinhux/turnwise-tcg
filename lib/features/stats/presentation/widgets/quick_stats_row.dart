import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/duration_format.dart';
import '../../domain/match_stats.dart';
import 'stat_metric_card.dart';

class QuickStatsRow extends StatelessWidget {
  final MatchStats stats;
  final VoidCallback? onTap;

  const QuickStatsRow({
    super.key,
    required this.stats,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final winRateLabel = stats.winRatePercent != null
        ? '${stats.winRatePercent!.toStringAsFixed(0)}%'
        : '—';
    final avgDurationLabel = stats.averageDuration != null
        ? DurationFormat.short(stats.averageDuration!)
        : '—';

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('As tuas estatísticas', style: AppTypography.label(context)),
            const Spacer(),
            if (onTap != null)
              TextButton(
                onPressed: onTap,
                child: const Text('Ver tudo'),
              ),
          ],
        ),
        AppSpacing.gapSm,
        Row(
          children: [
            StatMetricCard(
              label: 'Esta semana',
              value: '${stats.matchesThisWeek}',
              icon: Icons.calendar_today_rounded,
            ),
            AppSpacing.gapMd,
            StatMetricCard(
              label: 'Winrate',
              value: winRateLabel,
              icon: Icons.emoji_events_outlined,
            ),
            AppSpacing.gapMd,
            StatMetricCard(
              label: 'Tempo médio',
              value: avgDurationLabel,
              icon: Icons.timer_outlined,
            ),
          ],
        ),
      ],
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: content,
      ),
    );
  }
}
