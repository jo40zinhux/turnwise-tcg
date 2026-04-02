// lib/features/match/domain/rules_repository.dart

import 'game_rules.dart';

abstract class RulesRepository {
  Future<GameRules> getGameRules(String gameId);
}
