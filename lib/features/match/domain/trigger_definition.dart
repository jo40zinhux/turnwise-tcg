import 'checkup_definition.dart';

/// Rule-driven trigger that applies an effect when an event occurs.
class TriggerDefinition {
  final String id;
  final CheckupTrigger when;
  final String applyEffectId;
  final List<String> requiredActiveEffectIds;

  const TriggerDefinition({
    required this.id,
    required this.when,
    required this.applyEffectId,
    this.requiredActiveEffectIds = const [],
  });

  factory TriggerDefinition.fromJson(Map<String, dynamic> json) {
    return TriggerDefinition(
      id: json['id'] as String,
      when: CheckupTrigger.fromStorageKey(json['when'] as String?),
      applyEffectId: json['applyEffectId'] as String,
      requiredActiveEffectIds:
          List<String>.from(json['requiredActiveEffectIds'] ?? const []),
    );
  }
}
