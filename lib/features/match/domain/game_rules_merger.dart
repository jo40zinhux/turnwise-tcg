import 'checkup_definition.dart';
import 'effect_definition.dart';
import 'game_effects_bundle.dart';
import 'game_rules.dart';
import 'trigger_definition.dart';

/// Merges base game rules JSON with an optional external effects bundle.
abstract final class GameRulesMerger {
  static GameRules merge(GameRules base, GameEffectsBundle? bundle) {
    if (bundle == null) return base;
    if (bundle.effects.isEmpty &&
        bundle.checkups.isEmpty &&
        bundle.triggers.isEmpty) {
      return base;
    }

    return GameRules(
      gameId: base.gameId,
      name: base.name,
      phases: base.phases,
      actions: base.actions,
      validations: base.validations,
      effects: bundle.effects.isNotEmpty ? bundle.effects : base.effects,
      checkups: _mergeById<CheckupDefinition>(
        base.checkups,
        bundle.checkups,
        (item) => item.id,
      ),
      triggers: _mergeById<TriggerDefinition>(
        base.triggers,
        bundle.triggers,
        (item) => item.id,
      ),
    );
  }

  static List<T> _mergeById<T>(
    List<T> base,
    List<T> extra,
    String Function(T) idOf,
  ) {
    final map = <String, T>{};
    for (final item in base) {
      map[idOf(item)] = item;
    }
    for (final item in extra) {
      map[idOf(item)] = item;
    }
    return map.values.toList();
  }
}
