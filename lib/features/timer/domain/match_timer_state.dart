import 'timer_config.dart';
import 'timer_profile.dart';

class MatchTimerState {
  final TimerProfile profile;
  final bool isRunning;
  final int elapsedSeconds;
  final int? remainingSeconds;
  final int playerGamesWon;
  final int opponentGamesWon;
  final int currentBo3Game;

  const MatchTimerState({
    required this.profile,
    this.isRunning = true,
    this.elapsedSeconds = 0,
    this.remainingSeconds,
    this.playerGamesWon = 0,
    this.opponentGamesWon = 0,
    this.currentBo3Game = 1,
  });

  bool get isPaused => !isRunning;

  bool get isCountdown => TimerConfig.usesCountdown(profile);

  bool get isBo3SeriesComplete =>
      profile == TimerProfile.bo3 &&
      (playerGamesWon >= TimerConfig.gamesToWinBo3 ||
          opponentGamesWon >= TimerConfig.gamesToWinBo3);

  bool get isRoundExpired =>
      isCountdown && remainingSeconds != null && remainingSeconds! <= 0;

  int get displaySeconds {
    if (isCountdown) {
      return (remainingSeconds ?? 0).clamp(0, 86400);
    }
    return elapsedSeconds.clamp(0, 86400);
  }

  MatchTimerState copyWith({
    TimerProfile? profile,
    bool? isRunning,
    int? elapsedSeconds,
    int? remainingSeconds,
    bool clearRemaining = false,
    int? playerGamesWon,
    int? opponentGamesWon,
    int? currentBo3Game,
  }) {
    return MatchTimerState(
      profile: profile ?? this.profile,
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      remainingSeconds:
          clearRemaining ? null : (remainingSeconds ?? this.remainingSeconds),
      playerGamesWon: playerGamesWon ?? this.playerGamesWon,
      opponentGamesWon: opponentGamesWon ?? this.opponentGamesWon,
      currentBo3Game: currentBo3Game ?? this.currentBo3Game,
    );
  }

  factory MatchTimerState.initial(TimerProfile profile) {
    return MatchTimerState(
      profile: profile,
      isRunning: true,
      remainingSeconds: TimerConfig.initialRemainingSeconds(profile),
    );
  }

  factory MatchTimerState.fromSessionFields({
    required TimerProfile profile,
    required bool isRunning,
    required int elapsedSeconds,
    int? remainingSeconds,
    required int playerGamesWon,
    required int opponentGamesWon,
    required int currentBo3Game,
  }) {
    return MatchTimerState(
      profile: profile,
      isRunning: isRunning,
      elapsedSeconds: elapsedSeconds,
      remainingSeconds: remainingSeconds ??
          TimerConfig.initialRemainingSeconds(profile),
      playerGamesWon: playerGamesWon,
      opponentGamesWon: opponentGamesWon,
      currentBo3Game: currentBo3Game,
    );
  }
}
