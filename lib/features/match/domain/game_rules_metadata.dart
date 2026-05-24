import 'board_metadata.dart';
import 'coach_tip_definition.dart';
import 'match_board_state.dart';

/// Optional metadata from `assets/rules/{gameId}.json`.
class GameRulesMetadata {
  final List<String> setupPrompts;
  final String? firstTurnHint;
  final List<CoachTipDefinition> coachTips;
  final BoardMetadata board;

  const GameRulesMetadata({
    this.setupPrompts = const [],
    this.firstTurnHint,
    this.coachTips = const [],
    this.board = const BoardMetadata(),
  });

  /// Coin-flip setup is shown for every game unless explicitly opted out.
  bool get requiresWentFirstSetup =>
      !setupPrompts.contains('skip_coin_flip');

  static const resourceGameIds = {'one_piece', 'flesh_and_blood', 'riftbound'};

  static bool showResourceBarFor(String gameId) =>
      resourceGameIds.contains(gameId);

  static bool showBoardPanelFor(String gameId) =>
      MatchBoardState.initialForGame(gameId).targets.isNotEmpty;

  factory GameRulesMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GameRulesMetadata();

    final prompts = json['setupPrompts'];
    final tips = json['coachTips'];

    return GameRulesMetadata(
      setupPrompts: prompts is List
          ? prompts.map((e) => e.toString()).toList()
          : const [],
      firstTurnHint: json['firstTurnHint'] as String?,
      coachTips: tips is List
          ? tips
              .map((e) => CoachTipDefinition.fromJson(e as Map<String, dynamic>))
              .toList()
          : const [],
      board: BoardMetadata.fromJson(json['board'] as Map<String, dynamic>?),
    );
  }
}
