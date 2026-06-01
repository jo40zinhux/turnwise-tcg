import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/observability/app_analytics_provider.dart';
import '../../data/bundled_effects_datasource.dart';
import '../../data/bundled_rules_datasource.dart';
import '../../data/cached_rules_repository.dart';
import '../../data/file_rules_cache_datasource.dart';
import '../../domain/game_rules.dart';
import '../../domain/match_board_state.dart';
import '../../domain/match_effects_state.dart';
import '../../domain/match_engine.dart';
import '../../domain/match_resources_state.dart';
import '../../domain/match_engine_state.dart';
import '../../domain/match_feedback.dart';
import '../../domain/match_session_restore.dart';
import '../../domain/rules_repository.dart';
import '../services/match_session_persist_coordinator.dart';
import '../../../timer/presentation/providers/match_timer_providers.dart';
import 'match_session_providers.dart';

final bundledRulesDataSourceProvider = Provider<BundledRulesDataSource>((ref) {
  return BundledRulesDataSource();
});

final bundledEffectsDataSourceProvider =
    Provider<BundledEffectsDataSource>((ref) {
  return BundledEffectsDataSource();
});

final fileRulesCacheDataSourceProvider =
    Provider<FileRulesCacheDataSource>((ref) {
  return FileRulesCacheDataSource();
});

final rulesRepositoryProvider = Provider<RulesRepository>((ref) {
  return CachedRulesRepository(
    bundled: ref.watch(bundledRulesDataSourceProvider),
    effects: ref.watch(bundledEffectsDataSourceProvider),
    cache: ref.watch(fileRulesCacheDataSourceProvider),
  );
});

final gameRulesProvider =
    FutureProvider.family<GameRules, String>((ref, gameId) async {
  final repo = ref.watch(rulesRepositoryProvider);
  return repo.getGameRules(gameId);
});

final matchEngineProvider = Provider<MatchEngine>((ref) => MatchEngine());

class MatchState {
  final MatchEngineState engineState;

  const MatchState({required this.engineState});

  int get currentPhaseIndex => engineState.currentPhaseIndex;
  Map<String, int> get actionUsageCount => engineState.actionUsageCount;
  MatchEffectsState get effectsState => engineState.effectsState;
  MatchFeedback? get feedback => engineState.feedback;

  MatchState copyWith({MatchEngineState? engineState}) {
    return MatchState(engineState: engineState ?? this.engineState);
  }
}

class MatchStateNotifier extends StateNotifier<MatchState> {
  final Ref _ref;
  final String gameId;
  final MatchEngine _engine;
  final MatchSessionPersistCoordinator _sessionPersist;

  MatchStateNotifier({
    required Ref ref,
    required this.gameId,
    required MatchEngine engine,
    required MatchEngineState initialEngineState,
    required MatchSessionPersistCoordinator sessionPersist,
  })  : _ref = ref,
        _engine = engine,
        _sessionPersist = sessionPersist,
        super(MatchState(engineState: initialEngineState)) {
    Future.microtask(_persistPhaseToSession);
  }

  GameRules? get _rules => _ref.read(gameRulesProvider(gameId)).valueOrNull;

  void nextPhase() {
    final rules = _rules;
    if (rules == null) return;

    state = MatchState(
      engineState: _engine.nextPhase(state.engineState, rules),
    );

    if (state.feedback?.type == MatchFeedbackType.error) {
      _persistPhaseToSession();
      return;
    }

    unawaited(
      _ref.read(appAnalyticsProvider).logPhaseAdvanced(
            gameId: gameId,
            phaseIndex: state.currentPhaseIndex,
          ),
    );
    _persistPhaseToSession();
  }

  void attemptAction(
    String actionId, {
    String? targetId,
    MatchBoardState? board,
  }) {
    final rules = _rules;
    if (rules == null) return;

    var engineState = state.engineState;
    if (board != null) {
      engineState = engineState.copyWith(
        effectsState: engineState.effectsState.copyWith(board: board),
      );
    }

    state = MatchState(
      engineState: _engine.attemptAction(
        engineState,
        rules,
        actionId,
        targetId: targetId,
      ),
    );

    final feedback = state.feedback;
    if (feedback?.type == MatchFeedbackType.error) {
      _logActionBlockedAnalytics(rules, actionId, feedback!.reason);
    }

    _persistPhaseToSession();
  }

  void _logActionBlockedAnalytics(
    GameRules rules,
    String actionId,
    String? reason,
  ) {
    final analytics = _ref.read(appAnalyticsProvider);
    if (reason != null &&
        reason != 'opponent_turn' &&
        rules.validations.any((v) => v.id == reason)) {
      unawaited(
        analytics.logMatchValidationBlocked(
          gameId: gameId,
          actionId: actionId,
          validationId: reason,
        ),
      );
      return;
    }
    unawaited(
      analytics.logActionBlocked(gameId: gameId, actionId: actionId),
    );
  }

  void revertAction(String actionId) {
    final rules = _rules;
    if (rules == null) return;

    state = MatchState(
      engineState: _engine.revertAction(state.engineState, rules, actionId),
    );

    final feedback = state.feedback;
    if (feedback?.type == MatchFeedbackType.success) {
      unawaited(
        _ref.read(appAnalyticsProvider).logActionReverted(
              gameId: gameId,
              actionId: actionId,
            ),
      );
    }

    _persistPhaseToSession();
  }

  void clearFeedback() {
    state = MatchState(
      engineState: state.engineState.copyWith(clearFeedback: true),
    );
  }

  void applyEffect(String effectDefinitionId) {
    final rules = _rules;
    if (rules == null) return;

    state = MatchState(
      engineState: _engine.applyEffect(
        state.engineState,
        rules,
        effectDefinitionId,
      ),
    );
    _persistPhaseToSession();
  }

  void removeActiveEffect(String instanceId) {
    state = MatchState(
      engineState: _engine.removeEffect(state.engineState, instanceId),
    );
    _persistPhaseToSession();
  }

  void dismissCheckup(String checkupId) {
    state = MatchState(
      engineState: _engine.dismissCheckup(state.engineState, checkupId),
    );
    _persistPhaseToSession();
  }

  void setPlayerWentFirst(bool wentFirst) {
    state = MatchState(
      engineState: _engine.setPlayerWentFirst(state.engineState, wentFirst),
    );
    unawaited(
      _ref.read(appAnalyticsProvider).logMatchSetupCompleted(
            gameId: gameId,
            wentFirst: wentFirst,
          ),
    );
    _persistPhaseToSession();
  }

  void updateResources(MatchResourcesState resources) {
    state = MatchState(
      engineState: _engine.adjustResources(state.engineState, resources),
    );
    _persistPhaseToSession();
  }

  void updateBoard(MatchBoardState board) {
    state = MatchState(
      engineState: state.engineState.copyWith(
        effectsState: state.engineState.effectsState.copyWith(board: board),
      ),
    );
    _persistPhaseToSession();
  }

  void completeOpponentTurn() {
    state = MatchState(
      engineState: _engine.completeOpponentTurn(state.engineState),
    );
    _persistPhaseToSession();
  }

  bool isActionLocked(String actionId) {
    return _engine.isActionLocked(state.engineState, actionId);
  }

  void reconcilePhaseIndex(int phaseCount) {
    final clamped = MatchSessionRestore.clampPhaseIndex(
      state.currentPhaseIndex,
      phaseCount,
    );
    if (clamped == state.currentPhaseIndex) return;

    state = MatchState(
      engineState: state.engineState.copyWith(currentPhaseIndex: clamped),
    );
    _persistPhaseToSession();
  }

  void _persistPhaseToSession() {
    if (_sessionPersist.isAbandoned) return;
    _sessionPersist.update(
      (session) => session.copyWith(
        startedAt: session.startedAt ?? DateTime.now(),
        currentPhaseIndex: state.currentPhaseIndex,
        actionUsageCount: state.actionUsageCount,
        effectsState: state.effectsState,
      ),
    );
  }

  @override
  void dispose() {
    if (!_sessionPersist.isAbandoned) {
      unawaited(_sessionPersist.flushNow());
    }
    super.dispose();
  }
}

MatchEngineState _initialEngineState(Ref ref, String gameId) {
  final coordinator = ref.read(matchSessionPersistCoordinatorProvider(gameId));
  final session = coordinator.snapshot ??
      ref.read(matchSessionRepositoryProvider).getActiveSession();
  final rulesAsync = ref.read(gameRulesProvider(gameId));

  final phaseCount = rulesAsync.when(
    data: (rules) => rules.phases.length,
    loading: () => (session?.currentPhaseIndex ?? 0) + 1,
    error: (_, __) => (session?.currentPhaseIndex ?? 0) + 1,
  );

  return MatchSessionRestore.engineState(
    session: session,
    gameId: gameId,
    phaseCount: phaseCount,
  );
}

final matchStateProvider =
    StateNotifierProvider.family<MatchStateNotifier, MatchState, String>(
  (ref, gameId) {
    return MatchStateNotifier(
      ref: ref,
      gameId: gameId,
      engine: ref.watch(matchEngineProvider),
      initialEngineState: _initialEngineState(ref, gameId),
      sessionPersist: ref.read(matchSessionPersistCoordinatorProvider(gameId)),
    );
  },
);

/// Clears active match from memory and storage without recording history.
Future<void> dismissActiveMatch(WidgetRef ref, String gameId) async {
  await ref.read(matchSessionPersistCoordinatorProvider(gameId)).abandon();
  await ref.read(matchSessionRepositoryProvider).clearActiveSession();
  ref.invalidate(activeMatchSessionProvider);
  ref.invalidate(matchSessionPersistCoordinatorProvider(gameId));
}

Future<void> endActiveMatch(WidgetRef ref, String gameId) async {
  await ref.read(appAnalyticsProvider).logMatchEnded(gameId: gameId);
  await dismissActiveMatch(ref, gameId);
}
