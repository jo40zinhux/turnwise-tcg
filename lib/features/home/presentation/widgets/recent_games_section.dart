import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../games/domain/game_summary.dart';
import '../../../games/presentation/providers/game_catalog_providers.dart';
import '../../domain/recent_game_summary.dart';
import '../providers/home_carousel_hint_provider.dart';
import 'home_game_carousel.dart';
import 'home_games_grid_sheet.dart';
import 'home_section_header.dart';

class RecentGamesSection extends ConsumerWidget {
  final List<RecentGameSummary> games;
  final void Function(String gameId) onGameTap;

  const RecentGamesSection({
    super.key,
    required this.games,
    required this.onGameTap,
  });

  static const int _seeAllThreshold = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (games.isEmpty) return const SizedBox.shrink();

    final catalog = ref.watch(gameCatalogProvider).valueOrNull ?? [];
    final catalogById = {for (final game in catalog) game.id: game};
    final hintNotifier = ref.read(homeCarouselScrollHintSeenProvider.notifier);
    final showSeeAll = games.length > _seeAllThreshold;

    List<HomeGamesGridEntry> gridEntries() {
      return [
        for (final recent in games)
          _gridEntryFor(recent, catalogById, Theme.of(context)),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: 'Jogos recentes (${games.length})',
          actionLabel: showSeeAll ? 'Ver todos' : null,
          onAction: showSeeAll
              ? () {
                  hintNotifier.markHintSeen();
                  showHomeGamesGridSheet(
                    context,
                    title: 'Jogos recentes',
                    games: gridEntries(),
                    onGameTap: onGameTap,
                  );
                }
              : null,
        ),
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

  HomeGamesGridEntry _gridEntryFor(
    RecentGameSummary recent,
    Map<String, GameSummary> catalogById,
    ThemeData theme,
  ) {
    final catalogGame = catalogById[recent.gameId];
    final accent = catalogGame != null
        ? colorFromHex(catalogGame.accent)
        : theme.colorScheme.primary;
    final icon = catalogGame != null
        ? getIconFromString(catalogGame.iconCode)
        : Icons.sports_esports_outlined;

    return HomeGamesGridEntry(
      gameId: recent.gameId,
      title: recent.gameName,
      subtitle:
          '${recent.recentMatchCount} partida${recent.recentMatchCount == 1 ? '' : 's'}',
      icon: icon,
      accent: accent,
      variant: HomeGameCardVariant.recent,
    );
  }
}
