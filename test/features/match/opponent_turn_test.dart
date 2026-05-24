import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/match_effects_state.dart';

import 'support/rules_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Opponent turn', () {
    late final engine = RulesTestHarness.createEngine();

    test('nextPhase after last phase sets isOpponentTurn', () async {
      final rules = await RulesTestHarness.loadRules('pokemon');
      final lastPhase = rules.phases.length - 1;
      var state = RulesTestHarness.stateWith(
        gameId: 'pokemon',
        phaseIndex: lastPhase,
      );

      state = engine.nextPhase(state, rules);
      expect(state.effectsState.isOpponentTurn, isTrue);
      expect(state.currentPhaseIndex, 0);
    });

    test('completeOpponentTurn clears flag and item_lock effect', () async {
      final rules = await RulesTestHarness.loadRules('pokemon');
      var state = RulesTestHarness.stateWith(gameId: 'pokemon').copyWith(
        effectsState: const MatchEffectsState(isOpponentTurn: true),
      );

      state = engine.effects.applyEffect(state, rules, 'item_lock');
      expect(state.effectsState.activeEffects, hasLength(1));
      expect(
        state.effectsState.activeEffects.single.expiresOnOpponentTurnEnd,
        isTrue,
      );

      state = engine.completeOpponentTurn(state);
      expect(state.effectsState.isOpponentTurn, isFalse);
      expect(state.effectsState.activeEffects, isEmpty);
    });

    test('nextPhase blocked during opponent turn', () async {
      final rules = await RulesTestHarness.loadRules('pokemon');
      var state = RulesTestHarness.stateWith(gameId: 'pokemon').copyWith(
        effectsState: const MatchEffectsState(isOpponentTurn: true),
      );

      final beforeIndex = state.currentPhaseIndex;
      state = engine.nextPhase(state, rules);

      expect(state.currentPhaseIndex, beforeIndex);
      expect(state.feedback?.reason, 'opponent_turn');
      expect(state.effectsState.isOpponentTurn, isTrue);
    });

    test('attemptAction blocked during opponent turn', () async {
      final rules = await RulesTestHarness.loadRules('pokemon');
      final state = RulesTestHarness.stateWith(gameId: 'pokemon').copyWith(
        effectsState: const MatchEffectsState(isOpponentTurn: true),
      );

      final next = engine.attemptAction(state, rules, 'draw');
      expect(next.feedback?.type.name, 'error');
      expect(next.feedback?.message, contains('oponente'));
    });
  });
}
