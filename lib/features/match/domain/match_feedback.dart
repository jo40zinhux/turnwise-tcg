enum MatchFeedbackType {
  success,
  error,
  info,
}

class MatchFeedback {
  final String message;
  final MatchFeedbackType type;

  const MatchFeedback({
    required this.message,
    required this.type,
  });
}
