import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/async_value_body.dart';
import '../../games/presentation/providers/game_catalog_providers.dart';
import 'providers/match_history_providers.dart';
import 'widgets/match_history_tile.dart';

class MatchHistoryScreen extends ConsumerWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(recentMatchHistoryProvider);
    final catalogAsync = ref.watch(gameCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico', style: AppTypography.title(context)),
      ),
      body: SafeArea(
        child: AsyncListBody(
          value: historyAsync,
          isEmpty: (records) => records.isEmpty,
          emptyIcon: Icons.history_rounded,
          emptyTitle: 'Ainda sem partidas guardadas',
          emptyMessage: 'Encerra uma partida para ver o histórico aqui.',
          emptyActionLabel: 'Escolher jogo',
          onEmptyAction: () => context.goNamed('home'),
          onRetry: () => ref.invalidate(recentMatchHistoryProvider),
          data: (records) {
            final gameNames = catalogAsync.maybeWhen(
              data: (games) => {
                for (final game in games) game.id: game.name,
              },
              orElse: () => const <String, String>{},
            );

            return ListView.separated(
              key: ValueKey(records.length),
              padding: AppSpacing.screen,
              itemCount: records.length,
              separatorBuilder: (_, __) => AppSpacing.gapMd,
              itemBuilder: (context, index) {
                final record = records[index];
                return MatchHistoryTile(
                  gameName: gameNames[record.gameId] ?? record.gameId,
                  record: record,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
