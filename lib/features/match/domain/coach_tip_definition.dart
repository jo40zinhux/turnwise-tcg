/// Coach banner copy loaded from game rules metadata.
class CoachTipDefinition {
  final String id;
  final String message;
  final int maxTurn;
  final bool? whenWentFirst;

  const CoachTipDefinition({
    required this.id,
    required this.message,
    this.maxTurn = 1,
    this.whenWentFirst,
  });

  bool applies({required int turnNumber, required bool? wentFirst}) {
    if (turnNumber > maxTurn) return false;
    if (whenWentFirst == null) return true;
    return wentFirst == whenWentFirst;
  }

  factory CoachTipDefinition.fromJson(Map<String, dynamic> json) {
    return CoachTipDefinition(
      id: json['id'] as String,
      message: json['message'] as String,
      maxTurn: json['maxTurn'] as int? ?? 1,
      whenWentFirst: json['whenWentFirst'] as bool?,
    );
  }
}
