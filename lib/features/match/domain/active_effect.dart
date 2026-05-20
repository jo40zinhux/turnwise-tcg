import 'effect_source.dart';
import 'effect_type.dart';

/// Runtime effect instance on the match table.
class ActiveEffect {
  final String instanceId;
  final String definitionId;
  final EffectType type;
  final EffectSource source;
  final String name;
  final String? iconCode;
  final int? remainingTurns;
  final int? remainingPhases;
  final List<String> lockedActionIds;
  final String? reminderMessage;

  const ActiveEffect({
    required this.instanceId,
    required this.definitionId,
    required this.type,
    required this.source,
    required this.name,
    this.iconCode,
    this.remainingTurns,
    this.remainingPhases,
    this.lockedActionIds = const [],
    this.reminderMessage,
  });

  bool get isExpired {
    if (remainingTurns != null && remainingTurns! <= 0) return true;
    if (remainingPhases != null && remainingPhases! <= 0) return true;
    return false;
  }

  String? get durationLabel {
    if (remainingTurns != null) return '${remainingTurns}T';
    if (remainingPhases != null) return '${remainingPhases}F';
    return null;
  }

  ActiveEffect copyWith({
    String? instanceId,
    String? definitionId,
    EffectType? type,
    EffectSource? source,
    String? name,
    String? iconCode,
    int? remainingTurns,
    int? remainingPhases,
    List<String>? lockedActionIds,
    String? reminderMessage,
    bool clearRemainingTurns = false,
    bool clearRemainingPhases = false,
  }) {
    return ActiveEffect(
      instanceId: instanceId ?? this.instanceId,
      definitionId: definitionId ?? this.definitionId,
      type: type ?? this.type,
      source: source ?? this.source,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      remainingTurns:
          clearRemainingTurns ? null : (remainingTurns ?? this.remainingTurns),
      remainingPhases: clearRemainingPhases
          ? null
          : (remainingPhases ?? this.remainingPhases),
      lockedActionIds: lockedActionIds ?? this.lockedActionIds,
      reminderMessage: reminderMessage ?? this.reminderMessage,
    );
  }

  factory ActiveEffect.fromJson(Map<String, dynamic> json) {
    return ActiveEffect(
      instanceId: json['instanceId'] as String,
      definitionId: json['definitionId'] as String,
      type: EffectType.fromStorageKey(json['type'] as String?),
      source: EffectSource.fromJson(
        json['source'] as Map<String, dynamic>? ?? const {},
      ),
      name: json['name'] as String,
      iconCode: json['iconCode'] as String?,
      remainingTurns: json['remainingTurns'] as int?,
      remainingPhases: json['remainingPhases'] as int?,
      lockedActionIds: List<String>.from(json['lockedActionIds'] ?? const []),
      reminderMessage: json['reminderMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instanceId': instanceId,
      'definitionId': definitionId,
      'type': type.storageKey,
      'source': source.toJson(),
      'name': name,
      if (iconCode != null) 'iconCode': iconCode,
      if (remainingTurns != null) 'remainingTurns': remainingTurns,
      if (remainingPhases != null) 'remainingPhases': remainingPhases,
      if (lockedActionIds.isNotEmpty) 'lockedActionIds': lockedActionIds,
      if (reminderMessage != null) 'reminderMessage': reminderMessage,
    };
  }
}
