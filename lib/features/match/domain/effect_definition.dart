import 'effect_duration.dart';
import 'effect_type.dart';

/// Static effect template loaded from game rules JSON.
class EffectDefinition {
  final String id;
  final String name;
  final EffectType type;
  final EffectDuration duration;
  final String? iconCode;
  final String? reminderMessage;
  final Map<String, dynamic> params;

  const EffectDefinition({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    this.iconCode,
    this.reminderMessage,
    this.params = const {},
  });

  List<String> get lockedActionIds {
    final raw = params['lockedActionIds'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  factory EffectDefinition.fromJson(Map<String, dynamic> json) {
    final blocked = _readBlockedActions(json);
    final params = <String, dynamic>{
      if (json['params'] is Map<String, dynamic>)
        ...json['params'] as Map<String, dynamic>,
      if (blocked.isNotEmpty) 'lockedActionIds': blocked,
      if (json['skippedPhase'] != null) 'skippedPhase': json['skippedPhase'],
    };

    return EffectDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      type: EffectType.fromStorageKey(json['type'] as String?),
      duration: EffectDuration.fromJson(
        json['duration'] as Map<String, dynamic>? ?? const {},
      ),
      iconCode: json['iconCode'] as String?,
      reminderMessage: json['reminder'] as String? ?? json['reminderMessage'] as String?,
      params: params,
    );
  }

  static List<String> _readBlockedActions(Map<String, dynamic> json) {
    final fromParams = json['params']?['lockedActionIds'];
    if (fromParams is List) {
      return fromParams.map((e) => e.toString()).toList();
    }
    final blocked = json['blockedActions'];
    if (blocked is List) {
      return blocked.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
