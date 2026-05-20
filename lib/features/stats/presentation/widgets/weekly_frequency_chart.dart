import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/weekly_play_count.dart';

class WeeklyFrequencyChart extends StatelessWidget {
  final List<WeeklyPlayCount> weeks;

  const WeeklyFrequencyChart({super.key, required this.weeks});

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) return const SizedBox.shrink();

    final maxCount = weeks.map((w) => w.count).reduce((a, b) => a > b ? a : b);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Frequência semanal', style: AppTypography.label(context)),
        AppSpacing.gapMd,
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final week in weeks) ...[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${week.count}',
                        style: AppTypography.caption(context),
                      ),
                      AppSpacing.gapXs,
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: maxCount == 0
                            ? 4
                            : (week.count / maxCount) * 72 + 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.7),
                          borderRadius: AppRadius.smAll,
                        ),
                      ),
                      AppSpacing.gapXs,
                      Text(
                        week.label,
                        style: AppTypography.caption(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (week != weeks.last) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
