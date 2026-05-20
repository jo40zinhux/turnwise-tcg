import 'achievement_definition.dart';
import 'user_achievement.dart';

abstract class AchievementsRepository {
  Future<List<AchievementDefinition>> getDefinitions();

  Future<List<UserAchievement>> getUnlocked();

  Future<bool> isUnlocked(String achievementId);

  Future<void> unlock(UserAchievement achievement);
}
