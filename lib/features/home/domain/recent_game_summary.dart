class RecentGameSummary {
  final String gameId;
  final String gameName;
  final DateTime lastPlayedAt;
  final int recentMatchCount;

  const RecentGameSummary({
    required this.gameId,
    required this.gameName,
    required this.lastPlayedAt,
    required this.recentMatchCount,
  });
}
