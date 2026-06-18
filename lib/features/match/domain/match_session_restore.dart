import 'life_tracker_config.dart';
import 'match_effects_state.dart';
import 'match_engine_state.dart';
import 'match_life_state.dart';
import 'match_session.dart';

/// Restores match engine state from persistence with safe bounds.
class MatchSessionRestore {
  static MatchEngineState engineState({
    required MatchSession? session,
    required String gameId,
    required int phaseCount,
    LifeTrackerConfig? lifeTracker,
  }) {
    if (session == null || session.gameId != gameId || phaseCount <= 0) {
      return MatchEngineState(
        currentPhaseIndex: 0,
        effectsState: MatchEffectsState.initialForGame(
          gameId,
          lifeTracker: lifeTracker,
        ),
      );
    }

    final maxIndex = phaseCount - 1;
    final safeIndex = session.currentPhaseIndex.clamp(0, maxIndex);
    var effectsState = session.effectsState;

    // Back-fill life counters for sessions saved before the life tracker was
    // introduced so existing in-progress matches aren't silently empty.
    if (lifeTracker != null &&
        lifeTracker.hasCounters &&
        effectsState.life.player.isEmpty &&
        effectsState.life.opponent.isEmpty) {
      effectsState = effectsState.copyWith(
        life: MatchLifeState.initial(lifeTracker),
      );
    }

    return MatchEngineState(
      currentPhaseIndex: safeIndex,
      actionUsageCount: Map<String, int>.from(session.actionUsageCount),
      effectsState: effectsState,
    );
  }

  static int clampPhaseIndex(int phaseIndex, int phaseCount) {
    if (phaseCount <= 0) return 0;
    return phaseIndex.clamp(0, phaseCount - 1);
  }
}
