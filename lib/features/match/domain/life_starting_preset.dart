/// Optional starting-life preset shown in match setup (e.g. FAB 20/40).
class LifeStartingPreset {
  final String label;
  final int playerStart;
  final int opponentStart;

  const LifeStartingPreset({
    required this.label,
    required this.playerStart,
    required this.opponentStart,
  });

  factory LifeStartingPreset.fromJson(Map<String, dynamic> json) {
    return LifeStartingPreset(
      label: json['label'] as String,
      playerStart: (json['playerStart'] as num).toInt(),
      opponentStart: (json['opponentStart'] as num).toInt(),
    );
  }
}
