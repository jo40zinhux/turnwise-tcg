import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/achievements/domain/achievement_definition.dart';
import 'package:turnwise_tcg/features/achievements/domain/achievement_metric.dart';
import 'package:turnwise_tcg/features/achievements/domain/achievements_repository.dart';
import 'package:turnwise_tcg/features/achievements/domain/evaluate_achievements_use_case.dart';
import 'package:turnwise_tcg/features/achievements/domain/user_achievement.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_record.dart';

class _FakeAchievementsRepository implements AchievementsRepository {
  final List<UserAchievement> unlocked = [];

  @override
  Future<List<AchievementDefinition>> getDefinitions() async {
    return const [
      AchievementDefinition(
        id: 'first_match',
        title: 'Primeira partida',
        description: 'Completa a tua primeira partida.',
        metric: AchievementMetric.matchCount,
        target: 1,
        iconCode: 'emoji_events_outlined',
      ),
      AchievementDefinition(
        id: 'five_wins',
        title: 'Competidor',
        description: 'Regista 5 vitórias.',
        metric: AchievementMetric.winCount,
        target: 5,
        iconCode: 'workspace_premium_outlined',
      ),
    ];
  }

  @override
  Future<List<UserAchievement>> getUnlocked() async => unlocked;

  @override
  Future<bool> isUnlocked(String achievementId) async {
    return unlocked.any((item) => item.achievementId == achievementId);
  }

  @override
  Future<void> unlock(UserAchievement achievement) async {
    unlocked.add(achievement);
  }
}

void main() {
  group('EvaluateAchievementsUseCase', () {
    test('unlocks first match achievement', () async {
      final repository = _FakeAchievementsRepository();
      final useCase = EvaluateAchievementsUseCase(repository);

      final unlocked = await useCase.execute(
        matchRecords: [
          _record(outcome: MatchOutcome.playerLoss),
        ],
        referenceTime: DateTime.parse('2026-05-19T12:00:00.000'),
      );

      expect(unlocked.map((a) => a.id), ['first_match']);
      expect(repository.unlocked.length, 1);
    });

    test('unlocks win achievement when threshold reached', () async {
      final repository = _FakeAchievementsRepository();
      repository.unlocked.add(
        UserAchievement(
          achievementId: 'first_match',
          unlockedAt: DateTime.parse('2026-05-18T12:00:00.000'),
        ),
      );

      final useCase = EvaluateAchievementsUseCase(repository);
      final records = List.generate(
        5,
        (index) => _record(
          id: 'win-$index',
          outcome: MatchOutcome.playerWin,
        ),
      );

      final unlocked = await useCase.execute(matchRecords: records);

      expect(unlocked.single.id, 'five_wins');
    });

    test('does not unlock already unlocked achievements', () async {
      final repository = _FakeAchievementsRepository();
      repository.unlocked.add(
        UserAchievement(
          achievementId: 'first_match',
          unlockedAt: DateTime.parse('2026-05-18T12:00:00.000'),
        ),
      );

      final useCase = EvaluateAchievementsUseCase(repository);
      final unlocked = await useCase.execute(
        matchRecords: [_record()],
      );

      expect(unlocked, isEmpty);
    });
  });
}

MatchRecord _record({
  String id = 'match-1',
  MatchOutcome outcome = MatchOutcome.draw,
}) {
  final endedAt = DateTime.parse('2026-05-19T12:00:00.000');
  return MatchRecord(
    id: id,
    gameId: 'pokemon',
    startedAt: endedAt.subtract(const Duration(minutes: 20)),
    endedAt: endedAt,
    outcome: outcome,
    updatedAt: endedAt,
  );
}
