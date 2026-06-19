import 'action_rule.dart';
import 'game_rules.dart';
import 'match_engine_state.dart';
import 'validation_evaluator.dart';
import 'validation_rule.dart';

/// How strongly the engine can enforce an action's validations.
enum ValidationEnforcementKind {
  /// Blocked automatically by the match engine.
  enforced,

  /// Shown as a manual reminder — requires board/target state not yet tracked.
  reminder,
}

/// Summary of which validations apply to an action.
class ActionEnforcement {
  final bool hasEnforcedRules;
  final bool hasReminderRules;
  final String? primaryReminderMessage;

  const ActionEnforcement({
    this.hasEnforcedRules = false,
    this.hasReminderRules = false,
    this.primaryReminderMessage,
  });

  /// Action relies only on reminders (no automatic blocks).
  bool get isReminderOnly => hasReminderRules && !hasEnforcedRules;

  /// Action has at least one reminder the player must verify manually.
  bool get showsReminderBadge => hasReminderRules;

  /// Whether the player should pick a board target before registering.
  static bool needsTargetSelection(GameRules rules, ActionRule action) {
    if (action.requiresTarget) return true;
    for (final validationId in action.validations) {
      final validation = _findValidation(rules, validationId);
      if (validation?.type == 'condition') return true;
    }
    return false;
  }

  /// Target picker only when the action can still proceed without a pre-check.
  ///
  /// Skips the board sheet when enforced validations or effect locks already
  /// block the action (e.g. first-turn attack ban, paralysis).
  static bool shouldPromptForTarget({
    required GameRules rules,
    required ActionRule action,
    required MatchEngineState state,
  }) {
    if (!needsTargetSelection(rules, action)) return false;

    if (state.effectsState.lockedActionIds.contains(action.id)) {
      return false;
    }

    for (final validationId in action.validations) {
      final validation = _findValidation(rules, validationId);
      if (validation == null) continue;
      if (validation.type == 'condition') continue;

      final block = ValidationEvaluator.blockMessage(
        validation: validation,
        action: action,
        state: state,
        targetId: null,
      );
      if (block != null) return false;
    }

    return true;
  }

  static ActionEnforcement analyze(GameRules rules, ActionRule action) {
    var enforced = false;
    var reminder = false;
    String? reminderMessage;

    for (final validationId in action.validations) {
      final validation = _findValidation(rules, validationId);
      if (validation == null) continue;

      switch (_kindFor(validation)) {
        case ValidationEnforcementKind.enforced:
          enforced = true;
        case ValidationEnforcementKind.reminder:
          reminder = true;
          reminderMessage ??= validation.errorMessage;
      }
    }

    return ActionEnforcement(
      hasEnforcedRules: enforced,
      hasReminderRules: reminder,
      primaryReminderMessage: reminderMessage,
    );
  }

  static ValidationEnforcementKind _kindFor(ValidationRule validation) {
    return switch (validation.type) {
      'limit' ||
      'player_first_turn' ||
      'first_player_first_turn' ||
      'resource' =>
        ValidationEnforcementKind.enforced,
      'condition' => ValidationEnforcementKind.reminder,
      _ => ValidationEnforcementKind.enforced,
    };
  }

  static ValidationRule? _findValidation(GameRules rules, String id) {
    for (final validation in rules.validations) {
      if (validation.id == id) return validation;
    }
    return null;
  }
}
