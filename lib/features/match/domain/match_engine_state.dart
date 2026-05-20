import 'match_effects_state.dart';
import 'match_feedback.dart';

class MatchEngineState {
  final int currentPhaseIndex;
  final Map<String, int> actionUsageCount;
  final MatchFeedback? feedback;
  final MatchEffectsState effectsState;

  const MatchEngineState({
    required this.currentPhaseIndex,
    this.actionUsageCount = const {},
    this.feedback,
    this.effectsState = MatchEffectsState.empty,
  });

  MatchEngineState copyWith({
    int? currentPhaseIndex,
    Map<String, int>? actionUsageCount,
    MatchFeedback? feedback,
    MatchEffectsState? effectsState,
    bool clearFeedback = false,
  }) {
    return MatchEngineState(
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      actionUsageCount: actionUsageCount ?? this.actionUsageCount,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      effectsState: effectsState ?? this.effectsState,
    );
  }

  factory MatchEngineState.fromJson(Map<String, dynamic> json) {
    return MatchEngineState(
      currentPhaseIndex: json['currentPhaseIndex'] as int? ?? 0,
      actionUsageCount: (json['actionUsageCount'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toInt())) ??
          const {},
      effectsState: MatchEffectsState.fromJson(
        json['effectsState'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPhaseIndex': currentPhaseIndex,
      'actionUsageCount': actionUsageCount,
      'effectsState': effectsState.toJson(),
    };
  }
}
