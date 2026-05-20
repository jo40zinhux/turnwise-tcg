import '../../match_history/domain/match_outcome.dart';
import '../../match_history/domain/match_record.dart';
import 'achievement_definition.dart';
import 'achievement_metric.dart';
import 'achievements_repository.dart';
import 'user_achievement.dart';

class EvaluateAchievementsUseCase {
  final AchievementsRepository _repository;

  const EvaluateAchievementsUseCase(this._repository);

  Future<List<AchievementDefinition>> execute({
    required List<MatchRecord> matchRecords,
    DateTime? referenceTime,
  }) async {
    final definitions = await _repository.getDefinitions();
    final unlocked = await _repository.getUnlocked();
    final unlockedIds = unlocked.map((a) => a.achievementId).toSet();
    final now = referenceTime ?? DateTime.now();

    final matchCount = matchRecords.length;
    final winCount = matchRecords
        .where((record) => record.outcome == MatchOutcome.playerWin)
        .length;

    final newlyUnlocked = <AchievementDefinition>[];

    for (final definition in definitions) {
      if (unlockedIds.contains(definition.id)) continue;

      final progress = _progressFor(
        definition.metric,
        matchCount: matchCount,
        winCount: winCount,
      );

      if (progress >= definition.target) {
        await _repository.unlock(
          UserAchievement(
            achievementId: definition.id,
            unlockedAt: now,
          ),
        );
        newlyUnlocked.add(definition);
        unlockedIds.add(definition.id);
      }
    }

    return newlyUnlocked;
  }

  int _progressFor(
    AchievementMetric metric, {
    required int matchCount,
    required int winCount,
  }) {
    return switch (metric) {
      AchievementMetric.matchCount => matchCount,
      AchievementMetric.winCount => winCount,
    };
  }
}
