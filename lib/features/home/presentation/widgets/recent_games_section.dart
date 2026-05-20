import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../games/presentation/providers/game_catalog_providers.dart';
import '../../domain/recent_game_summary.dart';
import 'home_game_carousel.dart';
import 'home_section_header.dart';

class RecentGamesSection extends ConsumerWidget {
  final List<RecentGameSummary> games;
  final void Function(String gameId) onGameTap;

  const RecentGamesSection({
    super.key,
    required this.games,
    required this.onGameTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (games.isEmpty) return const SizedBox.shrink();

    final catalog = ref.watch(gameCatalogProvider).valueOrNull ?? [];
    final catalogById = {for (final game in catalog) game.id: game};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HomeSectionHeader(title: 'Jogos recentes'),
        AppSpacing.gapMd,
        HomeGameCarouselStrip(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final recent = games[index];
            final catalogGame = catalogById[recent.gameId];
            final theme = Theme.of(context);
            final accent = catalogGame != null
                ? colorFromHex(catalogGame.accent)
                : theme.colorScheme.primary;
            final icon = catalogGame != null
                ? getIconFromString(catalogGame.iconCode)
                : Icons.sports_esports_outlined;

            return HomeGameCarouselCard(
              title: recent.gameName,
              subtitle:
                  '${recent.recentMatchCount} partida${recent.recentMatchCount == 1 ? '' : 's'}',
              icon: icon,
              accent: accent,
              variant: HomeGameCardVariant.recent,
              onTap: () => onGameTap(recent.gameId),
            );
          },
        ),
      ],
    );
  }
}
