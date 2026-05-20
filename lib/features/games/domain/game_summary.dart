class GameSummary {
  final String id;
  final String name;
  final String iconCode;
  final String accent;

  const GameSummary({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.accent,
  });

  factory GameSummary.fromJson(Map<String, dynamic> json) {
    return GameSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCode: json['iconCode'] as String,
      accent: json['accent'] as String,
    );
  }
}
