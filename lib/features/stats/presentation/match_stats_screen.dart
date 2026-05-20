import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/duration_format.dart';
import '../../../shared/widgets/async_value_body.dart';
import '../../games/presentation/providers/game_catalog_providers.dart';
import '../domain/match_stats.dart';
import 'providers/match_stats_providers.dart';
import 'widgets/stat_metric_card.dart';
import 'widgets/weekly_frequency_chart.dart';

class MatchStatsScreen extends ConsumerWidget {
  const MatchStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(matchStatsProvider);
    final catalogAsync = ref.watch(gameCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Estatísticas', style: AppTypography.title(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Conquistas',
            onPressed: () => context.goNamed('achievements'),
          ),
        ],
      ),
      body: SafeArea(
        child: AsyncListBody<MatchStats>(
          value: statsAsync,
          isEmpty: (stats) => stats.isEmpty,
          emptyIcon: Icons.bar_chart_rounded,
          emptyTitle: 'Sem dados ainda',
          emptyMessage:
              'Completa partidas para ver winrate, tempo médio e mais.',
          emptyActionLabel: 'Jogar agora',
          onEmptyAction: () => context.goNamed('home'),
          onRetry: () => ref.invalidate(matchStatsProvider),
          data: (stats) {
            final gameNames = catalogAsync.maybeWhen(
              data: (games) => {
                for (final game in games) game.id: game.name,
              },
              orElse: () => const <String, String>{},
            );

            final winRateLabel = stats.winRatePercent != null
                ? '${stats.winRatePercent!.toStringAsFixed(0)}%'
                : '—';
            final avgDurationLabel = stats.averageDuration != null
                ? DurationFormat.short(stats.averageDuration!)
                : '—';

            return ListView(
              key: ValueKey(stats.totalMatches),
              padding: AppSpacing.screen,
              children: [
                Row(
                  children: [
                    StatMetricCard(
                      label: 'Partidas',
                      value: '${stats.totalMatches}',
                      icon: Icons.sports_esports_outlined,
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
                AppSpacing.gapXl,
                Text('Resumo', style: AppTypography.label(context)),
                AppSpacing.gapSm,
                _SummaryRow(label: 'Vitórias', value: '${stats.wins}'),
                _SummaryRow(label: 'Derrotas', value: '${stats.losses}'),
                _SummaryRow(label: 'Empates', value: '${stats.draws}'),
                _SummaryRow(
                  label: 'Abandonadas',
                  value: '${stats.abandoned}',
                ),
                _SummaryRow(
                  label: 'Partidas esta semana',
                  value: '${stats.matchesThisWeek}',
                ),
                AppSpacing.gapXl,
                Text('Jogos por TCG', style: AppTypography.label(context)),
                AppSpacing.gapMd,
                ...stats.gamesByTcg.map((entry) {
                  return _GameCountTile(
                    gameName: gameNames[entry.gameId] ?? entry.gameId,
                    count: entry.count,
                    total: stats.totalMatches,
                  );
                }),
                AppSpacing.gapXl,
                WeeklyFrequencyChart(weeks: stats.weeklyFrequency),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTypography.bodyMuted(context)),
          ),
          Text(value, style: AppTypography.body(context)),
        ],
      ),
    );
  }
}

class _GameCountTile extends StatelessWidget {
  final String gameName;
  final int count;
  final int total;

  const _GameCountTile({
    required this.gameName,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(gameName, style: AppTypography.body(context)),
              ),
              Text('$count', style: AppTypography.caption(context)),
            ],
          ),
          AppSpacing.gapXs,
          ClipRRect(
            borderRadius: AppRadius.smAll,
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor:
                  theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
