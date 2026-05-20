import 'checkup_definition.dart';
import 'effect_definition.dart';
import 'effect_duration.dart';
import 'effect_type.dart';
import 'trigger_definition.dart';

/// Parses `assets/rules/effects/{gameId}_effects.json` (effectsLibrary format).
abstract final class EffectsLibraryParser {
  static List<EffectDefinition> parseEffects(List<dynamic> raw) {
    return raw
        .map((e) => _parseEffect(e as Map<String, dynamic>))
        .toList();
  }

  static List<CheckupDefinition> parseDerivedCheckups(
    List<EffectDefinition> effects,
    List<dynamic> raw,
  ) {
    final checkups = <CheckupDefinition>[];

    for (final entry in raw) {
      final json = entry as Map<String, dynamic>;
      final triggerKey = json['trigger'] as String?;
      final description =
          json['description'] as String? ?? json['reminder'] as String?;
      if (triggerKey == null || description == null) continue;

      final checkupTrigger = _mapEffectTriggerToCheckup(triggerKey);
      if (checkupTrigger == null) continue;

      checkups.add(
        CheckupDefinition(
          id: '${json['id']}_checkup',
          title: json['name'] as String? ?? json['id'] as String,
          message: description,
          trigger: checkupTrigger,
          effectIds: [json['id'] as String],
        ),
      );
    }

    return checkups;
  }

  static List<TriggerDefinition> parseTriggers(List<dynamic>? raw) {
    if (raw == null) return const [];

    return raw
        .map((e) => TriggerDefinition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static EffectDefinition _parseEffect(Map<String, dynamic> json) {
    final blocked = _blockedActions(json);
    final type = _resolveType(json['type'] as String?, blocked);
    final duration = EffectDuration.fromJson(
      json['duration'] as Map<String, dynamic>? ?? const {},
    );

    final params = <String, dynamic>{
      if (json['params'] is Map<String, dynamic>)
        ...json['params'] as Map<String, dynamic>,
      if (blocked.isNotEmpty) 'lockedActionIds': blocked,
      if (json['effect'] is Map<String, dynamic>)
        'effect': json['effect'],
      if (json['skippedPhase'] != null) 'skippedPhase': json['skippedPhase'],
    };

    return EffectDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      type: type,
      duration: duration,
      iconCode: json['iconCode'] as String?,
      reminderMessage:
          json['description'] as String? ?? json['reminderMessage'] as String?,
      params: params,
    );
  }

  static List<String> _blockedActions(Map<String, dynamic> json) {
    final raw = json['blockedActions'];
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  static EffectType _resolveType(String? raw, List<String> blocked) {
    final mapped = EffectType.fromStorageKey(raw);
    if (blocked.isNotEmpty &&
        (mapped == EffectType.status || mapped == EffectType.modifier)) {
      return EffectType.actionLock;
    }
    return mapped;
  }

  static CheckupTrigger? _mapEffectTriggerToCheckup(String trigger) {
    return switch (trigger) {
      'pokemon_checkup' ||
      'end_turn' ||
      'between_turns' =>
        CheckupTrigger.betweenTurns,
      'before_attack' || 'on_phase_start' => CheckupTrigger.onPhaseStart,
      'on_effect_applied' => CheckupTrigger.onEffectApplied,
      _ => null,
    };
  }
}
