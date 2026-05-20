import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/features/match/data/shared_preferences_match_session_repository.dart';
import 'package:turnwise_tcg/features/match/domain/match_session.dart';
import 'package:turnwise_tcg/features/timer/domain/timer_profile.dart';

void main() {
  group('MatchSession', () {
    test('serializes and deserializes', () {
      final session = MatchSession(
        gameId: 'pokemon',
        currentPhaseIndex: 2,
        actionUsageCount: const {'attach_energy': 1},
        updatedAt: DateTime.parse('2026-05-19T12:00:00.000'),
        startedAt: DateTime.parse('2026-05-19T11:00:00.000'),
        timerProfile: TimerProfile.bo1,
      );

      final restored = MatchSession.fromJson(session.toJson());

      expect(restored.gameId, 'pokemon');
      expect(restored.currentPhaseIndex, 2);
      expect(restored.actionUsageCount['attach_energy'], 1);
      expect(restored.updatedAt, session.updatedAt);
      expect(restored.startedAt, session.startedAt);
      expect(restored.timerProfile, TimerProfile.bo1);
    });

    test('deserializes legacy json without retention fields', () {
      final restored = MatchSession.fromJson({
        'gameId': 'magic',
        'currentPhaseIndex': 1,
        'actionUsageCount': <String, dynamic>{},
        'updatedAt': '2026-05-19T12:00:00.000',
      });

      expect(restored.startedAt, isNull);
      expect(restored.timerProfile, isNull);
      expect(restored.timerElapsedSeconds, 0);
      expect(restored.bo3CurrentGame, 1);
    });

    test('serializes timer fields', () {
      final session = MatchSession(
        gameId: 'pokemon',
        currentPhaseIndex: 0,
        actionUsageCount: const {},
        updatedAt: DateTime.parse('2026-05-19T12:00:00.000'),
        timerProfile: TimerProfile.bo3,
        timerElapsedSeconds: 120,
        timerRemainingSeconds: 2800,
        timerIsRunning: false,
        bo3PlayerWins: 1,
        bo3OpponentWins: 0,
        bo3CurrentGame: 2,
      );

      final restored = MatchSession.fromJson(session.toJson());
      expect(restored.timerProfile, TimerProfile.bo3);
      expect(restored.timerElapsedSeconds, 120);
      expect(restored.bo3CurrentGame, 2);
    });
  });

  group('SharedPreferencesMatchSessionRepository', () {
    test('saves and loads active session', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repository = SharedPreferencesMatchSessionRepository(prefs);

      final session = MatchSession(
        gameId: 'magic',
        currentPhaseIndex: 1,
        actionUsageCount: const {},
        updatedAt: DateTime.parse('2026-05-19T12:00:00.000'),
      );

      await repository.saveSession(session);
      final loaded = repository.getActiveSession();

      expect(loaded?.gameId, 'magic');
      expect(loaded?.currentPhaseIndex, 1);

      await repository.clearActiveSession();
      expect(repository.getActiveSession(), isNull);
    });
  });
}
