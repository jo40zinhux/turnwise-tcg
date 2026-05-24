import 'match_board_state.dart';

/// Snapshot of board state before an action, used for undo.
class BoardUndoEntry {
  final String actionId;
  final MatchBoardState board;

  const BoardUndoEntry({
    required this.actionId,
    required this.board,
  });

  factory BoardUndoEntry.fromJson(Map<String, dynamic> json) {
    return BoardUndoEntry(
      actionId: json['actionId'] as String,
      board: MatchBoardState.fromJson(json['board'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'actionId': actionId,
        'board': board.toJson(),
      };
}
