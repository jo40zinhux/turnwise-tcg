import 'package:flutter/foundation.dart';

import '../../../core/data/rules_asset_checker.dart';
import '../domain/game_catalog_repository.dart';
import '../domain/game_summary.dart';
import 'asset_game_catalog_repository.dart';

/// Returns only games that have a bundled rules JSON asset.
class FilteredGameCatalogRepository implements GameCatalogRepository {
  final GameCatalogRepository _catalog;
  final RulesAssetChecker _rulesAssetChecker;

  FilteredGameCatalogRepository({
    GameCatalogRepository? catalog,
    RulesAssetChecker? rulesAssetChecker,
  })  : _catalog = catalog ?? AssetGameCatalogRepository(),
        _rulesAssetChecker = rulesAssetChecker ?? RulesAssetChecker();

  @override
  Future<List<GameSummary>> getGames() async {
    final games = await _catalog.getGames();
    final available = <GameSummary>[];

    for (final game in games) {
      if (await _rulesAssetChecker.hasRulesAsset(game.id)) {
        available.add(game);
      } else {
        debugPrint('Skipping game without rules asset: ${game.id}');
      }
    }

    return available;
  }
}
