/// A trackable card/unit slot on the board.
class BoardTarget {
  final String id;
  final String label;

  /// Entered play during the current turn (summoning sickness / evolve ban).
  final bool enteredThisTurn;

  /// Exerted / rested — cannot quest, challenge, attack, or move.
  final bool exerted;

  /// Ready to act (inverse of exhausted in Lorcana/Riftbound terms).
  final bool ready;

  /// Yu-Gi-Oh!: monster must be in attack position to declare attack.
  final bool inAttackPosition;

  const BoardTarget({
    required this.id,
    required this.label,
    this.enteredThisTurn = false,
    this.exerted = false,
    this.ready = true,
    this.inAttackPosition = true,
  });

  bool get canAct => ready && !exerted;

  BoardTarget copyWith({
    String? label,
    bool? enteredThisTurn,
    bool? exerted,
    bool? ready,
    bool? inAttackPosition,
  }) {
    return BoardTarget(
      id: id,
      label: label ?? this.label,
      enteredThisTurn: enteredThisTurn ?? this.enteredThisTurn,
      exerted: exerted ?? this.exerted,
      ready: ready ?? this.ready,
      inAttackPosition: inAttackPosition ?? this.inAttackPosition,
    );
  }

  factory BoardTarget.fromJson(Map<String, dynamic> json) {
    return BoardTarget(
      id: json['id'] as String,
      label: json['label'] as String,
      enteredThisTurn: json['enteredThisTurn'] as bool? ?? false,
      exerted: json['exerted'] as bool? ?? false,
      ready: json['ready'] as bool? ?? true,
      inAttackPosition: json['inAttackPosition'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'enteredThisTurn': enteredThisTurn,
        'exerted': exerted,
        'ready': ready,
        'inAttackPosition': inAttackPosition,
      };
}
