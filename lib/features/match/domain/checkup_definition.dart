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
  final int priority;

  const CheckupDefinition({
    required this.id,
    required this.title,
    required this.message,
    required this.trigger,
    this.effectIds = const [],
    this.priority = 0,
  });

  factory CheckupDefinition.fromJson(Map<String, dynamic> json) {
    return CheckupDefinition(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      trigger: CheckupTrigger.fromStorageKey(json['trigger'] as String?),
      effectIds: List<String>.from(json['effectIds'] ?? const []),
      priority: json['priority'] as int? ?? 0,
    );
  }
}
