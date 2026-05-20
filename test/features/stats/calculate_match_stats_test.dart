import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_record.dart';
import 'package:turnwise_tcg/features/stats/domain/calculate_match_stats.dart';

void main() {
  const calculator = CalculateMatchStats();
  final reference = DateTime.parse('2026-05-19T18:00:00.000');

  MatchRecord record({
    required String id,
    required String gameId,
    required DateTime endedAt,
    required MatchOutcome outcome,
    int durationMinutes = 30,
  }) {
    return MatchRecord(
      id: id,
      gameId: gameId,
      startedAt: endedAt.subtract(Duration(minutes: durationMinutes)),
      endedAt: endedAt,
      outcome: outcome,
      updatedAt: endedAt,
    );
  }

  test('returns empty stats for no records', () {
    final stats = calculator([], referenceTime: reference);
    expect(stats.isEmpty, isTrue);
  });

  test('calculates winrate from wins and losses only', () {
    final stats = calculator(
      [
        record(
          id: '1',
          gameId: 'pokemon',
          endedAt: reference,
          outcome: MatchOutcome.playerWin,
        ),
        record(
          id: '2',
          gameId: 'pokemon',
          endedAt: reference,
          outcome: MatchOutcome.playerLoss,
        ),
        record(
          id: '3',
          gameId: 'magic',
          endedAt: reference,
          outcome: MatchOutcome.draw,
        ),
      ],
      referenceTime: reference,
    );

    expect(stats.totalMatches, 3);
    expect(stats.winRatePercent, 50);
    expect(stats.wins, 1);
    expect(stats.losses, 1);
    expect(stats.draws, 1);
  });

  test('groups games by tcg sorted by count', () {
    final stats = calculator(
      [
        record(
          id: '1',
          gameId: 'pokemon',
          endedAt: reference,
          outcome: MatchOutcome.playerWin,
        ),
        record(
          id: '2',
          gameId: 'pokemon',
          endedAt: reference,
          outcome: MatchOutcome.playerWin,
        ),
        record(
          id: '3',
          gameId: 'magic',
          endedAt: reference,
          outcome: MatchOutcome.playerLoss,
        ),
      ],
      referenceTime: reference,
    );

    expect(stats.gamesByTcg.first.gameId, 'pokemon');
    expect(stats.gamesByTcg.first.count, 2);
    expect(stats.gamesByTcg[1].gameId, 'magic');
  });

  test('counts matches in current week', () {
    final monday = DateTime.parse('2026-05-18T12:00:00.000');

    final stats = calculator(
      [
        record(
          id: '1',
          gameId: 'pokemon',
          endedAt: monday,
          outcome: MatchOutcome.playerWin,
        ),
        record(
          id: '2',
          gameId: 'pokemon',
          endedAt: monday.subtract(const Duration(days: 8)),
          outcome: MatchOutcome.playerWin,
        ),
      ],
      referenceTime: reference,
    );

    expect(stats.matchesThisWeek, 1);
    expect(stats.weeklyFrequency.length, 8);
  });

  test('calculates average duration', () {
    final stats = calculator(
      [
        record(
          id: '1',
          gameId: 'pokemon',
          endedAt: reference,
          outcome: MatchOutcome.playerWin,
          durationMinutes: 20,
        ),
        record(
          id: '2',
          gameId: 'pokemon',
          endedAt: reference,
          outcome: MatchOutcome.playerWin,
          durationMinutes: 40,
        ),
      ],
      referenceTime: reference,
    );

    expect(stats.averageDuration?.inMinutes, 30);
  });
}
