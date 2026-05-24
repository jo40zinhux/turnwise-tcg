import 'board_target.dart';
import 'validation_rule.dart';

/// Evaluates declarative `condition` validations against a board target.
abstract final class ConditionEvaluator {
  /// Returns true when the condition passes (action allowed).
  /// Without a [target], conditions cannot be verified — treated as pass-through.
  static bool isMet({
    required ValidationRule validation,
    BoardTarget? target,
  }) {
    if (target == null) return true;

    final requires = validation.params['requires'] as String? ?? '';
    return switch (requires) {
      'target_not_played_this_turn' => !target.enteredThisTurn,
      'character_active' => target.canAct,
      'character_ready' => target.canAct,
      'unit_ready' => target.canAct,
      'creature_control_since_turn_start' => !target.enteredThisTurn,
      'attacker_in_attack_position' => target.inAttackPosition,
      _ => true,
    };
  }

  /// Whether this condition can be auto-enforced when a target is selected.
  static bool isAutoEnforceable(ValidationRule validation) => true;
}
