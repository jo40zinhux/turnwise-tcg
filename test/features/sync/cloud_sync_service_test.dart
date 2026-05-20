import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/achievements/data/firestore_achievements_datasource.dart';
import 'package:turnwise_tcg/features/achievements/data/hive_achievements_datasource.dart';
import 'package:turnwise_tcg/features/achievements/domain/user_achievement.dart';
import 'package:turnwise_tcg/features/match_history/data/firestore_match_history_datasource.dart';
import 'package:turnwise_tcg/features/match_history/data/hive_match_history_datasource.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_record.dart';
import 'package:turnwise_tcg/features/match_history/domain/sync_status.dart';
import 'package:turnwise_tcg/features/sync/data/cloud_sync_service.dart';

class _FakeMatchLocal implements HiveMatchHistoryDataSource {
  final List<MatchRecord> store = [];

  @override
  Future<List<MatchRecord>> getAll() async => List.of(store);

  @override
  Future<void> upsert(MatchRecord record) async {
    store.removeWhere((item) => item.id == record.id);
    store.add(record);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMatchRemote implements FirestoreMatchHistoryDataSource {
  final List<MatchRecord> remote;
  final List<MatchRecord> uploaded = [];

  _FakeMatchRemote(this.remote);

  @override
  Future<List<MatchRecord>> fetchAll(String userId) async => remote;

  @override
  Future<void> upsert({
    required String userId,
    required MatchRecord record,
  }) async {
    uploaded.add(record);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAchievementsLocal implements HiveAchievementsDataSource {
  final List<UserAchievement> store = [];

  @override
  Future<List<UserAchievement>> getAll() async => List.of(store);

  @override
  Future<void> upsert(UserAchievement achievement) async {
    store.removeWhere((item) => item.achievementId == achievement.achievementId);
    store.add(achievement);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAchievementsRemote implements FirestoreAchievementsDataSource {
  final List<UserAchievement> remote = [];
  final List<UserAchievement> uploaded = [];

  @override
  Future<List<UserAchievement>> fetchAll(String userId) async => remote;

  @override
  Future<void> upsert({
    required String userId,
    required UserAchievement achievement,
  }) async {
    uploaded.add(achievement);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MatchRecord _record({
  required String id,
  required DateTime updatedAt,
  SyncStatus syncStatus = SyncStatus.pending,
}) {
  final started = updatedAt.subtract(const Duration(minutes: 10));
  return MatchRecord(
    id: id,
    gameId: 'pokemon',
    startedAt: started,
    endedAt: updatedAt,
    outcome: MatchOutcome.playerWin,
    syncStatus: syncStatus,
    updatedAt: updatedAt,
  );
}

void main() {
  group('CloudSyncService', () {
    test('pulls remote matches missing locally', () async {
      final local = _FakeMatchLocal();
      final remote = _FakeMatchRemote([
        _record(id: 'm1', updatedAt: DateTime(2025, 1, 2)),
      ]);
      final service = CloudSyncService(
        matchLocal: local,
        matchRemote: remote,
        achievementsLocal: _FakeAchievementsLocal(),
        achievementsRemote: _FakeAchievementsRemote(),
      );

      await service.syncForUser('user-1');

      expect(local.store, hasLength(1));
      expect(local.store.single.syncStatus, SyncStatus.synced);
    });

    test('retries failed local matches to remote', () async {
      final local = _FakeMatchLocal()
        ..store.add(
          _record(
            id: 'm-fail',
            updatedAt: DateTime(2025, 1, 1),
            syncStatus: SyncStatus.failed,
          ),
        );
      final remote = _FakeMatchRemote([]);

      final service = CloudSyncService(
        matchLocal: local,
        matchRemote: remote,
        achievementsLocal: _FakeAchievementsLocal(),
        achievementsRemote: _FakeAchievementsRemote(),
      );

      await service.syncForUser('user-1');

      expect(remote.uploaded, hasLength(1));
      expect(local.store.single.syncStatus, SyncStatus.synced);
    });
  });
}
