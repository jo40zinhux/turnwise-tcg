// lib/features/match/domain/action_rule.dart

class ActionRule {
  final String id;
  final String name;
  final List<String> allowedPhases;
  final List<String> validations;
  final bool trackUsage;
  final int cooldown;
  final bool requiresTarget;
  final Map<String, dynamic> metadata;

  const ActionRule({
    required this.id,
    required this.name,
    required this.allowedPhases,
    required this.validations,
    this.trackUsage = false,
    this.cooldown = 0,
    this.requiresTarget = false,
    this.metadata = const {},
  });

  factory ActionRule.fromJson(Map<String, dynamic> json) {
    // Extract unknown keys into metadata
    final knownKeys = {
      'id', 'name', 'allowedPhases', 'validations',
      'trackUsage', 'cooldown', 'requiresTarget'
    };
    final meta = <String, dynamic>{};
    json.forEach((key, value) {
      if (!knownKeys.contains(key)) meta[key] = value;
    });

    return ActionRule(
      id: json['id'] as String,
      name: json['name'] as String,
      allowedPhases: List<String>.from(json['allowedPhases'] ?? []),
      validations: List<String>.from(json['validations'] ?? []),
      trackUsage: json['trackUsage'] as bool? ?? false,
      cooldown: json['cooldown'] as int? ?? 0,
      requiresTarget: json['requiresTarget'] as bool? ?? false,
      metadata: meta,
    );
  }
}

