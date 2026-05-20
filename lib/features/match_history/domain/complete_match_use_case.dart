import 'package:uuid/uuid.dart';

import 'complete_match_params.dart';
import 'match_history_repository.dart';
import 'match_record.dart';
import 'sync_status.dart';

typedef MatchHistoryCloudSync = Future<void> Function(
  String userId,
  MatchRecord record,
);

String _defaultMatchId() => const Uuid().v4();

/// Archives a completed match locally and optionally syncs to cloud.
class CompleteMatchUseCase {
  final MatchHistoryRepository _repository;
  final MatchHistoryCloudSync? _cloudSync;
  final String? Function() _getCurrentUserId;
  final String Function() _generateId;

  CompleteMatchUseCase({
    required MatchHistoryRepository repository,
    MatchHistoryCloudSync? cloudSync,
    required String? Function() getCurrentUserId,
    String Function()? generateId,
  })  : _repository = repository,
        _cloudSync = cloudSync,
        _getCurrentUserId = getCurrentUserId,
        _generateId = generateId ?? _defaultMatchId;

  Future<MatchRecord> execute(CompleteMatchParams params) async {
    final now = DateTime.now();
    final startedAt = params.startedAt ?? now;

    var record = MatchRecord(
      id: _generateId(),
      gameId: params.gameId,
      startedAt: startedAt,
      endedAt: now,
      outcome: params.outcome,
      notes: _normalizeNotes(params.notes),
      timerProfile: params.timerProfile,
      roundsPlayed: params.roundsPlayed,
      syncStatus: SyncStatus.pending,
      updatedAt: now,
    );

    await _repository.save(record);

    final userId = _getCurrentUserId();
    final cloudSync = _cloudSync;
    if (userId != null && cloudSync != null) {
      try {
        await cloudSync(userId, record);
        record = record.copyWith(
          syncStatus: SyncStatus.synced,
          updatedAt: DateTime.now(),
        );
        await _repository.save(record);
      } catch (_) {
        record = record.copyWith(
          syncStatus: SyncStatus.failed,
          updatedAt: DateTime.now(),
        );
        await _repository.save(record);
      }
    }

    return record;
  }

  String? _normalizeNotes(String? notes) {
    final trimmed = notes?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.length > 500 ? trimmed.substring(0, 500) : trimmed;
  }
}
