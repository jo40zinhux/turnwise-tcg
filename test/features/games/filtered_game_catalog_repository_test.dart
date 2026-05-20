import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/data/rules_asset_checker.dart';
import 'package:turnwise_tcg/features/games/data/filtered_game_catalog_repository.dart';
import 'package:turnwise_tcg/features/games/domain/game_catalog_repository.dart';
import 'package:turnwise_tcg/features/games/domain/game_summary.dart';

class _FakeCatalogRepository implements GameCatalogRepository {
  final List<GameSummary> games;

  _FakeCatalogRepository(this.games);

  @override
  Future<List<GameSummary>> getGames() async => games;
}

class _FakeRulesAssetChecker extends RulesAssetChecker {
  final Set<String> availableIds;

  _FakeRulesAssetChecker(this.availableIds);

  @override
  Future<bool> hasRulesAsset(String gameId) async => availableIds.contains(gameId);
}

void main() {
  group('FilteredGameCatalogRepository', () {
    test('returns only games with bundled rules assets', () async {
      final catalog = FilteredGameCatalogRepository(
        catalog: _FakeCatalogRepository([
          const GameSummary(
            id: 'pokemon',
            name: 'Pokémon',
            iconCode: 'catching_pokemon',
            accent: '#FFCB05',
          ),
          const GameSummary(
            id: 'missing_rules',
            name: 'Missing',
            iconCode: 'help',
            accent: '#FFFFFF',
          ),
        ]),
        rulesAssetChecker: _FakeRulesAssetChecker({'pokemon'}),
      );

      final games = await catalog.getGames();

      expect(games, hasLength(1));
      expect(games.first.id, 'pokemon');
    });
  });
}
