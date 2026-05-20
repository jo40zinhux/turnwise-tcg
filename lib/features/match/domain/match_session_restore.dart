import 'match_engine_state.dart';
import 'match_session.dart';

/// Restores match engine state from persistence with safe bounds.
class MatchSessionRestore {
  static MatchEngineState engineState({
    required MatchSession? session,
    required String gameId,
    required int phaseCount,
  }) {
    if (session == null || session.gameId != gameId || phaseCount <= 0) {
      return const MatchEngineState(currentPhaseIndex: 0);
    }

    final maxIndex = phaseCount - 1;
    final safeIndex = session.currentPhaseIndex.clamp(0, maxIndex);

    return MatchEngineState(
      currentPhaseIndex: safeIndex,
      actionUsageCount: Map<String, int>.from(session.actionUsageCount),
      effectsState: session.effectsState,
    );
  }

  static int clampPhaseIndex(int phaseIndex, int phaseCount) {
    if (phaseCount <= 0) return 0;
    return phaseIndex.clamp(0, phaseCount - 1);
  }
}
