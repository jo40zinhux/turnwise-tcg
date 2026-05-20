import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/action_rule.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_feedback.dart';
import 'package:turnwise_tcg/features/match/domain/turn_phase.dart';
import 'package:turnwise_tcg/features/match/domain/validation_rule.dart';

void main() {
  final engine = MatchEngine();

  final rules = GameRules(
    gameId: 'test',
    name: 'Test',
    phases: const [
      TurnPhase(
        id: 'draw',
        title: 'Draw',
        description: 'Draw a card',
        iconCode: 'copy_outlined',
      ),
      TurnPhase(
        id: 'main',
        title: 'Main',
        description: 'Main phase',
        iconCode: 'back_hand_rounded',
      ),
    ],
    actions: [
      const ActionRule(
        id: 'play',
        name: 'Play Card',
        allowedPhases: ['main'],
        validations: ['play_limit'],
      ),
    ],
    validations: [
      const ValidationRule(
        id: 'play_limit',
        type: 'limit',
        params: {'max': 1},
        errorMessage: 'Cannot play {actionName} again',
      ),
    ],
    statusEffects: const [],
  );

  group('MatchEngine', () {
    test('advances to next phase', () {
      const state = MatchEngineState(currentPhaseIndex: 0);
      final next = engine.nextPhase(state, rules);
      expect(next.currentPhaseIndex, 1);
      expect(next.feedback, isNull);
    });

    test('loops turn and resets action usage', () {
      const state = MatchEngineState(
        currentPhaseIndex: 1,
        actionUsageCount: {'play': 1},
      );
      final next = engine.nextPhase(state, rules);
      expect(next.currentPhaseIndex, 0);
      expect(next.actionUsageCount, isEmpty);
      expect(next.feedback?.type, MatchFeedbackType.info);
    });

    test('blocks action in wrong phase', () {
      const state = MatchEngineState(currentPhaseIndex: 0);
      final next = engine.attemptAction(state, rules, 'play');
      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.actionUsageCount, isEmpty);
    });

    test('registers successful action usage', () {
      const state = MatchEngineState(currentPhaseIndex: 1);
      final next = engine.attemptAction(state, rules, 'play');
      expect(next.actionUsageCount['play'], 1);
      expect(next.feedback?.type, MatchFeedbackType.success);
    });

    test('blocks action when limit reached', () {
      const state = MatchEngineState(
        currentPhaseIndex: 1,
        actionUsageCount: {'play': 1},
      );
      final next = engine.attemptAction(state, rules, 'play');
      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.actionUsageCount['play'], 1);
    });
  });
}
