import 'package:flutter/foundation.dart';

import '../domain/achievement_definition.dart';
import '../domain/achievements_repository.dart';
import '../domain/user_achievement.dart';
import 'bundled_achievements_datasource.dart';
import 'firestore_achievements_datasource.dart';
import 'hive_achievements_datasource.dart';

typedef AchievementsCloudSync = Future<void> Function(
  String userId,
  UserAchievement achievement,
);

class AchievementsRepositoryImpl implements AchievementsRepository {
  final BundledAchievementsDataSource _bundled;
  final HiveAchievementsDataSource _local;
  final AchievementsCloudSync? _cloudSync;
  final String? Function() _getCurrentUserId;

  List<AchievementDefinition>? _cachedDefinitions;

  AchievementsRepositoryImpl({
    required BundledAchievementsDataSource bundled,
    required HiveAchievementsDataSource local,
    AchievementsCloudSync? cloudSync,
    required String? Function() getCurrentUserId,
  })  : _bundled = bundled,
        _local = local,
        _cloudSync = cloudSync,
        _getCurrentUserId = getCurrentUserId;

  @override
  Future<List<AchievementDefinition>> getDefinitions() async {
    _cachedDefinitions ??= await _bundled.loadDefinitions();
    return _cachedDefinitions!;
  }

  @override
  Future<List<UserAchievement>> getUnlocked() => _local.getAll();

  @override
  Future<bool> isUnlocked(String achievementId) async {
    final unlocked = await getUnlocked();
    return unlocked.any((item) => item.achievementId == achievementId);
  }

  @override
  Future<void> unlock(UserAchievement achievement) async {
    if (await isUnlocked(achievement.achievementId)) return;

    await _local.upsert(achievement);

    final userId = _getCurrentUserId();
    final cloudSync = _cloudSync;
    if (userId != null && cloudSync != null) {
      try {
        await cloudSync(userId, achievement);
      } catch (error, stack) {
        debugPrint(
          'Achievement cloud sync failed (${achievement.achievementId}): '
          '$error\n$stack',
        );
      }
    }
  }
}
