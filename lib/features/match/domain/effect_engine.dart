import 'package:uuid/uuid.dart';

import 'active_effect.dart';
import 'checkup_definition.dart';
import 'checkup_reminder.dart';
import 'effect_definition.dart';
import 'effect_duration.dart';
import 'effect_source.dart';
import 'effect_type.dart';
import 'game_rules.dart';
import 'match_effects_state.dart';
import 'match_engine_state.dart';
import 'match_feedback.dart';
import 'trigger_definition.dart';

/// Pure effect + checkup logic for the match engine.
class EffectEngine {
  final String Function() _newInstanceId;

  EffectEngine({String Function()? newInstanceId})
      : _newInstanceId = newInstanceId ?? _defaultInstanceId;

  static String _defaultInstanceId() => const Uuid().v4();

  MatchEngineState applyEffect(
    MatchEngineState state,
    GameRules rules,
    String effectDefinitionId, {
    EffectSource? source,
  }) {
    final definition = _findEffectDefinition(rules, effectDefinitionId);
    if (definition == null) return state;

    final active = _instantiate(definition, source ?? EffectSource.manual());
    var effects = state.effectsState.copyWith(
      activeEffects: [...state.effectsState.activeEffects, active],
    );

    effects = _enqueueCheckupsForTrigger(
      effects,
      rules,
      CheckupTrigger.onEffectApplied,
      appliedEffectId: effectDefinitionId,
    );

    return state.copyWith(
      effectsState: effects,
      feedback: MatchFeedback(
        message: '${definition.name} aplicado.',
        type: MatchFeedbackType.info,
      ),
    );
  }

  MatchEngineState removeEffect(MatchEngineState state, String instanceId) {
    final updated = state.effectsState.activeEffects
        .where((effect) => effect.instanceId != instanceId)
        .toList();

    return state.copyWith(
      effectsState: state.effectsState.copyWith(activeEffects: updated),
    );
  }

  MatchEngineState dismissCheckup(MatchEngineState state, String checkupId) {
    final updated = state.effectsState.pendingCheckups
        .where((reminder) => reminder.id != checkupId)
        .toList();

    return state.copyWith(
      effectsState: state.effectsState.copyWith(pendingCheckups: updated),
    );
  }

  /// Called when advancing phase; [newTurnStarted] when wrapping to phase 0.
  MatchEngineState onPhaseTransition(
    MatchEngineState state,
    GameRules rules, {
    required bool newTurnStarted,
  }) {
    var effects = _tickPhaseDurations(state.effectsState);

    if (newTurnStarted) {
      effects = _enqueueBetweenTurnCheckups(effects, rules);
      effects = _runTriggers(effects, rules, CheckupTrigger.betweenTurns);
      effects = _tickTurnDurations(effects);
      effects = effects.copyWith(turnNumber: effects.turnNumber + 1);
    }

    return state.copyWith(effectsState: effects);
  }

  MatchFeedback? validateActionBlock(
    MatchEngineState state,
    GameRules rules,
    String actionId,
  ) {
    final locks = state.effectsState.lockedActionIds;
    if (locks.contains(actionId)) {
      final blocker = state.effectsState.nonExpiredEffects.firstWhere(
        (effect) => effect.lockedActionIds.contains(actionId),
        orElse: () => state.effectsState.nonExpiredEffects.first,
      );
      return MatchFeedback(
        message: blocker.reminderMessage ??
            'Ação bloqueada por ${blocker.name}.',
        type: MatchFeedbackType.error,
      );
    }

    for (final effect in state.effectsState.nonExpiredEffects) {
      if (effect.type == EffectType.phaseSkip) {
        final blockedPhases = effect.lockedActionIds;
        final phaseId = rules.phases[state.currentPhaseIndex].id;
        if (blockedPhases.contains(phaseId)) {
          return MatchFeedback(
            message: effect.reminderMessage ??
                'Fase bloqueada por ${effect.name}.',
            type: MatchFeedbackType.error,
          );
        }
      }
    }

    return null;
  }

  MatchEngineState applyEffectsFromAction(
    MatchEngineState state,
    GameRules rules,
    String actionId,
  ) {
    final action = rules.actions.where((a) => a.id == actionId).firstOrNull;
    if (action == null) return state;

    final applyIds = action.metadata['applyEffects'];
    if (applyIds is! List || applyIds.isEmpty) return state;

    var next = state;
    for (final raw in applyIds) {
      final effectId = raw.toString();
      next = applyEffect(
        next,
        rules,
        effectId,
        source: EffectSource.fromAction(actionId),
      );
    }
    return next;
  }

  List<String> lockedActionIds(MatchEngineState state) {
    return state.effectsState.lockedActionIds.toList();
  }

  ActiveEffect _instantiate(EffectDefinition definition, EffectSource source) {
    int? remainingTurns;
    int? remainingPhases;

    switch (definition.duration.kind) {
      case EffectDurationKind.turns:
        remainingTurns = definition.duration.value ?? 1;
      case EffectDurationKind.phases:
        remainingPhases = definition.duration.value ?? 1;
      case EffectDurationKind.permanent:
        break;
    }

    final lockedIds = _lockedActionsFor(definition);

    return ActiveEffect(
      instanceId: _newInstanceId(),
      definitionId: definition.id,
      type: definition.type,
      source: source,
      name: definition.name,
      iconCode: definition.iconCode,
      remainingTurns: remainingTurns,
      remainingPhases: remainingPhases,
      lockedActionIds: lockedIds,
      reminderMessage: definition.reminderMessage,
    );
  }

  List<String> _lockedActionsFor(EffectDefinition definition) {
    if (definition.type == EffectType.attackRestriction) {
      final custom = definition.lockedActionIds;
      return custom.isNotEmpty ? custom : const ['attack'];
    }
    if (definition.type == EffectType.phaseSkip) {
      final phase = definition.params['skippedPhase'];
      if (phase is String) return [phase];
      return definition.lockedActionIds;
    }
    if (definition.type == EffectType.actionLock) {
      return definition.lockedActionIds;
    }
    return const [];
  }

  MatchEffectsState _tickPhaseDurations(MatchEffectsState effects) {
    final updated = <ActiveEffect>[];
    for (final effect in effects.activeEffects) {
      if (effect.remainingPhases == null) {
        updated.add(effect);
        continue;
      }
      final nextPhases = effect.remainingPhases! - 1;
      if (nextPhases <= 0) continue;
      updated.add(effect.copyWith(remainingPhases: nextPhases));
    }
    return effects.copyWith(activeEffects: updated);
  }

  MatchEffectsState _tickTurnDurations(MatchEffectsState effects) {
    final updated = <ActiveEffect>[];
    for (final effect in effects.activeEffects) {
      if (effect.remainingTurns == null) {
        updated.add(effect);
        continue;
      }
      final nextTurns = effect.remainingTurns! - 1;
      if (nextTurns <= 0) continue;
      updated.add(effect.copyWith(remainingTurns: nextTurns));
    }
    return effects.copyWith(activeEffects: updated);
  }

  MatchEffectsState _enqueueBetweenTurnCheckups(
    MatchEffectsState effects,
    GameRules rules,
  ) {
    var next = effects;
    for (final checkup in rules.checkups) {
      if (checkup.trigger != CheckupTrigger.betweenTurns) continue;
      if (!_shouldFireCheckup(checkup, next)) continue;
      next = _addReminder(next, checkup);
    }
    return next;
  }

  MatchEffectsState _enqueueCheckupsForTrigger(
    MatchEffectsState effects,
    GameRules rules,
    CheckupTrigger trigger, {
    String? appliedEffectId,
  }) {
    var next = effects;
    for (final checkup in rules.checkups) {
      if (checkup.trigger != trigger) continue;
      if (appliedEffectId != null &&
          checkup.effectIds.isNotEmpty &&
          !checkup.effectIds.contains(appliedEffectId)) {
        continue;
      }
      if (!_shouldFireCheckup(checkup, next)) continue;
      next = _addReminder(next, checkup);
    }
    return next;
  }

  MatchEffectsState _runTriggers(
    MatchEffectsState effects,
    GameRules rules,
    CheckupTrigger when,
  ) {
    var next = effects;
    for (final trigger in rules.triggers) {
      if (trigger.when != when) continue;
      if (!_hasRequiredEffects(trigger, next)) continue;
      if (next.activeEffects.any((e) => e.definitionId == trigger.applyEffectId)) {
        continue;
      }

      final definition = _findEffectDefinition(rules, trigger.applyEffectId);
      if (definition == null) continue;

      next = next.copyWith(
        activeEffects: [
          ...next.activeEffects,
          _instantiate(definition, EffectSource.fromDefinition(trigger.id)),
        ],
      );
    }
    return next;
  }

  bool _shouldFireCheckup(CheckupDefinition checkup, MatchEffectsState effects) {
    if (checkup.effectIds.isEmpty) return true;
    return effects.nonExpiredEffects
        .any((effect) => checkup.effectIds.contains(effect.definitionId));
  }

  bool _hasRequiredEffects(TriggerDefinition trigger, MatchEffectsState effects) {
    if (trigger.requiredActiveEffectIds.isEmpty) return true;
    return trigger.requiredActiveEffectIds.every(
      (id) => effects.nonExpiredEffects.any((e) => e.definitionId == id),
    );
  }

  MatchEffectsState _addReminder(
    MatchEffectsState effects,
    CheckupDefinition checkup,
  ) {
    if (effects.pendingCheckups.any((r) => r.id == checkup.id)) {
      return effects;
    }

    return effects.copyWith(
      pendingCheckups: [
        ...effects.pendingCheckups,
        CheckupReminder(
          id: checkup.id,
          title: checkup.title,
          message: checkup.message,
          relatedEffectIds: checkup.effectIds,
        ),
      ],
    );
  }

  EffectDefinition? _findEffectDefinition(GameRules rules, String id) {
    for (final effect in rules.effects) {
      if (effect.id == id) return effect;
    }
    return null;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
