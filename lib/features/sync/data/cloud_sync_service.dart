import 'package:flutter/foundation.dart';

import '../../achievements/data/firestore_achievements_datasource.dart';
import '../../achievements/data/hive_achievements_datasource.dart';
import '../../match_history/data/firestore_match_history_datasource.dart';
import '../../match_history/data/hive_match_history_datasource.dart';
import '../../match_history/domain/sync_status.dart';

/// Pulls remote Firestore data into Hive and retries failed/pending uploads.
class CloudSyncService {
  final HiveMatchHistoryDataSource _matchLocal;
  final FirestoreMatchHistoryDataSource _matchRemote;
  final HiveAchievementsDataSource _achievementsLocal;
  final FirestoreAchievementsDataSource _achievementsRemote;

  CloudSyncService({
    required HiveMatchHistoryDataSource matchLocal,
    required FirestoreMatchHistoryDataSource matchRemote,
    required HiveAchievementsDataSource achievementsLocal,
    required FirestoreAchievementsDataSource achievementsRemote,
  })  : _matchLocal = matchLocal,
        _matchRemote = matchRemote,
        _achievementsLocal = achievementsLocal,
        _achievementsRemote = achievementsRemote;

  Future<void> syncForUser(String userId) async {
    await _pullMatches(userId);
    await _pullAchievements(userId);
    await _pushPendingAchievements(userId);
    await _retryPendingMatches(userId);
  }

  Future<void> _pullMatches(String userId) async {
    final remoteRecords = await _matchRemote.fetchAll(userId);
    if (remoteRecords.isEmpty) return;

    final localRecords = await _matchLocal.getAll();
    final localById = {for (final record in localRecords) record.id: record};

    for (final remote in remoteRecords) {
      final local = localById[remote.id];
      if (local == null) {
        await _matchLocal.upsert(
          remote.copyWith(syncStatus: SyncStatus.synced),
        );
        continue;
      }

      if (remote.updatedAt.isAfter(local.updatedAt)) {
        await _matchLocal.upsert(
          remote.copyWith(syncStatus: SyncStatus.synced),
        );
      }
    }
  }

  Future<void> _pullAchievements(String userId) async {
    final remoteAchievements = await _achievementsRemote.fetchAll(userId);
    if (remoteAchievements.isEmpty) return;

    final localAchievements = await _achievementsLocal.getAll();
    final localById = {
      for (final item in localAchievements) item.achievementId: item,
    };

    for (final remote in remoteAchievements) {
      final local = localById[remote.achievementId];
      if (local == null) {
        await _achievementsLocal.upsert(remote);
        continue;
      }

      if (remote.unlockedAt.isBefore(local.unlockedAt)) {
        await _achievementsLocal.upsert(remote);
      }
    }
  }

  Future<void> _pushPendingAchievements(String userId) async {
    final local = await _achievementsLocal.getAll();
    for (final achievement in local) {
      try {
        await _achievementsRemote.upsert(
          userId: userId,
          achievement: achievement,
        );
      } catch (error, stack) {
        debugPrint(
          'Achievement upload retry failed (${achievement.achievementId}): '
          '$error\n$stack',
        );
      }
    }
  }

  Future<void> _retryPendingMatches(String userId) async {
    final localRecords = await _matchLocal.getAll();
    final pending = localRecords.where(
      (record) =>
          record.syncStatus == SyncStatus.pending ||
          record.syncStatus == SyncStatus.failed,
    );

    for (final record in pending) {
      try {
        await _matchRemote.upsert(userId: userId, record: record);
        await _matchLocal.upsert(
          record.copyWith(
            syncStatus: SyncStatus.synced,
            updatedAt: DateTime.now(),
          ),
        );
      } catch (error, stack) {
        debugPrint('Match upload retry failed (${record.id}): $error\n$stack');
        await _matchLocal.upsert(
          record.copyWith(
            syncStatus: SyncStatus.failed,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }
}
