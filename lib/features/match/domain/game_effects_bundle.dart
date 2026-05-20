import 'dart:convert';

import 'checkup_definition.dart';
import 'effect_definition.dart';
import 'effects_library_parser.dart';
import 'trigger_definition.dart';

/// External effects pack loaded from `assets/rules/effects/{gameId}_effects.json`.
class GameEffectsBundle {
  final String gameId;
  final List<EffectDefinition> effects;
  final List<CheckupDefinition> checkups;
  final List<TriggerDefinition> triggers;

  const GameEffectsBundle({
    required this.gameId,
    required this.effects,
    this.checkups = const [],
    this.triggers = const [],
  });

  factory GameEffectsBundle.fromJson(String gameId, Map<String, dynamic> json) {
    final library = json['effectsLibrary'] as List<dynamic>? ?? [];
    final effects = EffectsLibraryParser.parseEffects(library);
    final derivedCheckups =
        EffectsLibraryParser.parseDerivedCheckups(effects, library);

    final explicitCheckups = (json['checkups'] as List<dynamic>?)
            ?.map((e) => CheckupDefinition.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    final triggers = EffectsLibraryParser.parseTriggers(
      json['triggers'] as List<dynamic>?,
    );

    return GameEffectsBundle(
      gameId: gameId,
      effects: effects,
      checkups: _mergeCheckups(derivedCheckups, explicitCheckups),
      triggers: triggers,
    );
  }

  factory GameEffectsBundle.fromRawJson(String gameId, String rawJson) {
    final map = json.decode(rawJson) as Map<String, dynamic>;
    return GameEffectsBundle.fromJson(gameId, map);
  }

  static List<CheckupDefinition> _mergeCheckups(
    List<CheckupDefinition> a,
    List<CheckupDefinition> b,
  ) {
    final byId = <String, CheckupDefinition>{};
    for (final item in [...a, ...b]) {
      byId[item.id] = item;
    }
    return byId.values.toList();
  }
}
