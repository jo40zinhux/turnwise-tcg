import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../domain/life_counter_config.dart';
import '../../domain/life_tracker_config.dart';
import '../../domain/match_life_state.dart';
import 'match_life_adjust_sheet.dart';

/// Compact life / prizes / lore tracker; opens a sheet for numeric adjustments.
class MatchLifeBar extends StatelessWidget {
  final LifeTrackerConfig config;
  final MatchLifeState life;
  final void Function({
    required String counterId,
    required bool isPlayer,
    required int delta,
    required LifeCounterConfig counter,
  }) onAdjust;

  const MatchLifeBar({
    super.key,
    required this.config,
    required this.life,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    if (!config.hasCounters) return const SizedBox.shrink();

    final primary = config.counters.first;
    final playerValue = life.valueFor(
      counterId: primary.id,
      isPlayer: true,
      config: primary,
    );
    final opponentValue = life.valueFor(
      counterId: primary.id,
      isPlayer: false,
      config: primary,
    );

    final icon = primary.iconCode != null
        ? getIconFromString(primary.iconCode!)
        : Icons.favorite_border;

    return Material(
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.5),
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () => showMatchLifeAdjustSheet(
          context,
          config: config,
          life: life,
          onAdjust: onAdjust,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs + 2,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${primary.label} · Você $playerValue · Oponente $opponentValue',
                  style: AppTypography.label(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.tune_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
