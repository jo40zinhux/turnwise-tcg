import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../timer/presentation/widgets/match_timer_bar.dart';
import '../../domain/board_metadata.dart';
import '../../domain/game_rules_metadata.dart';
import '../../domain/match_board_state.dart';
import '../../domain/match_effects_state.dart';
import '../../domain/match_resources_state.dart';
import 'match_board_panel.dart';
import 'match_phase_progress.dart';
import 'match_resource_bar.dart';
import 'match_setup_sheet.dart';
import 'match_turn_context_bar.dart';

/// Timer, turn context, resources and board above the phase list.
class MatchBodyHeader extends StatelessWidget {
  final String gameId;
  final BoardMetadata boardMetadata;
  final int currentPhaseIndex;
  final int totalPhases;
  final String currentPhaseTitle;
  final MatchEffectsState effectsState;
  final MatchBoardState board;
  final ValueChanged<MatchResourcesState> onResourcesChanged;
  final ValueChanged<MatchBoardState> onBoardChanged;
  final ValueChanged<bool> onPlayerWentFirst;
  final VoidCallback? onCompleteOpponentTurn;

  const MatchBodyHeader({
    super.key,
    required this.gameId,
    this.boardMetadata = const BoardMetadata(),
    required this.currentPhaseIndex,
    required this.totalPhases,
    required this.currentPhaseTitle,
    required this.effectsState,
    required this.board,
    required this.onResourcesChanged,
    required this.onBoardChanged,
    required this.onPlayerWentFirst,
    this.onCompleteOpponentTurn,
  });

  @override
  Widget build(BuildContext context) {
    final showResourceBar = GameRulesMetadata.showResourceBarFor(gameId);

    return Padding(
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MatchTimerBar(gameId: gameId),
          AppSpacing.gapMd,
          MatchPhaseProgress(
            currentPhase: currentPhaseIndex,
            totalPhases: totalPhases,
            currentPhaseTitle: currentPhaseTitle,
          ),
          AppSpacing.gapSm,
          MatchTurnContextBar(
            turnNumber: effectsState.turnNumber,
            playerWentFirst: effectsState.playerWentFirst,
            isOpponentTurn: effectsState.isOpponentTurn,
            onCompleteOpponentTurn: onCompleteOpponentTurn,
            onEditSetup: () async {
              final selected = await showMatchSetupSheet(
                context,
                gameId: gameId,
              );
              if (selected == null || !context.mounted) return;
              onPlayerWentFirst(selected);
            },
          ),
          if (showResourceBar) ...[
            AppSpacing.gapMd,
            MatchResourceBar(
              gameId: gameId,
              resources: effectsState.resources,
              onChanged: onResourcesChanged,
            ),
          ],
          AppSpacing.gapMd,
          MatchBoardPanel(
            gameId: gameId,
            boardMetadata: boardMetadata,
            board: board,
            onChanged: onBoardChanged,
          ),
        ],
      ),
    );
  }
}
