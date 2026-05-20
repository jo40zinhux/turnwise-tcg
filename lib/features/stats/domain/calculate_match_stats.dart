import '../../match_history/domain/match_outcome.dart';
import '../../match_history/domain/match_record.dart';
import 'game_play_count.dart';
import 'match_stats.dart';
import 'weekly_play_count.dart';

/// Derives retention metrics from completed match records.
class CalculateMatchStats {
  const CalculateMatchStats();

  MatchStats call(
    List<MatchRecord> records, {
    DateTime? referenceTime,
  }) {
    if (records.isEmpty) return MatchStats.empty;

    final now = referenceTime ?? DateTime.now();
    var wins = 0;
    var losses = 0;
    var draws = 0;
    var abandoned = 0;
    var totalDurationSeconds = 0;

    final tcgCounts = <String, int>{};

    for (final record in records) {
      switch (record.outcome) {
        case MatchOutcome.playerWin:
          wins++;
        case MatchOutcome.playerLoss:
          losses++;
        case MatchOutcome.draw:
          draws++;
        case MatchOutcome.abandoned:
          abandoned++;
      }

      totalDurationSeconds += record.duration.inSeconds.clamp(0, 86400);
      tcgCounts.update(record.gameId, (value) => value + 1, ifAbsent: () => 1);
    }

    final totalMatches = records.length;
    final decisive = wins + losses;
    final winRatePercent =
        decisive > 0 ? (wins / decisive) * 100 : null;

    final averageDuration = Duration(
      seconds: (totalDurationSeconds / totalMatches).round(),
    );

    final gamesByTcg = tcgCounts.entries
        .map((e) => GamePlayCount(gameId: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return MatchStats(
      totalMatches: totalMatches,
      wins: wins,
      losses: losses,
      draws: draws,
      abandoned: abandoned,
      winRatePercent: winRatePercent,
      averageDuration: averageDuration,
      matchesThisWeek: _matchesInWeek(records, _startOfWeek(now)),
      gamesByTcg: gamesByTcg,
      weeklyFrequency: _weeklyFrequency(records, now),
    );
  }

  int _matchesInWeek(List<MatchRecord> records, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return records.where((record) {
      return !record.endedAt.isBefore(weekStart) &&
          record.endedAt.isBefore(weekEnd);
    }).length;
  }

  List<WeeklyPlayCount> _weeklyFrequency(
    List<MatchRecord> records,
    DateTime now,
  ) {
    const weeksToShow = 8;
    final currentWeekStart = _startOfWeek(now);
    final buckets = <DateTime, int>{};

    for (var i = weeksToShow - 1; i >= 0; i--) {
      final weekStart = currentWeekStart.subtract(Duration(days: 7 * i));
      buckets[weekStart] = 0;
    }

    for (final record in records) {
      final weekStart = _startOfWeek(record.endedAt);
      if (buckets.containsKey(weekStart)) {
        buckets[weekStart] = buckets[weekStart]! + 1;
      }
    }

    return buckets.entries
        .map(
          (entry) => WeeklyPlayCount(
            weekStart: entry.key,
            count: entry.value,
            label: _weekLabel(entry.key),
          ),
        )
        .toList();
  }

  DateTime _startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final weekday = day.weekday;
    return day.subtract(Duration(days: weekday - DateTime.monday));
  }

  String _weekLabel(DateTime weekStart) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${weekStart.day} ${months[weekStart.month - 1]}';
  }
}
