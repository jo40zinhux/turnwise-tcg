import 'checkup_reminder.dart';
import 'game_rules.dart';
import 'match_engine_state.dart';

/// Phase-entry reminders derived from rules (not card-specific).
abstract final class PhaseReminderEvaluator {
  static CheckupReminder? onPhaseEntered({
    required GameRules rules,
    required String phaseId,
    required MatchEngineState state,
  }) {
    if (phaseId == 'draw' &&
        rules.gameId == 'one_piece' &&
        state.effectsState.turnNumber <= 1 &&
        state.effectsState.playerWentFirst == true) {
      return const CheckupReminder(
        id: 'first_player_skip_draw',
        title: 'Fase de compra',
        message:
            'Como primeiro jogador, você não compra carta no primeiro turno.',
      );
    }

    if (phaseId == 'don' && rules.gameId == 'one_piece') {
      return const CheckupReminder(
        id: 'don_phase_hint',
        title: 'Fase DON!!',
        message: 'Adicione até 2 cartas DON!! do seu DON!! Deck.',
      );
    }

    return null;
  }
}
