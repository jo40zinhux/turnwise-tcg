import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/data/bundled_effects_datasource.dart';
import 'package:turnwise_tcg/features/match/data/bundled_rules_datasource.dart';
import 'package:turnwise_tcg/features/match/data/cached_rules_repository.dart';
import 'package:turnwise_tcg/features/match/data/file_rules_cache_datasource.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine.dart';
import 'package:turnwise_tcg/features/match/domain/match_engine_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_feedback.dart';

class _InMemoryRulesCache extends FileRulesCacheDataSource {
  final Map<String, String> store = {};

  @override
  Future<String?> read(String gameId) async => store[gameId];

  @override
  Future<void> write(String gameId, String rawJson) async {
    store[gameId] = rawJson;
  }
}

Future<GameRules> _loadRules(String gameId) {
  final repository = CachedRulesRepository(
    bundled: BundledRulesDataSource(),
    effects: BundledEffectsDataSource(),
    cache: _InMemoryRulesCache(),
  );
  return repository.getGameRules(gameId);
}

int _phaseIndex(GameRules rules, String phaseId) {
  return rules.phases.indexWhere((p) => p.id == phaseId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final matchEngine = MatchEngine();

  group('per-game effects merged into rules', () {
    const cases = <String, String>{
      'pokemon': 'item_lock',
      'magic': 'spell_lock',
      'yugioh': 'special_summon_lock',
      'lorcana': 'exerted',
      'one_piece': 'rested',
      'flesh_and_blood': 'frailty',
      'riftbound': 'stun',
    };

    for (final entry in cases.entries) {
      test('${entry.key} exposes ${entry.value} from effects library', () async {
        final rules = await _loadRules(entry.key);
        expect(rules.effects.any((e) => e.id == entry.value), isTrue);
      });
    }
  });

  group('MatchEngine blocks actions from library effects', () {
    test('pokemon item_lock blocks item in actions phase', () async {
      final rules = await _loadRules('pokemon');
      var state = MatchEngineState(
        currentPhaseIndex: _phaseIndex(rules, 'actions'),
      );
      state = matchEngine.applyEffect(state, rules, 'item_lock');

      final next = matchEngine.attemptAction(state, rules, 'item');
      expect(next.feedback?.type, MatchFeedbackType.error);
    });

    test('magic spell_lock blocks cast_spell', () async {
      final rules = await _loadRules('magic');
      var state = MatchEngineState(
        currentPhaseIndex: _phaseIndex(rules, 'main1'),
      );
      state = matchEngine.applyEffect(state, rules, 'spell_lock');

      final next = matchEngine.attemptAction(state, rules, 'cast_spell');
      expect(next.feedback?.type, MatchFeedbackType.error);
    });

    test('yugioh special_summon_lock blocks special_summon', () async {
      final rules = await _loadRules('yugioh');
      var state = MatchEngineState(
        currentPhaseIndex: _phaseIndex(rules, 'main1'),
      );
      state = matchEngine.applyEffect(state, rules, 'special_summon_lock');

      final next = matchEngine.attemptAction(state, rules, 'special_summon');
      expect(next.feedback?.type, MatchFeedbackType.error);
    });

    test('pokemon poison queues between-turn checkup', () async {
      final rules = await _loadRules('pokemon');
      var state = MatchEngineState(
        currentPhaseIndex: _phaseIndex(rules, 'attack'),
      );
      state = matchEngine.applyEffect(state, rules, 'poison');

      final afterTurn = matchEngine.nextPhase(state, rules);
      expect(
        afterTurn.effectsState.pendingCheckups
            .any((c) => c.relatedEffectIds.contains('poison')),
        isTrue,
      );
    });
  });
}
