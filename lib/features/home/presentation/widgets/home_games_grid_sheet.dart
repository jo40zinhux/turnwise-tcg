import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'home_game_carousel.dart';

/// Entry for the full-list games bottom sheet (catalog or recent).
class HomeGamesGridEntry {
  final String gameId;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final HomeGameCardVariant variant;

  const HomeGamesGridEntry({
    required this.gameId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.variant,
  });
}

Future<void> showHomeGamesGridSheet(
  BuildContext context, {
  required String title,
  required List<HomeGamesGridEntry> games,
  required ValueChanged<String> onGameTap,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _HomeGamesGridSheet(
      title: title,
      games: games,
      onGameTap: onGameTap,
    ),
  );
}

class _HomeGamesGridSheet extends StatelessWidget {
  final String title;
  final List<HomeGamesGridEntry> games;
  final ValueChanged<String> onGameTap;

  const _HomeGamesGridSheet({
    required this.title,
    required this.games,
    required this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + bottomInset,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppTypography.headline(context)),
            AppSpacing.gapSm,
            Text(
              'Escolhe um jogo para começar uma partida.',
              style: AppTypography.bodyMuted(context),
            ),
            AppSpacing.gapLg,
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.55,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.78,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return HomeGameCarouselCard(
                    title: game.title,
                    subtitle: game.subtitle,
                    icon: game.icon,
                    accent: game.accent,
                    variant: game.variant,
                    expandWidth: true,
                    onTap: () {
                      Navigator.pop(context);
                      onGameTap(game.gameId);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
