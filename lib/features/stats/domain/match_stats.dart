import 'game_play_count.dart';
import 'weekly_play_count.dart';

class MatchStats {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final int abandoned;
  final double? winRatePercent;
  final Duration? averageDuration;
  final int matchesThisWeek;
  final List<GamePlayCount> gamesByTcg;
  final List<WeeklyPlayCount> weeklyFrequency;

  const MatchStats({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.abandoned,
    required this.winRatePercent,
    required this.averageDuration,
    required this.matchesThisWeek,
    required this.gamesByTcg,
    required this.weeklyFrequency,
  });

  static const empty = MatchStats(
    totalMatches: 0,
    wins: 0,
    losses: 0,
    draws: 0,
    abandoned: 0,
    winRatePercent: null,
    averageDuration: null,
    matchesThisWeek: 0,
    gamesByTcg: [],
    weeklyFrequency: [],
  );

  bool get isEmpty => totalMatches == 0;
}
