import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/achievement_definition.dart';

class BundledAchievementsDataSource {
  static const assetPath = 'assets/achievements.json';

  Future<List<AchievementDefinition>> loadDefinitions() async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = json['achievements'] as List<dynamic>? ?? [];

    return list
        .map((item) => AchievementDefinition.fromJson(
              item as Map<String, dynamic>,
            ))
        .toList();
  }
}
