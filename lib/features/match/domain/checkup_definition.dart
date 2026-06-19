import 'match_effects_state.dart';

/// When a checkup reminder should appear.
enum CheckupTrigger {
  betweenTurns('between_turns'),
  onPhaseStart('on_phase_start'),
  onEffectApplied('on_effect_applied');

  const CheckupTrigger(this.storageKey);

  final String storageKey;

  static CheckupTrigger fromStorageKey(String? value) {
    return CheckupTrigger.values.firstWhere(
      (trigger) => trigger.storageKey == value,
      orElse: () => CheckupTrigger.betweenTurns,
    );
  }
}

class CheckupDefinition {
  final String id;
  final String title;
  final String message;
  final CheckupTrigger trigger;
  final List<String> effectIds;
  final List<String> phaseIds;
  final int priority;

  const CheckupDefinition({
    required this.id,
    required this.title,
    required this.message,
    required this.trigger,
    this.effectIds = const [],
    this.phaseIds = const [],
    this.priority = 0,
  });

  factory CheckupDefinition.fromJson(Map<String, dynamic> json) {
    return CheckupDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      trigger: CheckupTrigger.fromStorageKey(json['trigger'] as String?),
      effectIds: List<String>.from(json['effectIds'] ?? const []),
      phaseIds: List<String>.from(json['phaseIds'] ?? const []),
      priority: json['priority'] as int? ?? 0,
    );
  }

  /// Whether this reminder should surface given active effects.
  ///
  /// Checkups without [effectIds] are informational (e.g. FAB phase hints)
  /// and always fire when their trigger matches.
  bool shouldFire(MatchEffectsState effects) {
    if (effectIds.isEmpty) return true;
    return effects.nonExpiredEffects
        .any((effect) => effectIds.contains(effect.definitionId));
  }
}
