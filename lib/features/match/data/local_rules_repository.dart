// lib/features/match/data/local_rules_repository.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/game_rules.dart';
import '../domain/rules_repository.dart';

class LocalRulesRepository implements RulesRepository {
  @override
  Future<GameRules> getGameRules(String gameId) async {
    try {
      final jsonString = await rootBundle.loadString('assets/rules/$gameId.json');
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return GameRules.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load rules for game: $gameId. Error: $e');
    }
  }
}
