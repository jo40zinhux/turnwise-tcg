import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/data/bundled_effects_datasource.dart';
import 'package:turnwise_tcg/features/match/data/bundled_rules_datasource.dart';
import 'package:turnwise_tcg/features/match/data/cached_rules_repository.dart';
import 'package:turnwise_tcg/features/match/data/file_rules_cache_datasource.dart';
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
  late CachedRulesRepository repository;

  setUp(() {
    engine = MatchEngine();
    repository = CachedRulesRepository(
      bundled: BundledRulesDataSource(),
      effects: BundledEffectsDataSource(),
      cache: _InMemoryRulesCache(),
    );
  });

  test('evolve on turn 2 returns info feedback with reminder text', () async {
    final rules = await repository.getGameRules('pokemon');
    final state = MatchEngineState(
      currentPhaseIndex: 1,
      effectsState: MatchEffectsState(
        turnNumber: 2,
        playerWentFirst: false,
      ),
    );

    final next = engine.attemptAction(state, rules, 'evolve');

    expect(next.feedback?.type, MatchFeedbackType.info);
    expect(next.feedback?.message, contains('Lembrete'));
    expect(next.actionUsageCount['evolve'], 1);
  });
}
