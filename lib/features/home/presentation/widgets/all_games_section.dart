import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../games/domain/game_summary.dart';
import 'home_game_carousel.dart';
import 'home_section_header.dart';

class AllGamesSection extends StatelessWidget {
  final List<GameSummary> games;
  final void Function(String gameId) onGameTap;

  const AllGamesSection({
    super.key,
    required this.games,
    required this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HomeSectionHeader(title: 'Todos os jogos'),
        AppSpacing.gapMd,
        HomeGameCarouselStrip(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final accent = colorFromHex(game.accent);

            return HomeGameCarouselCard(
              title: game.name,
              subtitle: 'Jogar!',
              icon: getIconFromString(game.iconCode),
              accent: accent,
              variant: HomeGameCardVariant.catalog,
              onTap: () => onGameTap(game.id),
            );
          },
        ),
      ],
    );
  }
}
