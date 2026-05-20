import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../match/presentation/providers/match_providers.dart';
import '../../match/presentation/providers/match_session_providers.dart';
import '../../match/presentation/utils/dismiss_active_match_dialog.dart';
import '../../games/presentation/providers/game_catalog_providers.dart';
import 'widgets/home_dashboard_content.dart';
import 'widgets/home_dashboard_skeleton.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(gameCatalogProvider);
    final activeSession = ref.watch(activeMatchSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('TurnWise', style: AppTypography.title(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Definições',
            onPressed: () => context.goNamed('settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: catalogAsync.when(
          loading: () => const SingleChildScrollView(
            padding: AppSpacing.screenHorizontal,
            child: HomeDashboardSkeleton(),
          ),
          error: (error, _) => ErrorStateView(
            message: 'Não foi possível carregar os jogos.',
            retryLabel: 'Tentar novamente',
            onRetry: () => ref.invalidate(gameCatalogProvider),
          ),
          data: (games) {
            if (games.isEmpty) {
              return const EmptyStateView(
                icon: Icons.style_outlined,
                title: 'Nenhum jogo disponível',
                message:
                    'Ainda não temos TCGs configurados. Volta em breve.',
              );
            }

            return HomeDashboardContent(
              games: games,
              activeSession: activeSession,
              onGameTap: (gameId) => _openMatch(context, gameId),
              onDismissActiveSession: () => _confirmDismissActiveSession(
                context,
                ref,
                activeSession!.gameId,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDismissActiveSession(
    BuildContext context,
    WidgetRef ref,
    String gameId,
  ) async {
    final confirmed = await confirmDismissActiveMatch(context);
    if (!confirmed) return;
    await dismissActiveMatch(ref, gameId);
  }

  void _openMatch(BuildContext context, String gameId) {
    context.goNamed(
      'match',
      pathParameters: {'gameId': gameId},
    );
  }
}
