import 'board_game_config.dart';

/// Board UI copy and flag definitions from game rules metadata.
class BoardMetadata {
  final List<String> slotLabels;
  final List<BoardFlagSpec> flagSpecs;
  final String? emptyHint;

  const BoardMetadata({
    this.slotLabels = const [],
    this.flagSpecs = const [],
    this.emptyHint,
  });

  bool get hasFlagSpecs => flagSpecs.isNotEmpty;

  factory BoardMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const BoardMetadata();

    final labels = json['slotLabels'];
    final flags = json['flags'];

    return BoardMetadata(
      slotLabels: labels is List
          ? labels.map((e) => e.toString()).toList()
          : const [],
      flagSpecs: flags is List
          ? flags
              .map((e) => _flagSpecFromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      emptyHint: json['emptyHint'] as String?,
    );
  }

  static BoardFlagSpec _flagSpecFromJson(Map<String, dynamic> json) {
    final flagName = json['flag'] as String;
    final flag = switch (flagName) {
      'enteredThisTurn' => BoardTargetFlag.enteredThisTurn,
      'exerted' => BoardTargetFlag.exerted,
      'attackPosition' => BoardTargetFlag.attackPosition,
      _ => throw FormatException('Unknown board flag: $flagName'),
    };
    return BoardFlagSpec(
      flag: flag,
      label: json['label'] as String,
    );
  }
}
