import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/game_rules.dart';
import '../../domain/rules_repository.dart';
import '../../data/local_rules_repository.dart';

final rulesRepositoryProvider = Provider<RulesRepository>((ref) {
  return LocalRulesRepository();
});

final gameRulesProvider = FutureProvider.family<GameRules, String>((ref, gameId) async {
  final repo = ref.watch(rulesRepositoryProvider);
  return await repo.getGameRules(gameId);
});

class MatchState {
  final int currentPhaseIndex;
  final String? currentFeedback;
  final Map<String, int> actionUsageCount;

  const MatchState({
    required this.currentPhaseIndex,
    this.currentFeedback,
    this.actionUsageCount = const {},
  });

  MatchState copyWith({
    int? currentPhaseIndex,
    String? currentFeedback,
    bool clearFeedback = false,
    Map<String, int>? actionUsageCount,
  }) {
    return MatchState(
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      currentFeedback: clearFeedback ? null : (currentFeedback ?? this.currentFeedback),
      actionUsageCount: actionUsageCount ?? this.actionUsageCount,
    );
  }
}

class MatchStateNotifier extends StateNotifier<MatchState> {
  final GameRules? rules;

  MatchStateNotifier(this.rules) : super(const MatchState(currentPhaseIndex: 0));

  void nextPhase() {
    if (rules == null || rules!.phases.isEmpty) return;

    if (state.currentPhaseIndex < rules!.phases.length - 1) {
      state = state.copyWith(
        currentPhaseIndex: state.currentPhaseIndex + 1,
        clearFeedback: true,
      );
    } else {
      // Loop back to start
      state = state.copyWith(
        currentPhaseIndex: 0,
        currentFeedback: "Novo turno iniciado! Não esqueça de desvirar suas cartas.",
        actionUsageCount: const {}, // Reset tracking on new turn
      );
    }
  }

  void attemptAction(String actionId) {
    if (rules == null) return;

    final action = rules!.actions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => throw Exception('Action not found'),
    );

    final currentPhaseId = rules!.phases[state.currentPhaseIndex].id;

    if (!action.allowedPhases.contains(currentPhaseId)) {
      // Phase validation failed
      _setPhaseErrorFeedback(action);
      return;
    }

    // Check Limit validations
    for (final validationId in action.validations) {
      final validation = rules!.validations.firstWhere(
        (v) => v.id == validationId,
        orElse: () => throw Exception('Validation not found: $validationId'),
      );

      if (validation.type == 'limit') {
        final maxPerTurn = validation.params['max'] as int? ?? 1;
        final currentUsage = state.actionUsageCount[action.id] ?? 0;
        
        if (currentUsage >= maxPerTurn) {
          // Blocked by usage limit
          state = state.copyWith(
            currentFeedback: validation.errorMessage.replaceAll('{actionName}', action.name),
          );
          return; // Stop further processing
        }
      }
    }

    // Validate if action explicitly has trackUsage flag, increment anyway if reached this point
    // Though usually it's handled via the limit validation rules.
    final updatedUsages = Map<String, int>.from(state.actionUsageCount);
    updatedUsages[action.id] = (updatedUsages[action.id] ?? 0) + 1;

    state = state.copyWith(
      clearFeedback: true,
      actionUsageCount: updatedUsages,
    );
  }

  void _setPhaseErrorFeedback(action) {
    // If it has validations configured but failed because of phase, we might find a specific error message.
    // For simplicity, we just look for any phase/type message, or show default blocker.
    if (action.validations.isNotEmpty) {
        final validationId = action.validations.first;
        final validation = rules!.validations.firstWhere(
          (v) => v.id == validationId,
          orElse: () => throw Exception('Validation not found'),
        );
        state = state.copyWith(
          currentFeedback: validation.errorMessage.replaceAll('{actionName}', action.name),
        );
      } else {
        state = state.copyWith(
          currentFeedback: "Ação de ${action.name} bloqueada nesta fase do jogo.",
        );
      }
  }

  void clearFeedback() {
    state = state.copyWith(clearFeedback: true);
  }
}

final matchStateProvider = StateNotifierProvider.family<MatchStateNotifier, MatchState, String>((ref, gameId) {
  final rulesAsyncValue = ref.watch(gameRulesProvider(gameId));
  return MatchStateNotifier(rulesAsyncValue.valueOrNull);
});
