import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/data/bundled_effects_datasource.dart';
import 'package:turnwise_tcg/features/match/data/bundled_rules_datasource.dart';
import 'package:turnwise_tcg/features/match/data/cached_rules_repository.dart';
import 'package:turnwise_tcg/features/match/data/file_rules_cache_datasource.dart';

class _InMemoryRulesCache extends FileRulesCacheDataSource {
  final Map<String, String> store = {};

  @override
  Future<String?> read(String gameId) async => store[gameId];

  @override
  Future<void> write(String gameId, String rawJson) async {
    store[gameId] = rawJson;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CachedRulesRepository effects integration', () {
    late CachedRulesRepository repository;

    setUp(() {
      repository = CachedRulesRepository(
        bundled: BundledRulesDataSource(),
        effects: BundledEffectsDataSource(),
        cache: _InMemoryRulesCache(),
      );
    });

    test('pokemon rules include effects from pokemon_effects.json', () async {
      final rules = await repository.getGameRules('pokemon');

      expect(rules.gameId, 'pokemon');
      expect(rules.effects.any((e) => e.id == 'poison'), isTrue);
      expect(rules.effects.any((e) => e.id == 'item_lock'), isTrue);
      expect(rules.checkups.any((c) => c.effectIds.contains('poison')), isTrue);
    });

    test('magic rules include spell_lock from magic_effects.json', () async {
      final rules = await repository.getGameRules('magic');

      expect(rules.effects.any((e) => e.id == 'spell_lock'), isTrue);
      expect(
        rules.effects
            .firstWhere((e) => e.id == 'spell_lock')
            .lockedActionIds,
        contains('cast_spell'),
      );
    });

    test('yugioh rules load summon_lock effects', () async {
      final rules = await repository.getGameRules('yugioh');

      expect(rules.effects.any((e) => e.id == 'special_summon_lock'), isTrue);
    });

    test('lorcana rules load exerted from lorcana_effects.json', () async {
      final rules = await repository.getGameRules('lorcana');
      expect(rules.effects.any((e) => e.id == 'exerted'), isTrue);
    });

    test('one_piece rules load rested from one_piece_effects.json', () async {
      final rules = await repository.getGameRules('one_piece');
      expect(rules.effects.any((e) => e.id == 'rested'), isTrue);
    });

    test('flesh_and_blood rules load frailty from effects library', () async {
      final rules = await repository.getGameRules('flesh_and_blood');
      expect(rules.effects.any((e) => e.id == 'frailty'), isTrue);
    });

    test('riftbound rules load stun from riftbound_effects.json', () async {
      final rules = await repository.getGameRules('riftbound');
      expect(rules.effects.any((e) => e.id == 'stun'), isTrue);
    });
  });
}
