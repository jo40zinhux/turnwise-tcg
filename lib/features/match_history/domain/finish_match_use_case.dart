import '../../achievements/domain/achievement_definition.dart';
import '../../achievements/domain/evaluate_achievements_use_case.dart';
import 'complete_match_params.dart';
import 'complete_match_use_case.dart';
import 'match_history_repository.dart';
import 'match_record.dart';

/// Orchestrates archiving a match and evaluating achievements.
class FinishMatchUseCase {
  final CompleteMatchUseCase _completeMatch;
  final EvaluateAchievementsUseCase _evaluateAchievements;
  final MatchHistoryRepository _historyRepository;

  const FinishMatchUseCase({
    required CompleteMatchUseCase completeMatch,
    required EvaluateAchievementsUseCase evaluateAchievements,
    required MatchHistoryRepository historyRepository,
  })  : _completeMatch = completeMatch,
        _evaluateAchievements = evaluateAchievements,
        _historyRepository = historyRepository;

  Future<FinishMatchResult> execute(CompleteMatchParams params) async {
    final record = await _completeMatch.execute(params);
    final records = await _historyRepository.getAllRecords();
    final newlyUnlocked = await _evaluateAchievements.execute(
      matchRecords: records,
    );

    return FinishMatchResult(
      record: record,
      newlyUnlocked: newlyUnlocked,
    );
  }
}

class FinishMatchResult {
  final MatchRecord record;
  final List<AchievementDefinition> newlyUnlocked;

  const FinishMatchResult({
    required this.record,
    required this.newlyUnlocked,
  });
}
