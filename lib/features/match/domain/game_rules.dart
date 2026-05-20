import 'action_rule.dart';
import 'checkup_definition.dart';
import 'effect_definition.dart';
import 'effect_duration.dart';
import 'effect_type.dart';
import 'trigger_definition.dart';
import 'turn_phase.dart';
import 'validation_rule.dart';

class GameRules {
  final String gameId;
  final String name;
  final List<TurnPhase> phases;
  final List<ActionRule> actions;
  final List<ValidationRule> validations;
  final List<EffectDefinition> effects;
  final List<CheckupDefinition> checkups;
  final List<TriggerDefinition> triggers;

  const GameRules({
    required this.gameId,
    required this.name,
    required this.phases,
    required this.actions,
    required this.validations,
    required this.effects,
    this.checkups = const [],
    this.triggers = const [],
  });

  EffectDefinition? effectById(String id) {
    for (final effect in effects) {
      if (effect.id == id) return effect;
    }
    return null;
  }

  factory GameRules.fromJson(Map<String, dynamic> json) {
    final legacyStatus = json['statusEffects'] as List<dynamic>? ?? [];
    final parsedEffects = (json['effects'] as List<dynamic>?)
            ?.map((e) => EffectDefinition.fromJson(e as Map<String, dynamic>))
            .toList() ??
        _legacyStatusToEffects(legacyStatus);

    return GameRules(
      gameId: json['gameId'] as String,
      name: json['name'] as String,
      phases: (json['phases'] as List<dynamic>?)
              ?.map((e) => TurnPhase.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      actions: (json['actions'] as List<dynamic>?)
              ?.map((e) => ActionRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      validations: (json['validations'] as List<dynamic>?)
              ?.map((e) => ValidationRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      effects: parsedEffects,
      checkups: (json['checkups'] as List<dynamic>?)
              ?.map((e) => CheckupDefinition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      triggers: (json['triggers'] as List<dynamic>?)
              ?.map((e) => TriggerDefinition.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static List<EffectDefinition> _legacyStatusToEffects(List<dynamic> legacy) {
    return legacy.map((raw) {
      final id = raw.toString();
      return EffectDefinition(
        id: id,
        name: _legacyStatusLabel(id),
        type: EffectType.status,
        duration: const EffectDuration(
          kind: EffectDurationKind.permanent,
        ),
        iconCode: 'info_outline',
      );
    }).toList();
  }

  static String _legacyStatusLabel(String id) {
    return switch (id) {
      'poison' => 'Envenenado',
      'burn' => 'Queimadura',
      'confusion' => 'Confusão',
      'paralysis' => 'Paralisia',
      'sleep' => 'Sono',
      _ => id,
    };
  }
}
