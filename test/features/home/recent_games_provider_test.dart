import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/home/domain/recent_game_summary.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_record.dart';

/// Mirrors grouping logic from [recentGamesProvider].
List<RecentGameSummary> buildRecentGames({
  required List<MatchRecord> records,
  required Map<String, String> namesById,
  int limit = 4,
}) {
  if (records.isEmpty) return const [];

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
    ..sort((a, b) => lastPlayedByGame[b]!.compareTo(lastPlayedByGame[a]!));

  return sortedGameIds.take(limit).map((gameId) {
    return RecentGameSummary(
      gameId: gameId,
      gameName: namesById[gameId] ?? gameId,
      lastPlayedAt: lastPlayedByGame[gameId]!,
      recentMatchCount: countsByGame[gameId] ?? 0,
    );
  }).toList();
}

void main() {
  test('returns recent games ordered by last played date', () {
    final recent = buildRecentGames(
      records: [
        _record('1', 'pokemon', DateTime.parse('2026-05-10T12:00:00.000')),
        _record('2', 'magic', DateTime.parse('2026-05-19T12:00:00.000')),
        _record('3', 'pokemon', DateTime.parse('2026-05-18T12:00:00.000')),
      ],
      namesById: const {'pokemon': 'Pokémon', 'magic': 'Magic'},
    );

    expect(recent.first.gameId, 'magic');
    expect(recent[1].gameId, 'pokemon');
    expect(recent[1].recentMatchCount, 2);
  });
}

MatchRecord _record(String id, String gameId, DateTime endedAt) {
  return MatchRecord(
    id: id,
    gameId: gameId,
    startedAt: endedAt.subtract(const Duration(minutes: 20)),
    endedAt: endedAt,
    outcome: MatchOutcome.draw,
    updatedAt: endedAt,
  );
}
