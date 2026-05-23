import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/action_rule.dart';
import 'package:turnwise_tcg/features/match/domain/effect_definition.dart';
import 'package:turnwise_tcg/features/match/domain/effect_duration.dart';
import 'package:turnwise_tcg/features/match/domain/effect_engine.dart';
import 'package:turnwise_tcg/features/match/domain/effect_source.dart';
import 'package:turnwise_tcg/features/match/domain/effect_type.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';
import 'package:turnwise_tcg/features/match/domain/turn_phase.dart';

void main() {
  final engine = EffectEngine(newInstanceId: () => 'test-id');

  final rules = GameRules(
    gameId: 'test',
    name: 'Test',
    phases: const [
      TurnPhase(
        id: 'main',
        title: 'Main',
        description: 'Main',
        iconCode: 'back_hand_rounded',
      ),
    ],
    actions: [
      const ActionRule(
        id: 'attack',
        name: 'Attack',
        allowedPhases: ['main'],
        validations: [],
        metadata: {'applyEffects': ['stun']},
      ),
    ],
    validations: const [],
    effects: [
      EffectDefinition(
        id: 'stun',
        name: 'Stun',
        type: EffectType.actionLock,
        duration: const EffectDuration(kind: EffectDurationKind.turns, value: 1),
        params: const {'lockedActionIds': ['attack']},
      ),
    ],
  );

  test('removeLastEffectsFromAction removes batch from last use', () {
    var state = const MatchEngineState(currentPhaseIndex: 0);
    state = engine.applyEffectsFromAction(state, rules, 'attack');
    expect(state.effectsState.activeEffects, hasLength(1));

    final reverted = engine.removeLastEffectsFromAction(state, rules, 'attack');
    expect(reverted.effectsState.activeEffects, isEmpty);
  });

  test('removeLastEffectsFromAction is LIFO across multiple uses', () {
    var state = const MatchEngineState(currentPhaseIndex: 0);
    state = engine.applyEffectsFromAction(state, rules, 'attack');
    state = state.copyWith(
      effectsState: state.effectsState.copyWith(
        activeEffects: [
          ...state.effectsState.activeEffects,
          state.effectsState.activeEffects.first.copyWith(
            instanceId: 'second',
            source: EffectSource.fromAction('attack'),
          ),
        ],
      ),
    );

    final reverted = engine.removeLastEffectsFromAction(state, rules, 'attack');
    expect(reverted.effectsState.activeEffects, hasLength(1));
    expect(reverted.effectsState.activeEffects.first.instanceId, isNot('second'));
  });
}
