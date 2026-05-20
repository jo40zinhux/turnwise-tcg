/// Result of a completed match from the local player's perspective.
enum MatchOutcome {
  playerWin,
  playerLoss,
  draw,
  abandoned;

  String get storageKey => name;

  static MatchOutcome? fromStorageKey(String? value) {
    if (value == null) return null;
    for (final outcome in MatchOutcome.values) {
      if (outcome.storageKey == value) return outcome;
    }
    return null;
  }
}
