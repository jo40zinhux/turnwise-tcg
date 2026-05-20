import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/user_achievement.dart';

class HiveAchievementsDataSource {
  static const boxName = 'achievements';

  Box<String>? _box;

  Future<Box<String>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  Future<List<UserAchievement>> getAll() async {
    final hiveBox = await box;
    final achievements = <UserAchievement>[];

    for (final raw in hiveBox.values) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        achievements.add(UserAchievement.fromJson(json));
      } catch (_) {
        // Skip corrupted entries.
      }
    }

    achievements.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    return achievements;
  }

  Future<void> upsert(UserAchievement achievement) async {
    final hiveBox = await box;
    await hiveBox.put(
      achievement.achievementId,
      jsonEncode(achievement.toJson()),
    );
  }
}
