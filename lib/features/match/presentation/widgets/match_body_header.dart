import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../timer/presentation/widgets/match_timer_bar.dart';
import '../../domain/game_rules_metadata.dart';
import '../../domain/life_counter_config.dart';
import '../../domain/life_tracker_config.dart';
import '../../domain/match_effects_state.dart';
import 'match_life_bar.dart';
import 'match_phase_progress.dart';
import 'match_setup_sheet.dart';
import 'match_turn_context_bar.dart';

/// Pinned match status: timer, (optional life bar), phase position, and turn
/// context only.
///
/// Board and resource trackers live in the scroll body so the fixed header
/// stays glanceable at the table.
class MatchBodyHeader extends StatelessWidget {
  final String gameId;
  final int currentPhaseIndex;
  final int totalPhases;
  final int turnNumber;
  final bool? playerWentFirst;
  final bool isOpponentTurn;
  final ValueChanged<bool> onPlayerWentFirst;
  final VoidCallback? onCompleteOpponentTurn;

  // Life tracker — only shown when the game has counters configured.
  final LifeTrackerConfig lifeTracker;
  final MatchEffectsState? effectsState;
  final void Function({
    required String counterId,
    required bool isPlayer,
    required int delta,
    required LifeCounterConfig counter,
  })? onLifeAdjust;

  const MatchBodyHeader({
    super.key,
    required this.gameId,
    required this.currentPhaseIndex,
    required this.totalPhases,
    required this.turnNumber,
    this.playerWentFirst,
    this.isOpponentTurn = false,
    required this.onPlayerWentFirst,
    this.onCompleteOpponentTurn,
    this.lifeTracker = const LifeTrackerConfig(),
    this.effectsState,
    this.onLifeAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final showLifeBar = GameRulesMetadata.showLifeTrackerFor(lifeTracker) &&
        effectsState != null &&
        onLifeAdjust != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MatchTimerBar(gameId: gameId),
          if (showLifeBar) ...[
            AppSpacing.gapSm,
            MatchLifeBar(
              config: lifeTracker,
              life: effectsState!.life,
              onAdjust: onLifeAdjust!,
            ),
          ],
          AppSpacing.gapSm,
          MatchPhaseProgress(
            currentPhase: currentPhaseIndex,
            totalPhases: totalPhases,
          ),
          AppSpacing.gapXs,
          MatchTurnContextBar(
            turnNumber: turnNumber,
            playerWentFirst: playerWentFirst,
            isOpponentTurn: isOpponentTurn,
            onCompleteOpponentTurn: onCompleteOpponentTurn,
            onEditSetup: () async {
              final setup = await showMatchSetupSheet(
                context,
                gameId: gameId,
                mode: MatchSetupMode.edit,
              );
              if (setup == null || !context.mounted) return;
              onPlayerWentFirst(setup.playerWentFirst);
            },
          ),
        ],
      ),
    );
  }
}
