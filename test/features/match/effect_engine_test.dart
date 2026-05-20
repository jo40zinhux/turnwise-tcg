import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/action_rule.dart';
import 'package:turnwise_tcg/features/match/domain/checkup_definition.dart';
import 'package:turnwise_tcg/features/match/domain/effect_definition.dart';
import 'package:turnwise_tcg/features/match/domain/effect_duration.dart';
import 'package:turnwise_tcg/features/match/domain/effect_engine.dart';
import 'package:turnwise_tcg/features/match/domain/effect_type.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_feedback.dart';
import 'package:turnwise_tcg/features/match/domain/turn_phase.dart';
import 'package:turnwise_tcg/features/match/domain/validation_rule.dart';

void main() {
  final effectEngine = EffectEngine(newInstanceId: () => 'inst-1');
  final matchEngine = MatchEngine(effects: effectEngine);

  final rules = GameRules(
    gameId: 'test',
    name: 'Test',
    phases: const [
      TurnPhase(
        id: 'draw',
        title: 'Draw',
        description: 'Draw',
        iconCode: 'copy_outlined',
      ),
      TurnPhase(
        id: 'main',
        title: 'Main',
        description: 'Main',
        iconCode: 'back_hand_rounded',
      ),
      TurnPhase(
        id: 'attack',
        title: 'Attack',
        description: 'Attack',
        iconCode: 'sports_mma',
      ),
    ],
    actions: const [
      ActionRule(
        id: 'attack',
        name: 'Attack',
        allowedPhases: ['attack'],
        validations: [],
      ),
    ],
    validations: const [],
    effects: [
      const EffectDefinition(
        id: 'sleep',
        name: 'Sleep',
        type: EffectType.status,
        duration: EffectDuration(kind: EffectDurationKind.turns, value: 1),
      ),
      const EffectDefinition(
        id: 'lock_attack',
        name: 'Cannot attack',
        type: EffectType.actionLock,
        duration: EffectDuration(kind: EffectDurationKind.turns, value: 1),
        params: {'lockedActionIds': ['attack']},
        reminderMessage: 'Blocked by sleep',
      ),
    ],
    checkups: [
      const CheckupDefinition(
        id: 'sleep_check',
        title: 'Sleep check',
        message: 'Flip a coin to wake up.',
        trigger: CheckupTrigger.betweenTurns,
        effectIds: ['sleep'],
      ),
    ],
  );

  group('EffectEngine', () {
    test('applyEffect adds active effect', () {
      const state = MatchEngineState(currentPhaseIndex: 0);
      final next = effectEngine.applyEffect(state, rules, 'sleep');
      expect(next.effectsState.activeEffects, hasLength(1));
      expect(next.effectsState.activeEffects.first.definitionId, 'sleep');
    });

    test('validateActionBlock returns feedback when action locked', () {
      var state = const MatchEngineState(currentPhaseIndex: 2);
      state = effectEngine.applyEffect(state, rules, 'lock_attack');

      final block = effectEngine.validateActionBlock(state, rules, 'attack');
      expect(block?.type, MatchFeedbackType.error);
    });
  });

  group('MatchEngine integration', () {
    test('blocks attack when lock effect active', () {
      var state = const MatchEngineState(currentPhaseIndex: 2);
      state = matchEngine.applyEffect(state, rules, 'lock_attack');

      final next = matchEngine.attemptAction(state, rules, 'attack');
      expect(next.feedback?.type, MatchFeedbackType.error);
    });

    test('between-turn checkup queued on new turn', () {
      var state = const MatchEngineState(currentPhaseIndex: 2);
      state = matchEngine.applyEffect(state, rules, 'sleep');

      final next = matchEngine.nextPhase(state, rules);
      expect(next.currentPhaseIndex, 0);
      expect(next.effectsState.pendingCheckups, isNotEmpty);
      expect(next.effectsState.pendingCheckups.first.id, 'sleep_check');
    });

    test('turn-based effect expires after new turn', () {
      var state = const MatchEngineState(currentPhaseIndex: 2);
      state = matchEngine.applyEffect(state, rules, 'sleep');

      final afterTurn = matchEngine.nextPhase(state, rules);
      expect(
        afterTurn.effectsState.activeEffects
            .where((e) => e.definitionId == 'sleep'),
        isEmpty,
      );
    });
  });
}
