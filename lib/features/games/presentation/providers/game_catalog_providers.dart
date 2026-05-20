import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/filtered_game_catalog_repository.dart';
import '../../domain/game_catalog_repository.dart';
import '../../domain/game_summary.dart';

final gameCatalogRepositoryProvider = Provider<GameCatalogRepository>((ref) {
  return FilteredGameCatalogRepository();
});

final gameCatalogProvider = FutureProvider<List<GameSummary>>((ref) async {
  final repository = ref.watch(gameCatalogRepositoryProvider);
  return repository.getGames();
});
