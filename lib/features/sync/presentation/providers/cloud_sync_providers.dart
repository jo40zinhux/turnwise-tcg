import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/observability/app_crashlytics_provider.dart';
import '../../../achievements/presentation/providers/achievements_providers.dart';
import '../../../auth/domain/auth_repository.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../home/presentation/providers/home_dashboard_providers.dart';
import '../../../match_history/presentation/providers/match_history_providers.dart';
import '../../../stats/presentation/providers/match_stats_providers.dart';
import '../../data/cloud_sync_service.dart';

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(
    matchLocal: ref.watch(hiveMatchHistoryDataSourceProvider),
    matchRemote: ref.watch(firestoreMatchHistoryDataSourceProvider),
    achievementsLocal: ref.watch(hiveAchievementsDataSourceProvider),
    achievementsRemote: ref.watch(firestoreAchievementsDataSourceProvider),
  );
});

/// Runs cloud pull + retry once per authenticated session.
final cloudSyncSessionProvider =
    StateNotifierProvider<CloudSyncSessionNotifier, String?>((ref) {
  return CloudSyncSessionNotifier(ref);
});

class CloudSyncSessionNotifier extends StateNotifier<String?> {
  final Ref _ref;

  CloudSyncSessionNotifier(this._ref) : super(null);

  Future<void> syncIfNeeded(String userId) async {
    if (state == userId) return;
    state = userId;

    try {
      await _ref.read(cloudSyncServiceProvider).syncForUser(userId);
      _invalidateLocalCaches();
    } catch (error, stack) {
      debugPrint('Cloud sync failed for $userId: $error\n$stack');
      await _ref.read(appCrashlyticsProvider).recordError(
            error,
            stack,
            reason: 'cloud_sync',
          );
      state = null;
    }
  }

  void reset() => state = null;

  void _invalidateLocalCaches() {
    _ref.invalidate(recentMatchHistoryProvider);
    _ref.invalidate(matchHistoryCountProvider);
    _ref.invalidate(matchStatsProvider);
    _ref.invalidate(achievementProgressListProvider);
    _ref.invalidate(recentGamesProvider);
  }
}

/// Listens to auth and triggers background sync for signed-in users.
final cloudSyncListenerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AuthUser?>>(authStateProvider, (previous, next) {
    final user = next.valueOrNull;
    if (user == null) {
      ref.read(cloudSyncSessionProvider.notifier).reset();
      return;
    }
    if (next.isLoading) return;

    ref.read(cloudSyncSessionProvider.notifier).syncIfNeeded(user.uid);
  });
});
