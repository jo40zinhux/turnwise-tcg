import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../games/domain/game_summary.dart';
import '../../../match/domain/match_session.dart';
import '../../../../shared/widgets/resume_match_banner.dart';
import 'all_games_section.dart';
import 'home_dashboard_header.dart';
import 'home_dashboard_shortcuts.dart';
import 'home_dashboard_stats_section.dart';
import 'home_game_carousel.dart';
import 'home_section_header.dart';
import 'recent_games_section.dart';
import '../../domain/recent_game_summary.dart';
import '../providers/home_dashboard_providers.dart';

/// Dashboard body: hero, resume, stats, shortcuts, recent games, full catalog.
class HomeDashboardContent extends ConsumerWidget {
  final List<GameSummary> games;
  final MatchSession? activeSession;
  final void Function(String gameId) onGameTap;
  final VoidCallback onDismissActiveSession;

  const HomeDashboardContent({
    super.key,
    required this.games,
    required this.activeSession,
    required this.onGameTap,
    required this.onDismissActiveSession,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeGameName = ref.watch(resumeGameNameProvider);
    final recentGamesAsync = ref.watch(recentGamesProvider);
    final session = activeSession;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: AppSpacing.screenHorizontal.copyWith(
            top: AppSpacing.lg,
            bottom: AppSpacing.xl,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              HomeDashboardHeader(
                hasActiveSession: session != null,
                resumeGameName: resumeGameName,
              ),
              if (session != null && resumeGameName != null) ...[
                AppSpacing.gapLg,
                ResumeMatchBanner(
                  gameName: resumeGameName,
                  onResume: () => onGameTap(session.gameId),
                  onDismiss: onDismissActiveSession,
                ),
              ],
              AppSpacing.gapLg,
              const HomeDashboardStatsSection(),
              AppSpacing.gapLg,
              HomeDashboardShortcuts(
                shortcuts: [
                  HomeDashboardShortcut(
                    icon: Icons.history_rounded,
                    label: 'Histórico',
                    onTap: () => context.goNamed('history'),
                  ),
                  HomeDashboardShortcut(
                    icon: Icons.emoji_events_outlined,
                    label: 'Conquistas',
                    onTap: () => context.goNamed('achievements'),
                  ),
                  HomeDashboardShortcut(
                    icon: Icons.bar_chart_rounded,
                    label: 'Estatísticas',
                    onTap: () => context.goNamed('stats'),
                  ),
                ],
              ),
              AppSpacing.gapLg,
              _RecentGamesDashboardSection(
                recentGamesAsync: recentGamesAsync,
                onGameTap: onGameTap,
              ),
              AppSpacing.gapLg,
              AllGamesSection(
                games: games,
                onGameTap: onGameTap,
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _RecentGamesDashboardSection extends StatelessWidget {
  final AsyncValue<List<RecentGameSummary>> recentGamesAsync;
  final void Function(String gameId) onGameTap;

  const _RecentGamesDashboardSection({
    required this.recentGamesAsync,
    required this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    return recentGamesAsync.when(
      loading: () => const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeSectionHeader(title: 'Jogos recentes'),
          AppSpacing.gapMd,
          SizedBox(
            height: HomeGameCarousel.height,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (recentGames) {
        if (recentGames.isEmpty) return const SizedBox.shrink();
        return RecentGamesSection(
          games: recentGames,
          onGameTap: onGameTap,
        );
      },
    );
  }
}
