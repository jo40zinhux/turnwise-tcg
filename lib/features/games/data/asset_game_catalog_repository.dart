import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/game_catalog_repository.dart';
import '../domain/game_summary.dart';

class AssetGameCatalogRepository implements GameCatalogRepository {
  static const _manifestPath = 'assets/games_manifest.json';

  @override
  Future<List<GameSummary>> getGames() async {
    try {
      final jsonString = await rootBundle.loadString(_manifestPath);
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final gamesJson = jsonMap['games'] as List<dynamic>? ?? [];

      return gamesJson
          .map((e) => GameSummary.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load game catalog: $e');
    }
  }
}
