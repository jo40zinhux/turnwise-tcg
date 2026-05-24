import 'action_rule.dart';
import 'condition_evaluator.dart';
import 'match_engine_state.dart';
import 'validation_rule.dart';

/// Evaluates declarative validation rules from game JSON.
abstract final class ValidationEvaluator {
  /// Returns an error message when the action should be blocked, or null if OK.
  static String? blockMessage({
    required ValidationRule validation,
    required ActionRule action,
    required MatchEngineState state,
    String? targetId,
  }) {
    if (!_isBlocked(validation, action, state, targetId)) return null;
    return validation.errorMessage.replaceAll('{actionName}', action.name);
  }

  static bool _isBlocked(
    ValidationRule validation,
    ActionRule action,
    MatchEngineState state,
    String? targetId,
  ) {
    return switch (validation.type) {
      'limit' => _limitBlocked(validation, action, state),
      'player_first_turn' => _playerFirstTurnBlocked(state),
      'first_player_first_turn' => _firstPlayerFirstTurnBlocked(state),
      'resource' => _resourceBlocked(validation, state),
      'condition' => _conditionBlocked(validation, state, targetId),
      _ => false,
    };
  }

  static bool _conditionBlocked(
    ValidationRule validation,
    MatchEngineState state,
    String? targetId,
  ) {
    if (targetId == null) return false;

    final target = state.effectsState.board.targetById(targetId);
    if (target == null) return false;

    if (!ConditionEvaluator.isAutoEnforceable(validation)) return false;

    return !ConditionEvaluator.isMet(validation: validation, target: target);
  }

  static bool _limitBlocked(
    ValidationRule validation,
    ActionRule action,
    MatchEngineState state,
  ) {
    final maxPerTurn = validation.params['max'] as int? ?? 1;
    final currentUsage = state.actionUsageCount[action.id] ?? 0;
    return currentUsage >= maxPerTurn;
  }

  static bool _playerFirstTurnBlocked(MatchEngineState state) {
    return state.effectsState.turnNumber <= 1;
  }

  static bool _firstPlayerFirstTurnBlocked(MatchEngineState state) {
    if (state.effectsState.turnNumber > 1) return false;
    return state.effectsState.playerWentFirst == true;
  }

  static bool _resourceBlocked(ValidationRule validation, MatchEngineState state) {
    final cost = validation.params['cost'] as int? ?? 1;
    final pool = state.effectsState.resources;

    return switch (validation.id) {
      'don_cost_check' => pool.don < cost,
      'action_point' => pool.actionPoints < cost,
      'energy_cost_check' => pool.energy < cost,
      _ => false,
    };
  }
}
