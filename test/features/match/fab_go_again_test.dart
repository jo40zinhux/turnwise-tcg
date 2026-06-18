import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/match_resources_state.dart';

import 'support/rules_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('go_again effect grants one action point', () async {
    final engine = RulesTestHarness.createEngine();
    final rules = await RulesTestHarness.loadRules('flesh_and_blood');
    var state = RulesTestHarness.stateWith(
      gameId: 'flesh_and_blood',
      resources: const MatchResourcesState(actionPoints: 0),
    );

    state = engine.applyEffect(state, rules, 'go_again');

    expect(state.effectsState.resources.actionPoints, 1);
  });
}
