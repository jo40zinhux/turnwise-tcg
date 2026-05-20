import 'match_feedback.dart';

class MatchEngineState {
  final int currentPhaseIndex;
  final Map<String, int> actionUsageCount;
  final MatchFeedback? feedback;

  const MatchEngineState({
    required this.currentPhaseIndex,
    this.actionUsageCount = const {},
    this.feedback,
  });

  MatchEngineState copyWith({
    int? currentPhaseIndex,
    Map<String, int>? actionUsageCount,
    MatchFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return MatchEngineState(
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      actionUsageCount: actionUsageCount ?? this.actionUsageCount,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }
}
