import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../games/presentation/providers/game_catalog_providers.dart';
import '../../../match/presentation/providers/match_session_providers.dart';
import '../../../match_history/presentation/providers/match_history_providers.dart';
import '../../domain/recent_game_summary.dart';

const _recentGamesLimit = 4;

final recentGamesProvider = FutureProvider<List<RecentGameSummary>>((ref) async {
  final records =
      await ref.watch(matchHistoryRepositoryProvider).getRecent(limit: 50);
  if (records.isEmpty) return const [];

  final catalog = await ref.watch(gameCatalogProvider.future);
  final namesById = {for (final game in catalog) game.id: game.name};

  final lastPlayedByGame = <String, DateTime>{};
  final countsByGame = <String, int>{};

  for (final record in records) {
    countsByGame.update(record.gameId, (value) => value + 1, ifAbsent: () => 1);

    final previous = lastPlayedByGame[record.gameId];
    if (previous == null || record.endedAt.isAfter(previous)) {
      lastPlayedByGame[record.gameId] = record.endedAt;
    }
  }

  final sortedGameIds = lastPlayedByGame.keys.toList()
    ..sort(
      (a, b) => lastPlayedByGame[b]!.compareTo(lastPlayedByGame[a]!),
    );

  return sortedGameIds.take(_recentGamesLimit).map((gameId) {
    return RecentGameSummary(
      gameId: gameId,
      gameName: namesById[gameId] ?? gameId,
      lastPlayedAt: lastPlayedByGame[gameId]!,
      recentMatchCount: countsByGame[gameId] ?? 0,
    );
  }).toList();
});

/// Resolves display name for the active session's game.
///
/// Falls back to [MatchSession.gameId] while the catalog is still loading so
/// the resume banner does not flicker off/on.
final resumeGameNameProvider = Provider<String?>((ref) {
  final session = ref.watch(activeMatchSessionProvider);
  if (session == null) return null;

  final catalog = ref.watch(gameCatalogProvider).valueOrNull;
  if (catalog == null) return session.gameId;

  return catalog
          .where((game) => game.id == session.gameId)
          .map((game) => game.name)
          .firstOrNull ??
      session.gameId;
});
