import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/board_target.dart';
import 'package:turnwise_tcg/features/match/domain/condition_evaluator.dart';
import 'package:turnwise_tcg/features/match/domain/match_board_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_effects_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_feedback.dart';
import 'package:turnwise_tcg/features/match/domain/validation_rule.dart';

import 'support/rules_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConditionEvaluator', () {
    const enteredTarget = BoardTarget(
      id: 'slot_0',
      label: 'Ativo',
      enteredThisTurn: true,
    );
    const readyTarget = BoardTarget(id: 'slot_0', label: 'Ativo');
    const exertedTarget = BoardTarget(
      id: 'slot_0',
      label: 'Ativo',
      exerted: true,
    );

    test('evolve target that entered play this turn fails condition', () {
      const validation = ValidationRule(
        id: 'evolve_entered_play',
        type: 'condition',
        params: {'requires': 'target_not_played_this_turn'},
        errorMessage: 'Não evoluir no turno em que entrou.',
      );

      expect(
        ConditionEvaluator.isMet(validation: validation, target: enteredTarget),
        isFalse,
      );
      expect(
        ConditionEvaluator.isMet(validation: validation, target: readyTarget),
        isTrue,
      );
    });

    test('exerted target cannot act', () {
      const validation = ValidationRule(
        id: 'exerted_check',
        type: 'condition',
        params: {'requires': 'character_ready'},
        errorMessage: 'Exaurido.',
      );

      expect(
        ConditionEvaluator.isMet(validation: validation, target: exertedTarget),
        isFalse,
      );
    });

    test('yugioh monster must be in attack position', () {
      const validation = ValidationRule(
        id: 'attack_position_check',
        type: 'condition',
        params: {'requires': 'attacker_in_attack_position'},
        errorMessage: 'Somente em posição de ataque.',
      );
      const defenseTarget = BoardTarget(
        id: 'slot_0',
        label: 'Monstro 1',
        inAttackPosition: false,
      );

      expect(
        ConditionEvaluator.isMet(
          validation: validation,
          target: defenseTarget,
        ),
        isFalse,
      );
    });
  });

  group('BoardState integration', () {
    late MatchEngine engine;

    setUp(() {
      engine = RulesTestHarness.createEngine();
    });

    test('pokemon evolve blocked when target entered play this turn', () async {
      final rules = await RulesTestHarness.loadRules('pokemon');
      final board = MatchBoardState.initialForGame('pokemon').withTarget(
        const BoardTarget(id: 'slot_0', label: 'Ativo', enteredThisTurn: true),
      );

      final state = MatchEngineState(
        currentPhaseIndex: RulesTestHarness.phaseIndex(rules, 'actions'),
        effectsState: MatchEffectsState(
          turnNumber: 2,
          playerWentFirst: false,
          board: board,
        ),
      );

      final next = engine.attemptAction(
        state,
        rules,
        'evolve',
        targetId: 'slot_0',
      );

      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.feedback?.message, contains('entrou em jogo'));
    });

    test('pokemon evolve succeeds when target is eligible', () async {
      final rules = await RulesTestHarness.loadRules('pokemon');
      final board = MatchBoardState.initialForGame('pokemon');

      final state = MatchEngineState(
        currentPhaseIndex: RulesTestHarness.phaseIndex(rules, 'actions'),
        effectsState: MatchEffectsState(
          turnNumber: 2,
          playerWentFirst: false,
          board: board,
        ),
      );

      final next = engine.attemptAction(
        state,
        rules,
        'evolve',
        targetId: 'slot_0',
      );

      expect(next.feedback?.type, MatchFeedbackType.success);
      expect(next.actionUsageCount['evolve'], 1);
    });

    test('lorcana challenge blocked on exerted target', () async {
      final rules = await RulesTestHarness.loadRules('lorcana');
      final board = MatchBoardState.initialForGame('lorcana').withTarget(
        const BoardTarget(
          id: 'slot_0',
          label: 'Personagem 1',
          exerted: true,
        ),
      );

      final state = MatchEngineState(
        currentPhaseIndex: RulesTestHarness.phaseIndex(rules, 'main'),
        effectsState: MatchEffectsState(
          turnNumber: 2,
          board: board,
        ),
      );

      final next = engine.attemptAction(
        state,
        rules,
        'challenge',
        targetId: 'slot_0',
      );

      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.feedback?.message, contains('exauridos'));
    });

    test('board clears per-turn flags on new turn', () async {
      final rules = await RulesTestHarness.loadRules('pokemon');
      var state = MatchEngineState(
        currentPhaseIndex: rules.phases.length - 1,
        effectsState: MatchEffectsState(
          turnNumber: 1,
          board: MatchBoardState.initialForGame('pokemon').withTarget(
            const BoardTarget(
              id: 'slot_0',
              label: 'Ativo',
              enteredThisTurn: true,
              exerted: true,
            ),
          ),
        ),
      );

      state = engine.nextPhase(state, rules);
      final target = state.effectsState.board.targetById('slot_0')!;

      expect(state.effectsState.turnNumber, 2);
      expect(target.enteredThisTurn, isFalse);
      expect(target.exerted, isFalse);
    });

    test('yugioh attack blocked when target in defense position', () async {
      final rules = await RulesTestHarness.loadRules('yugioh');
      final board = MatchBoardState.initialForGame('yugioh').withTarget(
        const BoardTarget(
          id: 'slot_0',
          label: 'Monstro 1',
          inAttackPosition: false,
        ),
      );

      final state = MatchEngineState(
        currentPhaseIndex: RulesTestHarness.phaseIndex(rules, 'battle'),
        effectsState: MatchEffectsState(
          turnNumber: 2,
          board: board,
        ),
      );

      final next = engine.attemptAction(
        state,
        rules,
        'declare_attack',
        targetId: 'slot_0',
      );

      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.feedback?.message, contains('posição'));
    });

    test('undo restores board snapshot', () async {
      final rules = await RulesTestHarness.loadRules('pokemon');
      final board = MatchBoardState.initialForGame('pokemon');

      var state = MatchEngineState(
        currentPhaseIndex: RulesTestHarness.phaseIndex(rules, 'actions'),
        effectsState: MatchEffectsState(
          turnNumber: 2,
          board: board,
        ),
      );

      state = engine.attemptAction(
        state,
        rules,
        'evolve',
        targetId: 'slot_0',
      );
      expect(state.effectsState.boardUndoStack, isNotEmpty);

      state = engine.revertAction(state, rules, 'evolve');
      expect(state.actionUsageCount['evolve'], isNull);
      expect(state.effectsState.boardUndoStack, isEmpty);
      expect(
        state.effectsState.board.targetById('slot_0')!.enteredThisTurn,
        isFalse,
      );
    });
  });
}
