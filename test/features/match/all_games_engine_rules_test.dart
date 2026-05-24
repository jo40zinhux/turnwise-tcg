import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine.dart';
import 'package:turnwise_tcg/features/match/domain/match_feedback.dart';
import 'package:turnwise_tcg/features/match/domain/match_resources_state.dart';
import 'package:turnwise_tcg/features/match/domain/phase_reminder_evaluator.dart';

import 'support/rules_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MatchEngine engine;

  setUp(() {
    engine = RulesTestHarness.createEngine();
  });

  group('Pokemon', () {
    late GameRules rules;

    setUpAll(() async {
      rules = await RulesTestHarness.loadRules('pokemon');
    });

    test('first player cannot use supporter on turn 1', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'pokemon',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'actions'),
        wentFirst: true,
      );
      final next = engine.attemptAction(state, rules, 'supporter');
      expect(next.feedback?.type, MatchFeedbackType.error);
    });

    test('both players cannot evolve on turn 1', () {
      for (final wentFirst in [true, false]) {
        final state = RulesTestHarness.stateWith(
          gameId: 'pokemon',
          phaseIndex: RulesTestHarness.phaseIndex(rules, 'actions'),
          wentFirst: wentFirst,
        );
        final next = engine.attemptAction(state, rules, 'evolve');
        expect(next.feedback?.type, MatchFeedbackType.error);
      }
    });

    test('evolve on turn 2 registers with manual reminder', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'pokemon',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'actions'),
        turn: 2,
        wentFirst: false,
      );
      final next = engine.attemptAction(state, rules, 'evolve');
      expect(next.feedback?.type, MatchFeedbackType.info);
      expect(next.feedback?.message, contains('Lembrete'));
      expect(next.actionUsageCount['evolve'], 1);
    });

    test('first player cannot attack on turn 1', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'pokemon',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'attack'),
        wentFirst: true,
      );
      final next = engine.attemptAction(state, rules, 'attack');
      expect(next.feedback?.type, MatchFeedbackType.error);
    });
  });

  group('One Piece', () {
    late GameRules rules;

    setUpAll(() async {
      rules = await RulesTestHarness.loadRules('one_piece');
    });

    test('add_don limited to 2 per turn', () {
      var state = RulesTestHarness.stateWith(
        gameId: 'one_piece',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'don'),
      );

      state = engine.attemptAction(state, rules, 'add_don');
      expect(state.feedback?.type, MatchFeedbackType.success);
      expect(state.effectsState.resources.don, 1);

      state = engine.attemptAction(state, rules, 'add_don');
      expect(state.feedback?.type, MatchFeedbackType.success);
      expect(state.effectsState.resources.don, 2);

      state = engine.attemptAction(state, rules, 'add_don');
      expect(state.feedback?.type, MatchFeedbackType.error);
      expect(state.effectsState.resources.don, 2);
    });

    test('play_character blocked without DON!!', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'one_piece',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'main'),
      );
      final next = engine.attemptAction(state, rules, 'play_character');
      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.feedback?.message, contains('DON'));
    });

    test('play_character spends DON!! when available', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'one_piece',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'main'),
        resources: const MatchResourcesState(don: 2),
      );
      final next = engine.attemptAction(state, rules, 'play_character');
      expect(next.feedback?.type, MatchFeedbackType.success);
      expect(next.effectsState.resources.don, 1);
    });

    test('attack registers with rested manual reminder', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'one_piece',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'battle'),
        turn: 2,
      );
      final next = engine.attemptAction(state, rules, 'attack');
      expect(next.feedback?.type, MatchFeedbackType.info);
      expect(next.feedback?.message, contains('descansados'));
    });

    test('first player skip draw reminder on draw phase', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'one_piece',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'draw'),
        wentFirst: true,
      );
      final reminder = PhaseReminderEvaluator.onPhaseEntered(
        rules: rules,
        phaseId: 'draw',
        state: state,
      );
      expect(reminder?.id, 'first_player_skip_draw');
    });
  });

  group('Yu-Gi-Oh!', () {
    late GameRules rules;

    setUpAll(() async {
      rules = await RulesTestHarness.loadRules('yugioh');
    });

    test('no attack on first turn of duel', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'yugioh',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'battle'),
      );
      final next = engine.attemptAction(state, rules, 'declare_attack');
      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.feedback?.message, contains('primeiro turno'));
    });

    test('attack on turn 2 registers with position reminder', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'yugioh',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'battle'),
        turn: 2,
      );
      final next = engine.attemptAction(state, rules, 'declare_attack');
      expect(next.feedback?.type, MatchFeedbackType.info);
      expect(next.feedback?.message, contains('posição'));
    });

    test('normal summon limited to once per turn', () {
      var state = RulesTestHarness.stateWith(
        gameId: 'yugioh',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'main1'),
      );
      state = engine.attemptAction(state, rules, 'normal_summon');
      expect(state.feedback?.type, MatchFeedbackType.success);

      state = engine.attemptAction(state, rules, 'normal_summon');
      expect(state.feedback?.type, MatchFeedbackType.error);
    });
  });

  group('Lorcana', () {
    late GameRules rules;

    setUpAll(() async {
      rules = await RulesTestHarness.loadRules('lorcana');
    });

    test('cannot challenge on first turn', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'lorcana',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'main'),
      );
      final next = engine.attemptAction(state, rules, 'challenge');
      expect(next.feedback?.type, MatchFeedbackType.error);
    });

    test('challenge on turn 2 registers with exerted reminder', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'lorcana',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'main'),
        turn: 2,
      );
      final next = engine.attemptAction(state, rules, 'challenge');
      expect(next.feedback?.type, MatchFeedbackType.info);
      expect(next.feedback?.message, contains('exauridos'));
    });

    test('ink limited to once per turn', () {
      var state = RulesTestHarness.stateWith(
        gameId: 'lorcana',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'main'),
      );
      state = engine.attemptAction(state, rules, 'ink');
      expect(state.feedback?.type, MatchFeedbackType.success);

      state = engine.attemptAction(state, rules, 'ink');
      expect(state.feedback?.type, MatchFeedbackType.error);
    });
  });

  group('Magic', () {
    late GameRules rules;

    setUpAll(() async {
      rules = await RulesTestHarness.loadRules('magic');
    });

    test('land limited to one per turn', () {
      var state = RulesTestHarness.stateWith(
        gameId: 'magic',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'main1'),
      );
      state = engine.attemptAction(state, rules, 'play_land');
      expect(state.feedback?.type, MatchFeedbackType.success);

      state = engine.attemptAction(state, rules, 'play_land');
      expect(state.feedback?.type, MatchFeedbackType.error);
    });

    test('declare attacker registers with summoning sickness reminder', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'magic',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'combat'),
        turn: 2,
      );
      final next = engine.attemptAction(state, rules, 'declare_attacker');
      expect(next.feedback?.type, MatchFeedbackType.info);
      expect(next.feedback?.message, contains('enjoo'));
    });
  });

  group('Flesh and Blood', () {
    late GameRules rules;

    setUpAll(() async {
      rules = await RulesTestHarness.loadRules('flesh_and_blood');
    });

    test('play_action blocked without action point', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'flesh_and_blood',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'action'),
        resources: const MatchResourcesState(actionPoints: 0),
      );
      final next = engine.attemptAction(state, rules, 'play_action');
      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.feedback?.message, contains('Action Point'));
    });

    test('play_action spends action point when available', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'flesh_and_blood',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'action'),
        resources: const MatchResourcesState(actionPoints: 1),
      );
      final next = engine.attemptAction(state, rules, 'play_action');
      expect(next.feedback?.type, MatchFeedbackType.success);
      expect(next.effectsState.resources.actionPoints, 0);
    });

    test('attack blocked without action point', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'flesh_and_blood',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'action'),
        resources: const MatchResourcesState(actionPoints: 0),
      );
      final next = engine.attemptAction(state, rules, 'attack');
      expect(next.feedback?.type, MatchFeedbackType.error);
    });
  });

  group('Riftbound', () {
    late GameRules rules;

    setUpAll(() async {
      rules = await RulesTestHarness.loadRules('riftbound');
    });

    test('channel runes once per turn and grants energy', () {
      var state = RulesTestHarness.stateWith(
        gameId: 'riftbound',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'beginning'),
      );
      state = engine.attemptAction(state, rules, 'channel_runes');
      expect(state.feedback?.type, MatchFeedbackType.success);
      expect(state.effectsState.resources.energy, 1);

      state = engine.attemptAction(state, rules, 'channel_runes');
      expect(state.feedback?.type, MatchFeedbackType.error);
    });

    test('draw limited to once in beginning phase', () {
      var state = RulesTestHarness.stateWith(
        gameId: 'riftbound',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'beginning'),
      );
      state = engine.attemptAction(state, rules, 'draw_card');
      expect(state.feedback?.type, MatchFeedbackType.success);

      state = engine.attemptAction(state, rules, 'draw_card');
      expect(state.feedback?.type, MatchFeedbackType.error);
    });

    test('play_unit blocked without energy', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'riftbound',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'action'),
      );
      final next = engine.attemptAction(state, rules, 'play_unit');
      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.feedback?.message, contains('energia'));
    });

    test('move_unit registers with ready-state reminder', () {
      final state = RulesTestHarness.stateWith(
        gameId: 'riftbound',
        phaseIndex: RulesTestHarness.phaseIndex(rules, 'action'),
        turn: 2,
        resources: const MatchResourcesState(energy: 2),
      );
      final next = engine.attemptAction(state, rules, 'move_unit');
      expect(next.feedback?.type, MatchFeedbackType.info);
      expect(next.feedback?.message, contains('pronta'));
    });
  });
}
