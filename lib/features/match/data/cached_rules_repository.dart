import 'dart:convert';

import '../domain/game_rules.dart';
import '../domain/game_rules_merger.dart';
import '../domain/rules_repository.dart';
import 'bundled_effects_datasource.dart';
import 'bundled_rules_datasource.dart';
import 'file_rules_cache_datasource.dart';

class CachedRulesRepository implements RulesRepository {
  final BundledRulesDataSource _bundled;
  final BundledEffectsDataSource _effects;
  final FileRulesCacheDataSource _cache;

  CachedRulesRepository({
    required BundledRulesDataSource bundled,
    BundledEffectsDataSource? effects,
    required FileRulesCacheDataSource cache,
  })  : _bundled = bundled,
        _effects = effects ?? BundledEffectsDataSource(),
        _cache = cache;

  @override
  Future<GameRules> getGameRules(String gameId) async {
    try {
      final rawJson = await _bundled.loadRawJson(gameId);
      await _cache.write(gameId, rawJson);
      return await _parseRules(rawJson, gameId);
    } catch (_) {
      final cachedJson = await _cache.read(gameId);
      if (cachedJson != null) {
        return await _parseRules(cachedJson, gameId);
      }
      throw Exception('Failed to load rules for game: $gameId');
    }
  }

  Future<GameRules> _parseRules(String rawJson, String gameId) async {
    try {
      final jsonMap = json.decode(rawJson) as Map<String, dynamic>;
      final base = GameRules.fromJson(jsonMap);
      final bundle = await _effects.loadEffectsBundle(gameId);
      return GameRulesMerger.merge(base, bundle);
    } catch (e) {
      throw Exception('Failed to parse rules for game: $gameId. Error: $e');
    }
  }
}
