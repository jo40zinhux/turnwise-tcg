import 'game_summary.dart';

abstract class GameCatalogRepository {
  Future<List<GameSummary>> getGames();
}
