// lib/features/match/domain/turn_phase.dart

class TurnPhase {
  final String id;
  final String title;
  final String description;
  final String iconCode;

  const TurnPhase({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
  });

  factory TurnPhase.fromJson(Map<String, dynamic> json) {
    return TurnPhase(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconCode: json['iconCode'] as String,
    );
  }
}
