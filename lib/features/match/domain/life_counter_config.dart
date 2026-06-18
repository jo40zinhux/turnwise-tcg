import 'life_counter_direction.dart';

/// Declarative counter definition from `metadata.lifeTracker` in rules JSON.
class LifeCounterConfig {
  final String id;
  final String label;
  final int playerStart;
  final int opponentStart;
  final int? min;
  final int? max;
  final LifeCounterDirection direction;
  final String? iconCode;

  const LifeCounterConfig({
    required this.id,
    required this.label,
    required this.playerStart,
    required this.opponentStart,
    this.min,
    this.max,
    this.direction = LifeCounterDirection.down,
    this.iconCode,
  });

  factory LifeCounterConfig.fromJson(Map<String, dynamic> json) {
    return LifeCounterConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      playerStart: (json['playerStart'] as num?)?.toInt() ?? 0,
      opponentStart: (json['opponentStart'] as num?)?.toInt() ?? 0,
      min: (json['min'] as num?)?.toInt(),
      max: (json['max'] as num?)?.toInt(),
      direction: LifeCounterDirection.fromJson(json['direction'] as String?),
      iconCode: json['iconCode'] as String?,
    );
  }

  int clamp(int value) {
    var result = value;
    if (min != null) result = result < min! ? min! : result;
    if (max != null) result = result > max! ? max! : result;
    return result;
  }
}
