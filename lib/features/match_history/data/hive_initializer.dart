import 'package:hive_flutter/hive_flutter.dart';

import '../../achievements/data/hive_achievements_datasource.dart';
import 'hive_match_history_datasource.dart';

/// Opens Hive boxes required by retention features.
class HiveInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(HiveMatchHistoryDataSource.boxName);
    await Hive.openBox<String>(HiveAchievementsDataSource.boxName);
  }
}
