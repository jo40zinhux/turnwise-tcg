import 'action_rule.dart';
import 'game_rules.dart';
import 'match_resources_state.dart';
import 'validation_rule.dart';

/// Applies resource gains/spends after a successful action.
abstract final class ResourceSpendEvaluator {
  static MatchResourcesState afterAction({
    required GameRules rules,
    required ActionRule action,
    required MatchResourcesState resources,
  }) {
    var next = resources;

    if (action.id == 'add_don' && rules.gameId == 'one_piece') {
      next = next.copyWith(don: next.don + 1);
    }

    if (action.id == 'channel_runes' && rules.gameId == 'riftbound') {
      next = next.copyWith(energy: next.energy + 1);
    }

    for (final validationId in action.validations) {
      final validation = _findValidation(rules, validationId);
      if (validation == null || validation.type != 'resource') continue;
      next = _spendForValidation(validation, next);
    }

    return next;
  }

  static MatchResourcesState afterRevert({
    required GameRules rules,
    required ActionRule action,
    required MatchResourcesState resources,
  }) {
    var next = resources;

    if (action.id == 'add_don' && rules.gameId == 'one_piece') {
      next = next.copyWith(don: (next.don - 1).clamp(0, 999));
    }

    if (action.id == 'channel_runes' && rules.gameId == 'riftbound') {
      next = next.copyWith(energy: (next.energy - 1).clamp(0, 999));
    }

    for (final validationId in action.validations) {
      final validation = _findValidation(rules, validationId);
      if (validation == null || validation.type != 'resource') continue;
      next = _refundForValidation(validation, next);
    }

    return next;
  }

  static ValidationRule? _findValidation(GameRules rules, String id) {
    for (final validation in rules.validations) {
      if (validation.id == id) return validation;
    }
    return null;
  }

  static MatchResourcesState _spendForValidation(
    ValidationRule validation,
    MatchResourcesState resources,
  ) {
    final cost = validation.params['cost'] as int? ?? 1;
    return switch (validation.id) {
      'don_cost_check' => resources.copyWith(don: (resources.don - cost).clamp(0, 999)),
      'action_point' => resources.copyWith(
          actionPoints: (resources.actionPoints - cost).clamp(0, 999),
        ),
      'energy_cost_check' => resources.copyWith(
          energy: (resources.energy - cost).clamp(0, 999),
        ),
      _ => resources,
    };
  }

  static MatchResourcesState _refundForValidation(
    ValidationRule validation,
    MatchResourcesState resources,
  ) {
    final cost = validation.params['cost'] as int? ?? 1;
    return switch (validation.id) {
      'don_cost_check' => resources.copyWith(don: resources.don + cost),
      'action_point' => resources.copyWith(actionPoints: resources.actionPoints + cost),
      'energy_cost_check' => resources.copyWith(energy: resources.energy + cost),
      _ => resources,
    };
  }
}
