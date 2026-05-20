import 'action_rule.dart';
import 'effect_engine.dart';
import 'game_rules.dart';
import 'match_engine_state.dart';
import 'match_feedback.dart';

class MatchEngine {
  final EffectEngine _effects;

  MatchEngine({EffectEngine? effects}) : _effects = effects ?? EffectEngine();

  EffectEngine get effects => _effects;

  MatchEngineState nextPhase(MatchEngineState state, GameRules rules) {
    if (rules.phases.isEmpty) return state;

    final isLastPhase = state.currentPhaseIndex >= rules.phases.length - 1;
    final newTurnStarted = isLastPhase;

    var next = _effects.onPhaseTransition(
      state,
      rules,
      newTurnStarted: newTurnStarted,
    );

    if (isLastPhase) {
      next = next.copyWith(
        currentPhaseIndex: 0,
        actionUsageCount: const {},
        feedback: _turnFeedback(next),
      );
      return next;
    }

    return next.copyWith(
      currentPhaseIndex: state.currentPhaseIndex + 1,
      clearFeedback: true,
    );
  }

  MatchEngineState attemptAction(
    MatchEngineState state,
    GameRules rules,
    String actionId,
  ) {
    final block = _effects.validateActionBlock(state, rules, actionId);
    if (block != null) {
      return state.copyWith(feedback: block);
    }

    final action = rules.actions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => throw Exception('Action not found: $actionId'),
    );

    final currentPhaseId = rules.phases[state.currentPhaseIndex].id;

    if (!action.allowedPhases.contains(currentPhaseId)) {
      return state.copyWith(
        feedback: MatchFeedback(
          message: _phaseErrorMessage(action, rules),
          type: MatchFeedbackType.error,
        ),
      );
    }

    for (final validationId in action.validations) {
      final validation = rules.validations.firstWhere(
        (v) => v.id == validationId,
        orElse: () => throw Exception('Validation not found: $validationId'),
      );

      if (validation.type == 'limit') {
        final maxPerTurn = validation.params['max'] as int? ?? 1;
        final currentUsage = state.actionUsageCount[action.id] ?? 0;

        if (currentUsage >= maxPerTurn) {
          return state.copyWith(
            feedback: MatchFeedback(
              message: validation.errorMessage
                  .replaceAll('{actionName}', action.name),
              type: MatchFeedbackType.error,
            ),
          );
        }
      }
    }

    final updatedUsages = Map<String, int>.from(state.actionUsageCount);
    updatedUsages[action.id] = (updatedUsages[action.id] ?? 0) + 1;

    var next = state.copyWith(
      actionUsageCount: updatedUsages,
      feedback: MatchFeedback(
        message: '${action.name} registada.',
        type: MatchFeedbackType.success,
      ),
    );

    next = _effects.applyEffectsFromAction(next, rules, actionId);
    return next;
  }

  MatchEngineState applyEffect(
    MatchEngineState state,
    GameRules rules,
    String effectDefinitionId,
  ) {
    return _effects.applyEffect(state, rules, effectDefinitionId);
  }

  MatchEngineState removeEffect(MatchEngineState state, String instanceId) {
    return _effects.removeEffect(state, instanceId);
  }

  MatchEngineState dismissCheckup(MatchEngineState state, String checkupId) {
    return _effects.dismissCheckup(state, checkupId);
  }

  bool isActionLocked(MatchEngineState state, String actionId) {
    return _effects.lockedActionIds(state).contains(actionId);
  }

  int? maxUsagePerTurn(GameRules rules, ActionRule action) {
    for (final validationId in action.validations) {
      try {
        final validation =
            rules.validations.firstWhere((v) => v.id == validationId);
        if (validation.type == 'limit') {
          return validation.params['max'] as int? ?? 1;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  MatchFeedback _turnFeedback(MatchEngineState state) {
    if (state.effectsState.pendingCheckups.isNotEmpty) {
      final first = state.effectsState.pendingCheckups.first;
      return MatchFeedback(
        message: first.message,
        type: MatchFeedbackType.info,
      );
    }

    return const MatchFeedback(
      message: 'Novo turno iniciado! Não esqueça de desvirar suas cartas.',
      type: MatchFeedbackType.info,
    );
  }

  String _phaseErrorMessage(ActionRule action, GameRules rules) {
    if (action.validations.isEmpty) {
      return 'Ação de ${action.name} bloqueada nesta fase do jogo.';
    }

    final validationId = action.validations.first;
    final validation = rules.validations.firstWhere(
      (v) => v.id == validationId,
      orElse: () => throw Exception('Validation not found'),
    );
    return validation.errorMessage.replaceAll('{actionName}', action.name);
  }
}
