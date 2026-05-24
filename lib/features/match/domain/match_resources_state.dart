/// Tracked resources for games that use cost validations (manual adjustment in UI).
class MatchResourcesState {
  final int don;
  final int actionPoints;
  final int energy;

  const MatchResourcesState({
    this.don = 0,
    this.actionPoints = 0,
    this.energy = 0,
  });

  MatchResourcesState copyWith({
    int? don,
    int? actionPoints,
    int? energy,
  }) {
    return MatchResourcesState(
      don: don ?? this.don,
      actionPoints: actionPoints ?? this.actionPoints,
      energy: energy ?? this.energy,
    );
  }

  factory MatchResourcesState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MatchResourcesState();
    return MatchResourcesState(
      don: json['don'] as int? ?? 0,
      actionPoints: json['actionPoints'] as int? ?? 0,
      energy: json['energy'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'don': don,
        'actionPoints': actionPoints,
        'energy': energy,
      };

  /// Default pools when a new match starts (before first turn actions).
  static MatchResourcesState initialForGame(String gameId) {
    return switch (gameId) {
      'flesh_and_blood' => const MatchResourcesState(actionPoints: 1),
      _ => const MatchResourcesState(),
    };
  }

  /// Restored at the start of each new turn for supported games.
  static MatchResourcesState onNewTurn(
    String gameId,
    MatchResourcesState current,
  ) {
    return switch (gameId) {
      'flesh_and_blood' => current.copyWith(actionPoints: 1),
      _ => current,
    };
  }
}
