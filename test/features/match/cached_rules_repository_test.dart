import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/data/bundled_effects_datasource.dart';
import 'package:turnwise_tcg/features/match/data/bundled_rules_datasource.dart';
import 'package:turnwise_tcg/features/match/data/cached_rules_repository.dart';
import 'package:turnwise_tcg/features/match/data/file_rules_cache_datasource.dart';
import 'package:turnwise_tcg/features/match/domain/game_effects_bundle.dart';

class _FakeBundledRulesDataSource extends BundledRulesDataSource {
  _FakeBundledRulesDataSource({this.json, this.throws = false});

  final String? json;
  final bool throws;

  @override
  Future<String> loadRawJson(String gameId) async {
    if (throws) {
      throw Exception('bundle unavailable');
    }
    return json!;
  }
}

class _FakeBundledEffectsDataSource extends BundledEffectsDataSource {
  final GameEffectsBundle? bundle;

  _FakeBundledEffectsDataSource({this.bundle});

  @override
  Future<GameEffectsBundle?> loadEffectsBundle(String gameId) async => bundle;
}

class _FakeFileRulesCacheDataSource extends FileRulesCacheDataSource {
  final Map<String, String> store = {};

  @override
  Future<String?> read(String gameId) async => store[gameId];

  @override
  Future<void> write(String gameId, String rawJson) async {
    store[gameId] = rawJson;
  }
}

void main() {
  const sampleRulesJson = '''
{
  "gameId": "pokemon",
  "name": "Pokemon TCG",
  "phases": [],
  "actions": [],
  "validations": [],
  "statusEffects": []
}
''';

  group('CachedRulesRepository', () {
    test('loads from bundle and writes cache', () async {
      final cache = _FakeFileRulesCacheDataSource();
      final repository = CachedRulesRepository(
        bundled: _FakeBundledRulesDataSource(json: sampleRulesJson),
        effects: _FakeBundledEffectsDataSource(),
        cache: cache,
      );

      final rules = await repository.getGameRules('pokemon');

      expect(rules.gameId, 'pokemon');
      expect(cache.store['pokemon'], sampleRulesJson);
    });

    test('falls back to cache when bundle is unavailable', () async {
      final cache = _FakeFileRulesCacheDataSource()
        ..store['pokemon'] = sampleRulesJson;
      final repository = CachedRulesRepository(
        bundled: _FakeBundledRulesDataSource(throws: true),
        effects: _FakeBundledEffectsDataSource(),
        cache: cache,
      );

      final rules = await repository.getGameRules('pokemon');

      expect(rules.gameId, 'pokemon');
    });

    test('throws when bundle and cache are unavailable', () async {
      final repository = CachedRulesRepository(
        bundled: _FakeBundledRulesDataSource(throws: true),
        effects: _FakeBundledEffectsDataSource(),
        cache: _FakeFileRulesCacheDataSource(),
      );

      expect(
        () => repository.getGameRules('pokemon'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
