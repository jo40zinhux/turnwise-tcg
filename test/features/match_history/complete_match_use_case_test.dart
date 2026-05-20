import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match_history/domain/complete_match_params.dart';
import 'package:turnwise_tcg/features/match_history/domain/complete_match_use_case.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_history_repository.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_record.dart';
import 'package:turnwise_tcg/features/match_history/domain/sync_status.dart';

class _FakeMatchHistoryRepository implements MatchHistoryRepository {
  final List<MatchRecord> saved = [];

  @override
  Future<void> delete(String id) async {}

  @override
  Future<int> count() async => saved.length;

  @override
  Future<MatchRecord?> getById(String id) async => null;

  @override
  Future<List<MatchRecord>> getAllRecords() async => saved;

  @override
  Future<List<MatchRecord>> getRecent({int limit = 20}) async => saved;

  @override
  Future<void> save(MatchRecord record) async {
    saved.removeWhere((item) => item.id == record.id);
    saved.add(record);
  }
}

void main() {
  group('CompleteMatchUseCase', () {
    test('saves locally without cloud when user is not signed in', () async {
      final repository = _FakeMatchHistoryRepository();
      final useCase = CompleteMatchUseCase(
        repository: repository,
        getCurrentUserId: () => null,
        generateId: () => 'fixed-id',
      );

      final record = await useCase.execute(
        const CompleteMatchParams(
          gameId: 'pokemon',
          outcome: MatchOutcome.playerWin,
          notes: '  close game  ',
        ),
      );

      expect(repository.saved.length, 1);
      expect(record.syncStatus, SyncStatus.pending);
      expect(record.notes, 'close game');
      expect(record.id, 'fixed-id');
    });

    test('marks record as synced when cloud upload succeeds', () async {
      final repository = _FakeMatchHistoryRepository();
      String? syncedUserId;

      final useCase = CompleteMatchUseCase(
        repository: repository,
        getCurrentUserId: () => 'user-1',
        generateId: () => 'fixed-id',
        cloudSync: (userId, record) async {
          syncedUserId = userId;
          expect(record.id, 'fixed-id');
        },
      );

      final record = await useCase.execute(
        const CompleteMatchParams(
          gameId: 'magic',
          outcome: MatchOutcome.draw,
        ),
      );

      expect(syncedUserId, 'user-1');
      expect(record.syncStatus, SyncStatus.synced);
      expect(repository.saved.last.syncStatus, SyncStatus.synced);
    });

    test('marks record as failed when cloud upload throws', () async {
      final repository = _FakeMatchHistoryRepository();

      final useCase = CompleteMatchUseCase(
        repository: repository,
        getCurrentUserId: () => 'user-1',
        generateId: () => 'fixed-id',
        cloudSync: (_, __) async {
          throw Exception('offline');
        },
      );

      final record = await useCase.execute(
        const CompleteMatchParams(
          gameId: 'lorcana',
          outcome: MatchOutcome.playerLoss,
        ),
      );

      expect(record.syncStatus, SyncStatus.failed);
      expect(repository.saved.last.syncStatus, SyncStatus.failed);
    });
  });
}
