import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/action_rule.dart';
import 'package:turnwise_tcg/features/match/domain/match_effects_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_resources_state.dart';
import 'package:turnwise_tcg/features/match/domain/validation_evaluator.dart';
import 'package:turnwise_tcg/features/match/domain/validation_rule.dart';

void main() {
  const action = ActionRule(
    id: 'play_character',
    name: 'Jogar Character',
    allowedPhases: ['main'],
    validations: ['don_cost_check'],
  );

  const validation = ValidationRule(
    id: 'don_cost_check',
    type: 'resource',
    params: {'cost': 2},
    errorMessage: 'Sem DON!!',
  );

  group('ValidationEvaluator resource', () {
    test('blocks when don pool is below cost', () {
      const state = MatchEngineState(
        currentPhaseIndex: 0,
        effectsState: MatchEffectsState(
          resources: MatchResourcesState(don: 1),
        ),
      );

      final message = ValidationEvaluator.blockMessage(
        validation: validation,
        action: action,
        state: state,
      );

      expect(message, isNotNull);
    });

    test('allows when don pool meets cost', () {
      const state = MatchEngineState(
        currentPhaseIndex: 0,
        effectsState: MatchEffectsState(
          resources: MatchResourcesState(don: 2),
        ),
      );

      final message = ValidationEvaluator.blockMessage(
        validation: validation,
        action: action,
        state: state,
      );

      expect(message, isNull);
    });
  });
}
