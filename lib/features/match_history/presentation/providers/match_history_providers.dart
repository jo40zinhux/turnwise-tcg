import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../../../core/observability/app_analytics_provider.dart';
import '../../data/firestore_match_history_datasource.dart';
import '../../data/hive_match_history_datasource.dart';
import '../../data/match_history_repository_impl.dart';
import '../../domain/complete_match_params.dart';
import '../../domain/complete_match_use_case.dart';
import '../../domain/finish_match_use_case.dart';
import '../../domain/match_history_repository.dart';
import '../../domain/match_record.dart';
import '../../../match/presentation/providers/match_providers.dart';
import '../../../achievements/presentation/providers/achievements_providers.dart';
import '../../../home/presentation/providers/home_dashboard_providers.dart';
import '../../../stats/presentation/providers/match_stats_providers.dart';

final hiveMatchHistoryDataSourceProvider =
    Provider<HiveMatchHistoryDataSource>((ref) {
  return HiveMatchHistoryDataSource();
});

final firestoreMatchHistoryDataSourceProvider =
    Provider<FirestoreMatchHistoryDataSource>((ref) {
  return FirestoreMatchHistoryDataSource();
});

final matchHistoryRepositoryProvider =
    Provider<MatchHistoryRepository>((ref) {
  return MatchHistoryRepositoryImpl(
    ref.watch(hiveMatchHistoryDataSourceProvider),
  );
});

final completeMatchUseCaseProvider = Provider<CompleteMatchUseCase>((ref) {
  final firestore = ref.watch(firestoreMatchHistoryDataSourceProvider);

  return CompleteMatchUseCase(
    repository: ref.watch(matchHistoryRepositoryProvider),
    getCurrentUserId: () => ref.read(authStateProvider).value?.uid,
    cloudSync: (userId, record) async {
      try {
        await firestore.upsert(userId: userId, record: record);
      } catch (error, stack) {
        debugPrint(
          'Match history cloud sync failed (${record.id}): $error\n$stack',
        );
        rethrow;
      }
    },
  );
});

final finishMatchUseCaseProvider = Provider<FinishMatchUseCase>((ref) {
  return FinishMatchUseCase(
    completeMatch: ref.watch(completeMatchUseCaseProvider),
    evaluateAchievements: ref.watch(evaluateAchievementsUseCaseProvider),
    historyRepository: ref.watch(matchHistoryRepositoryProvider),
  );
});

final matchHistoryCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(matchHistoryRepositoryProvider);
  return repository.count();
});

final recentMatchHistoryProvider =
    FutureProvider<List<MatchRecord>>((ref) async {
  final repository = ref.watch(matchHistoryRepositoryProvider);
  return repository.getRecent(limit: 50);
});

/// Archives the match, syncs when authenticated, clears active session.
Future<FinishMatchResult> completeAndEndActiveMatch(
  WidgetRef ref, {
  required String gameId,
  required CompleteMatchParams params,
}) async {
  final result = await ref.read(finishMatchUseCaseProvider).execute(params);
  final record = result.record;
  final newlyUnlocked = result.newlyUnlocked;

  await ref.read(appAnalyticsProvider).logMatchCompleted(
        gameId: gameId,
        durationSeconds: record.duration.inSeconds,
        outcome: params.outcome.storageKey,
        timerProfile: params.timerProfile?.storageKey,
      );

  ref.invalidate(recentMatchHistoryProvider);
  ref.invalidate(matchHistoryCountProvider);
  ref.invalidate(matchStatsProvider);

  for (final achievement in newlyUnlocked) {
    await ref.read(appAnalyticsProvider).logAchievementUnlocked(
          achievementId: achievement.id,
        );
  }

  ref.invalidate(achievementProgressListProvider);
  ref.invalidate(recentGamesProvider);

  await endActiveMatch(ref, gameId);

  return result;
}
