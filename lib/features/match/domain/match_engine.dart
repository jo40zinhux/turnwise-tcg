import 'action_rule.dart';
import 'game_rules.dart';
import 'match_engine_state.dart';
import 'match_feedback.dart';

class MatchEngine {
  MatchEngineState nextPhase(MatchEngineState state, GameRules rules) {
    if (rules.phases.isEmpty) return state;

    if (state.currentPhaseIndex < rules.phases.length - 1) {
      return state.copyWith(
        currentPhaseIndex: state.currentPhaseIndex + 1,
        clearFeedback: true,
      );
    }

    return state.copyWith(
      currentPhaseIndex: 0,
      actionUsageCount: const {},
      feedback: const MatchFeedback(
        message:
            'Novo turno iniciado! Não esqueça de desvirar suas cartas.',
        type: MatchFeedbackType.info,
      ),
    );
  }

  MatchEngineState attemptAction(
    MatchEngineState state,
    GameRules rules,
    String actionId,
  ) {
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

    return state.copyWith(
      actionUsageCount: updatedUsages,
      feedback: MatchFeedback(
        message: '${action.name} registada.',
        type: MatchFeedbackType.success,
      ),
    );
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
