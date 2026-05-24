import 'game_rules.dart';

/// Per-game copy for the universal coin-flip setup sheet.
abstract final class MatchSetupCopy {
  static String firstTurnHint(GameRules rules) {
    return rules.metadata.firstTurnHint ??
        _fallbackHint(rules.gameId);
  }

  /// Legacy entry when rules are not loaded yet.
  static String firstTurnHintByGameId(String gameId) => _fallbackHint(gameId);

  static String _fallbackHint(String gameId) {
    return 'A moeda define a ordem de turnos. O app usa isto para lembretes '
        'e bloqueios do primeiro turno quando aplicável.';
  }
}
