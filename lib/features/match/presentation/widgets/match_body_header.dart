import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../timer/presentation/widgets/match_timer_bar.dart';
import 'match_phase_progress.dart';
import 'match_setup_sheet.dart';
import 'match_turn_context_bar.dart';

/// Pinned match status: timer, phase position, and turn context only.
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
  });

  @override
  Widget build(BuildContext context) {
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
              final selected = await showMatchSetupSheet(
                context,
                gameId: gameId,
              );
              if (selected == null || !context.mounted) return;
              onPlayerWentFirst(selected);
            },
          ),
        ],
      ),
    );
  }
}
