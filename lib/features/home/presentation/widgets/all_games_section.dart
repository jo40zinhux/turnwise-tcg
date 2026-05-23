import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/observability/app_analytics_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../coach/presentation/widgets/coach_tip_banner.dart';
import '../../../games/domain/game_summary.dart';
import '../providers/home_carousel_hint_provider.dart';
import 'home_game_carousel.dart';
import 'home_games_grid_sheet.dart';
import 'home_section_header.dart';

class AllGamesSection extends ConsumerStatefulWidget {
  final List<GameSummary> games;
  final void Function(String gameId) onGameTap;

  const AllGamesSection({
    super.key,
    required this.games,
    required this.onGameTap,
  });

  static const int _seeAllThreshold = 2;

  @override
  ConsumerState<AllGamesSection> createState() => _AllGamesSectionState();
}

class _AllGamesSectionState extends ConsumerState<AllGamesSection> {
  HomeCarouselScrollHintNotifier? _hintNotifier;

  @override
  void initState() {
    super.initState();
    _hintNotifier = ref.read(homeCarouselScrollHintSeenProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCarouselLifecycle());
  }

  @override
  void didUpdateWidget(AllGamesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.games.length != widget.games.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hintNotifier?.onCatalogItemCountChanged(widget.games.length);
      });
    }
  }

  @override
  void dispose() {
    _hintNotifier?.onCatalogCarouselUnmounted();
    super.dispose();
  }

  void _syncCarouselLifecycle() {
    _hintNotifier?.onCatalogCarouselMounted(itemCount: widget.games.length);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.games.isEmpty) return const SizedBox.shrink();

    final hintState = ref.watch(homeCarouselScrollHintSeenProvider);
    final hintNotifier = ref.read(homeCarouselScrollHintSeenProvider.notifier);
    final showSeeAll = widget.games.length > AllGamesSection._seeAllThreshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: 'Todos os jogos (${widget.games.length})',
          actionLabel: showSeeAll ? 'Ver todos' : null,
          onAction: showSeeAll
              ? () {
                  hintNotifier.markHintSeen();
                  showHomeGamesGridSheet(
                    context,
                    title: 'Todos os jogos',
                    games: [
                      for (final game in widget.games)
                        HomeGamesGridEntry(
                          gameId: game.id,
                          title: game.name,
                          subtitle: 'Jogar!',
                          icon: getIconFromString(game.iconCode),
                          accent: colorFromHex(game.accent),
                          variant: HomeGameCardVariant.catalog,
                        ),
                    ],
                    onGameTap: widget.onGameTap,
                  );
                }
              : null,
        ),
        if (!hintState.seen && showSeeAll) ...[
          AppSpacing.gapSm,
          CoachTipBanner(
            message:
                'Desliza para ver mais jogos, ou toca em Ver todos para a lista completa.',
            onDismiss: () {
              hintNotifier.markHintSeen();
              ref.read(appAnalyticsProvider).logCoachTipDismissed(
                    tipId: 'home_carousel_scroll',
                  );
            },
          ),
        ],
        AppSpacing.gapMd,
        HomeGameCarouselStrip(
          itemCount: widget.games.length,
          nudgeTick: hintState.seen ? 0 : hintState.nudgeTick,
          onNudgeCycleComplete: hintNotifier.onNudgeCycleComplete,
          onUserScroll: hintNotifier.onUserScrollInteraction,
          itemBuilder: (context, index) {
            final game = widget.games[index];
            final accent = colorFromHex(game.accent);

            return HomeGameCarouselCard(
              title: game.name,
              subtitle: 'Jogar!',
              icon: getIconFromString(game.iconCode),
              accent: accent,
              variant: HomeGameCardVariant.catalog,
              onTap: () => widget.onGameTap(game.id),
            );
          },
        ),
      ],
    );
  }
}
