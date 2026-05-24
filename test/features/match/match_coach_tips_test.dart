import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/data/bundled_effects_datasource.dart';
import 'package:turnwise_tcg/features/match/data/bundled_rules_datasource.dart';
import 'package:turnwise_tcg/features/match/data/cached_rules_repository.dart';
import 'package:turnwise_tcg/features/match/data/file_rules_cache_datasource.dart';
import 'package:turnwise_tcg/features/match/domain/match_coach_tips.dart';
import 'package:turnwise_tcg/features/match/domain/match_effects_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';

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

  test('magic gets summoning sickness tip on turn 1', () async {
    final rules = await repository.getGameRules('magic');
    const state = MatchEngineState(
      currentPhaseIndex: 0,
      effectsState: MatchEffectsState(turnNumber: 1, playerWentFirst: true),
    );

    final tip = MatchCoachTips.activeTip(
      rules: rules,
      state: state,
      dismissedTipIds: const {},
    );

    expect(tip?.id, 'magic_summoning_sickness');
  });

  test('fallback tip when went first set but no game-specific match', () async {
    final rules = await repository.getGameRules('magic');
    const state = MatchEngineState(
      currentPhaseIndex: 0,
      effectsState: MatchEffectsState(turnNumber: 1, playerWentFirst: false),
    );

    final tip = MatchCoachTips.activeTip(
      rules: rules,
      state: state,
      dismissedTipIds: {'magic_summoning_sickness'},
    );

    expect(tip?.id, 'magic_turn_order_second');
  });
}
