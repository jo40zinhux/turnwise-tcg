import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/timer/domain/match_timer_engine.dart';
import 'package:turnwise_tcg/features/timer/domain/match_timer_state.dart';
import 'package:turnwise_tcg/features/timer/domain/timer_config.dart';
import 'package:turnwise_tcg/features/timer/domain/timer_profile.dart';

void main() {
  const engine = MatchTimerEngine();

  group('count-up (casual)', () {
    test('tick increases elapsed seconds', () {
      const state = MatchTimerState(
        profile: TimerProfile.casual,
        isRunning: true,
        elapsedSeconds: 10,
      );

      final next = engine.tick(state);
      expect(next.elapsedSeconds, 11);
    });
  });

  group('countdown (round)', () {
    test('tick decreases remaining seconds', () {
      final state = MatchTimerState(
        profile: TimerProfile.round,
        isRunning: true,
        remainingSeconds: 10,
      );

      final next = engine.tick(state);
      expect(next.remainingSeconds, 9);
      expect(next.displaySeconds, 9);
    });

    test('stops at zero', () {
      final state = MatchTimerState(
        profile: TimerProfile.round,
        isRunning: true,
        remainingSeconds: 0,
      );

      final next = engine.tick(state);
      expect(next.isRunning, isFalse);
      expect(next.remainingSeconds, 0);
    });
  });

  group('BO3', () {
    test('records game wins and advances game counter', () {
      var state = MatchTimerState.initial(TimerProfile.bo3);

      state = engine.recordPlayerGameWin(state);
      expect(state.playerGamesWon, 1);
      expect(state.currentBo3Game, 2);
      expect(state.remainingSeconds, TimerConfig.roundDurationSeconds);
    });

    test('ends series when a player reaches two wins', () {
      var state = MatchTimerState(
        profile: TimerProfile.bo3,
        playerGamesWon: 1,
        opponentGamesWon: 0,
        remainingSeconds: TimerConfig.roundDurationSeconds,
      );

      state = engine.recordPlayerGameWin(state);
      expect(state.isBo3SeriesComplete, isTrue);
      expect(state.isRunning, isFalse);
    });
  });

  test('togglePause flips running state', () {
    const state = MatchTimerState(
      profile: TimerProfile.casual,
      isRunning: true,
    );

    final paused = engine.togglePause(state);
    expect(paused.isRunning, isFalse);

    final resumed = engine.togglePause(paused);
    expect(resumed.isRunning, isTrue);
  });
}
