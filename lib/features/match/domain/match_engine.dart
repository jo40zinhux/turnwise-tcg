import 'board_state_updater.dart';
import 'board_undo_entry.dart';
import 'condition_evaluator.dart';
import 'action_rule.dart';
import 'checkup_definition.dart';
import 'checkup_reminder.dart';
import 'effect_engine.dart';
import 'game_rules.dart';
import 'match_engine_state.dart';
import 'match_feedback.dart';
import 'match_resources_state.dart';
import 'phase_reminder_evaluator.dart';
import 'resource_spend_evaluator.dart';
import 'validation_evaluator.dart';
import 'validation_rule.dart';

class MatchEngine {
  final EffectEngine _effects;

  MatchEngine({EffectEngine? effects}) : _effects = effects ?? EffectEngine();

  EffectEngine get effects => _effects;

  MatchEngineState setPlayerWentFirst(MatchEngineState state, bool wentFirst) {
    return state.copyWith(
      effectsState: state.effectsState.copyWith(playerWentFirst: wentFirst),
    );
  }

  MatchEngineState adjustResources(
    MatchEngineState state,
    MatchResourcesState resources,
  ) {
    return state.copyWith(
      effectsState: state.effectsState.copyWith(resources: resources),
    );
  }

  MatchEngineState nextPhase(MatchEngineState state, GameRules rules) {
    if (rules.phases.isEmpty) return state;

    if (state.effectsState.isOpponentTurn) {
      return state.copyWith(
        feedback: const MatchFeedback(
          message:
              'O oponente ainda está a jogar. Toca em "Oponente terminou" antes de avançar.',
          type: MatchFeedbackType.error,
          reason: 'opponent_turn',
        ),
      );
    }

    final isLastPhase = state.currentPhaseIndex >= rules.phases.length - 1;
    final newTurnStarted = isLastPhase;

    var next = _effects.onPhaseTransition(
      state,
      rules,
      newTurnStarted: newTurnStarted,
    );

    if (isLastPhase) {
      final effects = MatchResourcesState.onNewTurn(
        rules.gameId,
        next.effectsState.resources,
      );
      next = next.copyWith(
        currentPhaseIndex: 0,
        actionUsageCount: const {},
        effectsState: next.effectsState.copyWith(
          resources: effects,
          board: next.effectsState.board.onNewTurn(),
          boardUndoStack: const [],
          manualBoardUndoStack: const [],
          isOpponentTurn: true,
        ),
        feedback: _turnFeedback(next),
      );
      return _enqueuePhaseReminder(next, rules);
    }

    next = next.copyWith(
      currentPhaseIndex: state.currentPhaseIndex + 1,
      clearFeedback: true,
    );
    return _enqueuePhaseReminder(next, rules);
  }

  MatchEngineState attemptAction(
    MatchEngineState state,
    GameRules rules,
    String actionId, {
    String? targetId,
  }) {
    final action = rules.actions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => throw Exception('Action not found: $actionId'),
    );

    if (state.effectsState.isOpponentTurn) {
      if (!action.opponentTurnOnly) {
        return state.copyWith(
          feedback: const MatchFeedback(
            message:
                'Aguarda o turno do oponente. Toca em "Oponente terminou" quando acabar.',
            type: MatchFeedbackType.error,
            reason: 'opponent_turn',
          ),
        );
      }
    } else if (action.opponentTurnOnly) {
      return state.copyWith(
        feedback: const MatchFeedback(
          message: 'Defender só está disponível no turno do oponente.',
          type: MatchFeedbackType.error,
          reason: 'opponent_turn_only',
        ),
      );
    }

    final block = _effects.validateActionBlock(state, rules, actionId);
    if (block != null) {
      return state.copyWith(feedback: block);
    }

    final currentPhaseId = rules.phases[state.currentPhaseIndex].id;

    if (!action.opponentTurnOnly && !action.allowedPhases.contains(currentPhaseId)) {
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

      final blockMessage = ValidationEvaluator.blockMessage(
        validation: validation,
        action: action,
        state: state,
        targetId: targetId,
      );
      if (blockMessage != null) {
        return state.copyWith(
          feedback: MatchFeedback(
            message: blockMessage,
            type: MatchFeedbackType.error,
            reason: validation.id,
          ),
        );
      }
    }

    final updatedUsages = Map<String, int>.from(state.actionUsageCount);
    updatedUsages[action.id] = (updatedUsages[action.id] ?? 0) + 1;

    final spentResources = ResourceSpendEvaluator.afterAction(
      rules: rules,
      action: action,
      resources: state.effectsState.resources,
    );

    final boardBefore = state.effectsState.board;
    final updatedBoard = BoardStateUpdater.afterAction(
      action: action,
      board: boardBefore,
      targetId: targetId,
    );

    var effectsAfter = state.effectsState.copyWith(
      resources: spentResources,
      board: updatedBoard,
    );

    if (targetId != null ||
        BoardStateUpdater.boardChanged(boardBefore, updatedBoard)) {
      effectsAfter = effectsAfter.pushBoardUndo(
        BoardUndoEntry(actionId: action.id, board: boardBefore),
      );
    }

    final reminder = _pendingReminder(
      rules,
      action,
      targetId,
      state.copyWith(effectsState: effectsAfter.copyWith(board: boardBefore)),
    );
    final feedback = reminder != null
        ? MatchFeedback(
            message: '${action.name} registada. Lembrete: $reminder',
            type: MatchFeedbackType.info,
          )
        : MatchFeedback(
            message: '${action.name} registada.',
            type: MatchFeedbackType.success,
          );

    var next = state.copyWith(
      actionUsageCount: updatedUsages,
      effectsState: effectsAfter,
      feedback: feedback,
    );

    next = _effects.applyEffectsFromAction(next, rules, actionId);
    return next;
  }

  MatchEngineState completeOpponentTurn(MatchEngineState state) {
    if (!state.effectsState.isOpponentTurn) {
      return state.copyWith(
        feedback: const MatchFeedback(
          message: 'Não estás no turno do oponente.',
          type: MatchFeedbackType.info,
        ),
      );
    }

    final effects = _effects.expireOpponentTurnEffects(state.effectsState);

    return state.copyWith(
      effectsState: effects.copyWith(isOpponentTurn: false),
      feedback: const MatchFeedback(
        message: 'Turno do oponente concluído.',
        type: MatchFeedbackType.success,
      ),
    );
  }

  MatchEngineState revertAction(
    MatchEngineState state,
    GameRules rules,
    String actionId,
  ) {
    final currentUsage = state.actionUsageCount[actionId] ?? 0;
    if (currentUsage <= 0) {
      return state.copyWith(
        feedback: const MatchFeedback(
          message: 'Nenhuma utilização para desfazer.',
          type: MatchFeedbackType.error,
        ),
      );
    }

    final action = rules.actions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => throw Exception('Action not found: $actionId'),
    );

    final updatedUsages = Map<String, int>.from(state.actionUsageCount);
    if (currentUsage == 1) {
      updatedUsages.remove(actionId);
    } else {
      updatedUsages[actionId] = currentUsage - 1;
    }

    final refundedResources = ResourceSpendEvaluator.afterRevert(
      rules: rules,
      action: action,
      resources: state.effectsState.resources,
    );

    final effectsAfterUndo =
        state.effectsState.popBoardUndoFor(actionId).copyWith(
              resources: refundedResources,
            );

    var next = state.copyWith(
      actionUsageCount: updatedUsages,
      effectsState: effectsAfterUndo,
      feedback: MatchFeedback(
        message: '${action.name} desfeita.',
        type: MatchFeedbackType.success,
      ),
    );

    next = _effects.removeLastEffectsFromAction(next, rules, actionId);
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

  MatchEngineState _enqueuePhaseReminder(
    MatchEngineState state,
    GameRules rules,
  ) {
    final phaseIndex = state.currentPhaseIndex.clamp(0, rules.phases.length - 1);
    final phaseId = rules.phases[phaseIndex].id;

    // Process declarative phase-start checkups from rules JSON.
    var next = state;
    for (final checkup in rules.checkups) {
      if (checkup.trigger != CheckupTrigger.onPhaseStart) continue;
      if (checkup.phaseIds.isNotEmpty && !checkup.phaseIds.contains(phaseId)) {
        continue;
      }
      next = _enqueueCheckup(
        next,
        CheckupReminder(
          id: checkup.id,
          title: checkup.title,
          message: checkup.message,
          relatedEffectIds: checkup.effectIds,
        ),
      );
    }

    final reminder = PhaseReminderEvaluator.onPhaseEntered(
      rules: rules,
      phaseId: phaseId,
      state: next,
    );
    if (reminder == null) return next;
    return _enqueueCheckup(next, reminder);
  }

  MatchEngineState _enqueueCheckup(
    MatchEngineState state,
    CheckupReminder reminder,
  ) {
    final effects = state.effectsState;
    if (effects.pendingCheckups.any((r) => r.id == reminder.id)) {
      return state;
    }

    return state.copyWith(
      effectsState: effects.copyWith(
        pendingCheckups: [...effects.pendingCheckups, reminder],
      ),
    );
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

  String? _pendingReminder(
    GameRules rules,
    ActionRule action,
    String? targetId,
    MatchEngineState state,
  ) {
    for (final validationId in action.validations) {
      ValidationRule? validation;
      for (final v in rules.validations) {
        if (v.id == validationId) {
          validation = v;
          break;
        }
      }
      if (validation == null || validation.type != 'condition') continue;

      if (targetId != null && ConditionEvaluator.isAutoEnforceable(validation)) {
        final target = state.effectsState.board.targetById(targetId);
        if (target != null &&
            ConditionEvaluator.isMet(validation: validation, target: target)) {
          continue;
        }
      }

      return validation.errorMessage;
    }
    return null;
  }
}
