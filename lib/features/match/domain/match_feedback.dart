enum MatchFeedbackType {
  success,
  error,
  info,
}

class MatchFeedback {
  final String message;
  final MatchFeedbackType type;

  /// Analytics / diagnostics key (e.g. validation id, `opponent_turn`).
  final String? reason;

  const MatchFeedback({
    required this.message,
    required this.type,
    this.reason,
  });
}
