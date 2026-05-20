import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/match_session.dart';
import 'package:turnwise_tcg/features/match/domain/match_session_restore.dart';

void main() {
  group('MatchSessionRestore', () {
    test('returns default state when session is null', () {
      final state = MatchSessionRestore.engineState(
        session: null,
        gameId: 'pokemon',
        phaseCount: 5,
      );

      expect(state.currentPhaseIndex, 0);
      expect(state.actionUsageCount, isEmpty);
    });

    test('clamps phase index when rules have fewer phases', () {
      final session = MatchSession(
        gameId: 'pokemon',
        currentPhaseIndex: 9,
        actionUsageCount: const {'draw': 1},
        updatedAt: DateTime.now(),
      );

      final state = MatchSessionRestore.engineState(
        session: session,
        gameId: 'pokemon',
        phaseCount: 4,
      );

      expect(state.currentPhaseIndex, 3);
      expect(state.actionUsageCount['draw'], 1);
    });

    test('ignores session for a different game', () {
      final session = MatchSession(
        gameId: 'magic',
        currentPhaseIndex: 2,
        actionUsageCount: const {},
        updatedAt: DateTime.now(),
      );

      final state = MatchSessionRestore.engineState(
        session: session,
        gameId: 'pokemon',
        phaseCount: 5,
      );

      expect(state.currentPhaseIndex, 0);
    });

    test('clampPhaseIndex handles empty phase list', () {
      expect(MatchSessionRestore.clampPhaseIndex(3, 0), 0);
    });
  });
}
