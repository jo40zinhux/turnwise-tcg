import 'timer_config.dart';
import 'timer_profile.dart';
import 'match_timer_state.dart';

class MatchTimerEngine {
  const MatchTimerEngine();

  MatchTimerState tick(MatchTimerState state) {
    if (!state.isRunning || state.isBo3SeriesComplete) return state;

    if (state.isCountdown) {
      final remaining = state.remainingSeconds;
      if (remaining == null) return state;
      if (remaining <= 0) {
        return state.copyWith(isRunning: false, remainingSeconds: 0);
      }
      return state.copyWith(
        remainingSeconds: remaining - 1,
        elapsedSeconds: state.elapsedSeconds + 1,
      );
    }

    return state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
  }

  MatchTimerState togglePause(MatchTimerState state) {
    if (state.isBo3SeriesComplete || state.isRoundExpired) return state;
    return state.copyWith(isRunning: !state.isRunning);
  }

  MatchTimerState resetRound(MatchTimerState state) {
    if (state.profile == TimerProfile.casual) {
      return state.copyWith(
        elapsedSeconds: 0,
        isRunning: true,
        clearRemaining: true,
      );
    }

    return state.copyWith(
      elapsedSeconds: 0,
      remainingSeconds: TimerConfig.initialRemainingSeconds(state.profile),
      isRunning: true,
    );
  }

  MatchTimerState recordPlayerGameWin(MatchTimerState state) {
    if (state.profile != TimerProfile.bo3 || state.isBo3SeriesComplete) {
      return state;
    }

    final playerWins = state.playerGamesWon + 1;
    return _afterBo3Game(state, playerWins, state.opponentGamesWon);
  }

  MatchTimerState recordOpponentGameWin(MatchTimerState state) {
    if (state.profile != TimerProfile.bo3 || state.isBo3SeriesComplete) {
      return state;
    }

    final opponentWins = state.opponentGamesWon + 1;
    return _afterBo3Game(state, state.playerGamesWon, opponentWins);
  }

  MatchTimerState _afterBo3Game(
    MatchTimerState state,
    int playerWins,
    int opponentWins,
  ) {
    final seriesDone = playerWins >= TimerConfig.gamesToWinBo3 ||
        opponentWins >= TimerConfig.gamesToWinBo3;

    if (seriesDone) {
      return state.copyWith(
        playerGamesWon: playerWins,
        opponentGamesWon: opponentWins,
        isRunning: false,
      );
    }

    return state.copyWith(
      playerGamesWon: playerWins,
      opponentGamesWon: opponentWins,
      currentBo3Game: state.currentBo3Game + 1,
      elapsedSeconds: 0,
      remainingSeconds: TimerConfig.roundDurationSeconds,
      isRunning: true,
    );
  }
}
