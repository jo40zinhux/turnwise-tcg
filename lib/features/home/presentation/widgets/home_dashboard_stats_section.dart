import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../stats/presentation/providers/match_stats_providers.dart';
import '../../../stats/presentation/widgets/quick_stats_row.dart';
import 'home_dashboard_panel.dart';
import 'home_section_header.dart';

class HomeDashboardStatsSection extends ConsumerWidget {
  const HomeDashboardStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(matchStatsProvider);

    return statsAsync.when(
      loading: () => const HomeDashboardPanel(
        child: SkeletonBox(height: 100),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.isEmpty) return const SizedBox.shrink();

        return HomeDashboardPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeSectionHeader(
                title: 'Resumo',
                actionLabel: 'Ver tudo',
                onAction: () => context.goNamed('stats'),
              ),
              AppSpacing.gapSm,
              QuickStatsRow(stats: stats),
            ],
          ),
        );
      },
    );
  }
}
