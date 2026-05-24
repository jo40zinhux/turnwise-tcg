import 'package:turnwise_tcg/features/match/data/bundled_effects_datasource.dart';
import 'package:turnwise_tcg/features/match/data/bundled_rules_datasource.dart';
import 'package:turnwise_tcg/features/match/data/cached_rules_repository.dart';
import 'package:turnwise_tcg/features/match/data/file_rules_cache_datasource.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/domain/match_effects_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_resources_state.dart';

/// All bundled TCG rule sets under `assets/rules/`.
const kAllGameIds = [
  'pokemon',
  'one_piece',
  'yugioh',
  'lorcana',
  'magic',
  'flesh_and_blood',
  'riftbound',
];

class _InMemoryRulesCache extends FileRulesCacheDataSource {
  @override
  Future<String?> read(String gameId) async => null;

  @override
  Future<void> write(String gameId, String rawJson) async {}
}

/// Shared fixtures for cross-game rules and engine tests.
abstract final class RulesTestHarness {
  static CachedRulesRepository createRepository() {
    return CachedRulesRepository(
      bundled: BundledRulesDataSource(),
      effects: BundledEffectsDataSource(),
      cache: _InMemoryRulesCache(),
    );
  }

  static MatchEngine createEngine() => MatchEngine();

  static Future<GameRules> loadRules(String gameId) {
    return createRepository().getGameRules(gameId);
  }

  static int phaseIndex(GameRules rules, String phaseId) {
    return rules.phases.indexWhere((p) => p.id == phaseId);
  }

  static MatchEngineState stateWith({
    required String gameId,
    int phaseIndex = 0,
    int turn = 1,
    bool? wentFirst,
    MatchResourcesState? resources,
  }) {
    return MatchEngineState(
      currentPhaseIndex: phaseIndex,
      effectsState: MatchEffectsState(
        turnNumber: turn,
        playerWentFirst: wentFirst,
        resources: resources ?? MatchResourcesState.initialForGame(gameId),
      ),
    );
  }
}
