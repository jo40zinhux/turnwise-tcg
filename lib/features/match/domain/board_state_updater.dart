import 'action_rule.dart';
import 'match_board_state.dart';

/// Updates board targets after a successful action registration.
abstract final class BoardStateUpdater {
  static MatchBoardState afterAction({
    required ActionRule action,
    required MatchBoardState board,
    String? targetId,
  }) {
    if (targetId == null) return board;
    final target = board.targetById(targetId);
    if (target == null) return board;

    if (_marksEnteredPlay(action.id)) {
      return board.withTarget(target.copyWith(enteredThisTurn: true));
    }

    if (action.id == 'set_monster') {
      return board.withTarget(
        target.copyWith(enteredThisTurn: true, inAttackPosition: false),
      );
    }

    if (action.id == 'normal_summon') {
      return board.withTarget(
        target.copyWith(enteredThisTurn: true, inAttackPosition: true),
      );
    }

    if (_marksExerted(action.id)) {
      return board.withTarget(target.copyWith(exerted: true));
    }

    return board;
  }

  static MatchBoardState afterRevert({
    required ActionRule action,
    required MatchBoardState board,
  }) {
    return board;
  }

  static bool boardChanged(MatchBoardState before, MatchBoardState after) {
    return before.toJson().toString() != after.toJson().toString();
  }

  static bool _marksEnteredPlay(String actionId) {
    return const {
      'play_basic',
      'play_character',
      'play_unit',
      'special_summon',
    }.contains(actionId);
  }

  static bool _marksExerted(String actionId) {
    return const {
      'attack',
      'declare_attack',
      'declare_attacker',
      'quest',
      'challenge',
      'move_unit',
    }.contains(actionId);
  }
}
