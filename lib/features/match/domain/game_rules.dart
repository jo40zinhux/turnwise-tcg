// lib/features/match/domain/game_rules.dart

import 'turn_phase.dart';
import 'action_rule.dart';
import 'validation_rule.dart';

class GameRules {
  final String gameId;
  final String name;
  final List<TurnPhase> phases;
  final List<ActionRule> actions;
  final List<ValidationRule> validations;
  final List<dynamic> statusEffects; // placeholder

  const GameRules({
    required this.gameId,
    required this.name,
    required this.phases,
    required this.actions,
    required this.validations,
    required this.statusEffects,
  });

  factory GameRules.fromJson(Map<String, dynamic> json) {
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
      statusEffects: json['statusEffects'] as List<dynamic>? ?? [],
    );
  }
}
