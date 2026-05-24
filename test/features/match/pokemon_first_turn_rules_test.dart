import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/data/bundled_effects_datasource.dart';
import 'package:turnwise_tcg/features/match/data/bundled_rules_datasource.dart';
import 'package:turnwise_tcg/features/match/data/cached_rules_repository.dart';
import 'package:turnwise_tcg/features/match/data/file_rules_cache_datasource.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/domain/match_effects_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_feedback.dart';

class _InMemoryRulesCache extends FileRulesCacheDataSource {
  @override
  Future<String?> read(String gameId) async => null;

  @override
  Future<void> write(String gameId, String rawJson) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MatchEngine engine;
  late GameRules rules;

  setUpAll(() async {
    engine = MatchEngine();
    final repository = CachedRulesRepository(
      bundled: BundledRulesDataSource(),
      effects: BundledEffectsDataSource(),
      cache: _InMemoryRulesCache(),
    );
    rules = await repository.getGameRules('pokemon');
  });

  MatchEngineState stateWith({
    int phase = 1,
    int turn = 1,
    bool? wentFirst,
  }) {
    return MatchEngineState(
      currentPhaseIndex: phase,
      effectsState: MatchEffectsState(
        turnNumber: turn,
        playerWentFirst: wentFirst,
      ),
    );
  }

  group('Pokemon first turn rules', () {
    test('first player cannot use supporter on turn 1', () {
      final state = stateWith(wentFirst: true);
      final next = engine.attemptAction(state, rules, 'supporter');
      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.feedback?.message, contains('Apoiador'));
    });

    test('second player can use supporter on turn 1', () {
      final state = stateWith(wentFirst: false);
      final next = engine.attemptAction(state, rules, 'supporter');
      expect(next.feedback?.type, MatchFeedbackType.success);
    });

    test('both players cannot evolve on turn 1', () {
      for (final wentFirst in [true, false]) {
        final state = stateWith(wentFirst: wentFirst);
        final next = engine.attemptAction(state, rules, 'evolve');
        expect(next.feedback?.type, MatchFeedbackType.error);
        expect(next.feedback?.message, contains('primeiro turno'));
      }
    });

    test('second player can evolve on turn 2 with manual reminder', () {
      final state = stateWith(turn: 2, wentFirst: false);
      final next = engine.attemptAction(state, rules, 'evolve');
      expect(next.feedback?.type, MatchFeedbackType.info);
      expect(next.feedback?.message, contains('Lembrete'));
      expect(next.actionUsageCount['evolve'], 1);
    });

    test('first player cannot attack on turn 1', () {
      final state = stateWith(phase: 2, wentFirst: true);
      final next = engine.attemptAction(state, rules, 'attack');
      expect(next.feedback?.type, MatchFeedbackType.error);
      expect(next.feedback?.message, contains('atacar'));
    });

    test('second player can attack on turn 1', () {
      final state = stateWith(phase: 2, wentFirst: false);
      final next = engine.attemptAction(state, rules, 'attack');
      expect(next.feedback?.type, MatchFeedbackType.success);
    });
  });
}
