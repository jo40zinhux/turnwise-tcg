import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_record.dart';
import 'package:turnwise_tcg/features/match_history/domain/sync_status.dart';
import 'package:turnwise_tcg/features/timer/domain/timer_profile.dart';

void main() {
  group('MatchRecord', () {
    test('serializes and deserializes with optional fields', () {
      final record = MatchRecord(
        id: 'match-1',
        gameId: 'pokemon',
        startedAt: DateTime.parse('2026-05-19T10:00:00.000'),
        endedAt: DateTime.parse('2026-05-19T10:45:00.000'),
        outcome: MatchOutcome.playerWin,
        notes: 'Great game',
        timerProfile: TimerProfile.bo3,
        roundsPlayed: 2,
        syncStatus: SyncStatus.pending,
        updatedAt: DateTime.parse('2026-05-19T10:45:00.000'),
      );

      final restored = MatchRecord.fromJson(record.toJson());

      expect(restored.id, record.id);
      expect(restored.gameId, 'pokemon');
      expect(restored.outcome, MatchOutcome.playerWin);
      expect(restored.notes, 'Great game');
      expect(restored.timerProfile, TimerProfile.bo3);
      expect(restored.roundsPlayed, 2);
      expect(restored.duration.inMinutes, 45);
      expect(restored.isWin, isTrue);
    });

    test('deserializes legacy json without optional fields', () {
      final restored = MatchRecord.fromJson({
        'id': 'legacy-1',
        'gameId': 'magic',
        'startedAt': '2026-05-19T10:00:00.000',
        'endedAt': '2026-05-19T10:30:00.000',
        'outcome': 'draw',
        'updatedAt': '2026-05-19T10:30:00.000',
      });

      expect(restored.timerProfile, isNull);
      expect(restored.notes, isNull);
      expect(restored.outcome, MatchOutcome.draw);
      expect(restored.syncStatus, SyncStatus.pending);
    });
  });
}
