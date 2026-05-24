import 'board_game_config.dart';
import 'board_metadata.dart';
import 'board_target.dart';

/// Lightweight board memory for condition validations.
class MatchBoardState {
  final List<BoardTarget> targets;

  const MatchBoardState({this.targets = const []});

  BoardTarget? targetById(String id) {
    for (final target in targets) {
      if (target.id == id) return target;
    }
    return null;
  }

  MatchBoardState withTarget(BoardTarget updated) {
    final next = targets
        .map((t) => t.id == updated.id ? updated : t)
        .toList(growable: false);
    return MatchBoardState(targets: next);
  }

  MatchBoardState addTarget(BoardTarget target) {
    return MatchBoardState(targets: [...targets, target]);
  }

  MatchBoardState removeTarget(String targetId) {
    return MatchBoardState(
      targets: targets.where((t) => t.id != targetId).toList(growable: false),
    );
  }

  MatchBoardState addEmptySlot(
    String gameId, {
    BoardMetadata? board,
  }) {
    if (targets.length >= BoardGameConfig.maxTargets) return this;
    final index = targets.length;
    return addTarget(
      BoardTarget(
        id: 'slot_$index',
        label: BoardGameConfig.resolveNextSlotLabel(gameId, index, board),
      ),
    );
  }

  /// Clears per-turn flags at the start of a new turn.
  MatchBoardState onNewTurn() {
    return MatchBoardState(
      targets: targets
          .map((t) => t.copyWith(enteredThisTurn: false, exerted: false))
          .toList(growable: false),
    );
  }

  static MatchBoardState initialForGame(String gameId) {
    final labels = BoardGameConfig.slotLabels(gameId);
    return MatchBoardState(
      targets: [
        for (var i = 0; i < labels.length; i++)
          BoardTarget(id: 'slot_$i', label: labels[i]),
      ],
    );
  }

  factory MatchBoardState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MatchBoardState();
    final raw = json['targets'] as List<dynamic>? ?? [];
    return MatchBoardState(
      targets: raw
          .map((e) => BoardTarget.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'targets': targets.map((t) => t.toJson()).toList(),
      };
}
