import '../../achievements/domain/achievement_definition.dart';
import 'match_record.dart';

/// Navigation payload for the post-match summary screen.
class MatchSummaryArgs {
  final MatchRecord record;
  final List<AchievementDefinition> newlyUnlocked;
  final String gameName;

  const MatchSummaryArgs({
    required this.record,
    required this.newlyUnlocked,
    required this.gameName,
  });
}
