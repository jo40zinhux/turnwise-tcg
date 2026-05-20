import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../match/presentation/services/match_session_persist_coordinator.dart';
import '../../domain/match_timer_engine.dart';
import '../../domain/match_timer_state.dart';
import '../../domain/timer_profile.dart';

final matchTimerEngineProvider = Provider<MatchTimerEngine>((ref) {
  return const MatchTimerEngine();
});

class MatchTimerNotifier extends StateNotifier<MatchTimerState?> {
  static const _persistIntervalSeconds = 15;

  final String gameId;
  final MatchTimerEngine _engine;
  final MatchSessionPersistCoordinator _sessionPersist;

  Timer? _tickTimer;
  int _ticksSinceLastPersist = 0;

  MatchTimerNotifier({
    required this.gameId,
    required MatchTimerEngine engine,
    required MatchSessionPersistCoordinator sessionPersist,
  })  : _engine = engine,
        _sessionPersist = sessionPersist,
        super(null) {
    _restoreFromSession();
  }

  void _restoreFromSession() {
    final session = _sessionPersist.snapshot;
    if (session == null || session.gameId != gameId) return;
    final profile = session.timerProfile;
    if (profile == null) return;

    state = MatchTimerState.fromSessionFields(
      profile: profile,
      isRunning: session.timerIsRunning,
      elapsedSeconds: session.timerElapsedSeconds,
      remainingSeconds: session.timerRemainingSeconds,
      playerGamesWon: session.bo3PlayerWins,
      opponentGamesWon: session.bo3OpponentWins,
      currentBo3Game: session.bo3CurrentGame,
    );

    if (state!.isRunning && !state!.isBo3SeriesComplete && !state!.isRoundExpired) {
      _startTicking();
    }
  }

  void setProfile(TimerProfile profile) {
    state = MatchTimerState.initial(profile);
    _persistTimerToSession(flushImmediately: true);
    _startTicking();
  }

  void togglePause() {
    final current = state;
    if (current == null) return;

    state = _engine.togglePause(current);
    if (state!.isRunning) {
      _startTicking();
    } else {
      _stopTicking();
    }
    _persistTimerToSession(flushImmediately: true);
  }

  void resetRound() {
    final current = state;
    if (current == null) return;

    state = _engine.resetRound(current);
    _persistTimerToSession(flushImmediately: true);
    _startTicking();
  }

  void recordPlayerGameWin() {
    final current = state;
    if (current == null) return;

    state = _engine.recordPlayerGameWin(current);
    _handlePostTickState();
    _persistTimerToSession(flushImmediately: true);
  }

  void recordOpponentGameWin() {
    final current = state;
    if (current == null) return;

    state = _engine.recordOpponentGameWin(current);
    _handlePostTickState();
    _persistTimerToSession(flushImmediately: true);
  }

  void _startTicking() {
    _tickTimer?.cancel();
    _ticksSinceLastPersist = 0;
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _stopTicking() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  void _onTick() {
    final current = state;
    if (current == null || !current.isRunning) return;

    state = _engine.tick(current);
    _handlePostTickState();

    _ticksSinceLastPersist++;
    if (_ticksSinceLastPersist >= _persistIntervalSeconds) {
      _ticksSinceLastPersist = 0;
      _persistTimerToSession();
    }
  }

  void _handlePostTickState() {
    if (state!.isRoundExpired || state!.isBo3SeriesComplete) {
      _stopTicking();
    }
  }

  void _persistTimerToSession({bool flushImmediately = false}) {
    final timerState = state;
    if (timerState == null) return;

    _sessionPersist.update(
      (session) => session.copyWith(
        startedAt: session.startedAt ?? DateTime.now(),
        timerProfile: timerState.profile,
        timerElapsedSeconds: timerState.elapsedSeconds,
        timerRemainingSeconds: timerState.remainingSeconds,
        timerIsRunning: timerState.isRunning,
        bo3PlayerWins: timerState.playerGamesWon,
        bo3OpponentWins: timerState.opponentGamesWon,
        bo3CurrentGame: timerState.currentBo3Game,
      ),
    );

    if (flushImmediately) {
      _sessionPersist.flushNow();
    }
  }

  @override
  void dispose() {
    _stopTicking();
    _persistTimerToSession(flushImmediately: true);
    super.dispose();
  }
}

final matchTimerProvider =
    StateNotifierProvider.family<MatchTimerNotifier, MatchTimerState?, String>(
  (ref, gameId) {
    return MatchTimerNotifier(
      gameId: gameId,
      engine: ref.watch(matchTimerEngineProvider),
      sessionPersist: ref.watch(matchSessionPersistCoordinatorProvider(gameId)),
    );
  },
);
