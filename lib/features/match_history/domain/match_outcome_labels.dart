import 'match_outcome.dart';

abstract final class MatchOutcomeLabels {
  static String label(MatchOutcome outcome) {
    return switch (outcome) {
      MatchOutcome.playerWin => 'Vitória',
      MatchOutcome.playerLoss => 'Derrota',
      MatchOutcome.draw => 'Empate',
      MatchOutcome.abandoned => 'Abandonada',
    };
  }
}
