import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../../match_history/presentation/providers/match_history_providers.dart';
import '../../data/achievements_repository_impl.dart';
import '../../data/bundled_achievements_datasource.dart';
import '../../data/firestore_achievements_datasource.dart';
import '../../data/hive_achievements_datasource.dart';
import '../../domain/achievement_definition.dart';
import '../../domain/achievement_metric.dart';
import '../../domain/achievements_repository.dart';
import '../../domain/evaluate_achievements_use_case.dart';

final bundledAchievementsDataSourceProvider =
    Provider<BundledAchievementsDataSource>((ref) {
  return BundledAchievementsDataSource();
});

final hiveAchievementsDataSourceProvider =
    Provider<HiveAchievementsDataSource>((ref) {
  return HiveAchievementsDataSource();
});

final firestoreAchievementsDataSourceProvider =
    Provider<FirestoreAchievementsDataSource>((ref) {
  return FirestoreAchievementsDataSource();
});

final achievementsRepositoryProvider = Provider<AchievementsRepository>((ref) {
  final firestore = ref.watch(firestoreAchievementsDataSourceProvider);

  return AchievementsRepositoryImpl(
    bundled: ref.watch(bundledAchievementsDataSourceProvider),
    local: ref.watch(hiveAchievementsDataSourceProvider),
    getCurrentUserId: () => ref.read(authStateProvider).value?.uid,
    cloudSync: (userId, achievement) => firestore.upsert(
      userId: userId,
      achievement: achievement,
    ),
  );
});

final evaluateAchievementsUseCaseProvider =
    Provider<EvaluateAchievementsUseCase>((ref) {
  return EvaluateAchievementsUseCase(
    ref.watch(achievementsRepositoryProvider),
  );
});

class AchievementProgress {
  final AchievementDefinition definition;
  final int current;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const AchievementProgress({
    required this.definition,
    required this.current,
    required this.isUnlocked,
    this.unlockedAt,
  });

  double get progressFraction {
    if (definition.target <= 0) return 0;
    return (current / definition.target).clamp(0, 1);
  }
}

final achievementProgressListProvider =
    FutureProvider<List<AchievementProgress>>((ref) async {
  final repository = ref.watch(achievementsRepositoryProvider);
  final definitions = await repository.getDefinitions();
  final unlocked = await repository.getUnlocked();
  final records =
      await ref.watch(matchHistoryRepositoryProvider).getAllRecords();

  final unlockedMap = {
    for (final item in unlocked) item.achievementId: item.unlockedAt,
  };

  final matchCount = records.length;
  final winCount = records.where((r) => r.isWin).length;

  return definitions.map((definition) {
    final current = switch (definition.metric) {
      AchievementMetric.matchCount => matchCount,
      AchievementMetric.winCount => winCount,
    };

    return AchievementProgress(
      definition: definition,
      current: current,
      isUnlocked: unlockedMap.containsKey(definition.id),
      unlockedAt: unlockedMap[definition.id],
    );
  }).toList();
});
