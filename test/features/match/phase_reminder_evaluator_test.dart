import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/data/bundled_rules_datasource.dart';
import 'package:turnwise_tcg/features/match/data/cached_rules_repository.dart';
import 'package:turnwise_tcg/features/match/data/file_rules_cache_datasource.dart';
import 'package:turnwise_tcg/features/match/domain/match_effects_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';
import 'package:turnwise_tcg/features/match/domain/phase_reminder_evaluator.dart';
import 'package:turnwise_tcg/features/match/data/bundled_effects_datasource.dart';

class _InMemoryRulesCache extends FileRulesCacheDataSource {
  @override
  Future<String?> read(String gameId) async => null;

  @override
  Future<void> write(String gameId, String rawJson) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CachedRulesRepository repository;

  setUp(() {
    repository = CachedRulesRepository(
      bundled: BundledRulesDataSource(),
      effects: BundledEffectsDataSource(),
      cache: _InMemoryRulesCache(),
    );
  });

  test('one piece first player skip draw reminder on draw phase', () async {
    final rules = await repository.getGameRules('one_piece');
    const state = MatchEngineState(
      currentPhaseIndex: 1,
      effectsState: MatchEffectsState(
        turnNumber: 1,
        playerWentFirst: true,
      ),
    );

    final reminder = PhaseReminderEvaluator.onPhaseEntered(
      rules: rules,
      phaseId: 'draw',
      state: state,
    );

    expect(reminder, isNotNull);
    expect(reminder!.id, 'first_player_skip_draw');
  });
}
