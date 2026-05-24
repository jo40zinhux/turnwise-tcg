import 'game_rules.dart';
import 'match_engine_state.dart';

/// Contextual one-shot coach copy for the match screen.
class MatchCoachTip {
  final String id;
  final String message;

  const MatchCoachTip({required this.id, required this.message});
}

abstract final class MatchCoachTips {
  static MatchCoachTip? activeTip({
    required GameRules rules,
    required MatchEngineState state,
    required Set<String> dismissedTipIds,
  }) {
    if (state.effectsState.turnNumber > 1) return null;

    final wentFirst = state.effectsState.playerWentFirst;

    for (final tip in rules.metadata.coachTips) {
      if (dismissedTipIds.contains(tip.id)) continue;
      if (!tip.applies(
        turnNumber: state.effectsState.turnNumber,
        wentFirst: wentFirst,
      )) {
        continue;
      }
      return MatchCoachTip(id: tip.id, message: tip.message);
    }

    if (wentFirst == null) return null;

    final fallbackId = '${rules.gameId}_turn_order_${wentFirst ? 'first' : 'second'}';
    if (dismissedTipIds.contains(fallbackId)) return null;

    return MatchCoachTip(
      id: fallbackId,
      message: wentFirst
          ? 'Você joga primeiro — confere os lembretes desta fase.'
          : 'Oponente joga primeiro — no teu turno 1 aplicam-se as tuas regras de abertura.',
    );
  }
}
