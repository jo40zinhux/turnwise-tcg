import 'dart:convert';

import '../domain/game_rules.dart';
import '../domain/rules_repository.dart';
import 'bundled_rules_datasource.dart';
import 'file_rules_cache_datasource.dart';

class CachedRulesRepository implements RulesRepository {
  final BundledRulesDataSource _bundled;
  final FileRulesCacheDataSource _cache;

  CachedRulesRepository({
    required BundledRulesDataSource bundled,
    required FileRulesCacheDataSource cache,
  })  : _bundled = bundled,
        _cache = cache;

  @override
  Future<GameRules> getGameRules(String gameId) async {
    try {
      final rawJson = await _bundled.loadRawJson(gameId);
      await _cache.write(gameId, rawJson);
      return _parseRules(rawJson, gameId);
    } catch (_) {
      final cachedJson = await _cache.read(gameId);
      if (cachedJson != null) {
        return _parseRules(cachedJson, gameId);
      }
      throw Exception('Failed to load rules for game: $gameId');
    }
  }

  GameRules _parseRules(String rawJson, String gameId) {
    try {
      final jsonMap = json.decode(rawJson) as Map<String, dynamic>;
      return GameRules.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to parse rules for game: $gameId. Error: $e');
    }
  }
}
