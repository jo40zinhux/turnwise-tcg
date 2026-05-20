import '../../timer/domain/timer_profile.dart';

class MatchSession {
  final String gameId;
  final int currentPhaseIndex;
  final Map<String, int> actionUsageCount;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final TimerProfile? timerProfile;
  final int timerElapsedSeconds;
  final int? timerRemainingSeconds;
  final bool timerIsRunning;
  final int bo3PlayerWins;
  final int bo3OpponentWins;
  final int bo3CurrentGame;

  const MatchSession({
    required this.gameId,
    required this.currentPhaseIndex,
    required this.actionUsageCount,
    required this.updatedAt,
    this.startedAt,
    this.timerProfile,
    this.timerElapsedSeconds = 0,
    this.timerRemainingSeconds,
    this.timerIsRunning = true,
    this.bo3PlayerWins = 0,
    this.bo3OpponentWins = 0,
    this.bo3CurrentGame = 1,
  });

  factory MatchSession.fromJson(Map<String, dynamic> json) {
    final usageRaw = json['actionUsageCount'] as Map<String, dynamic>? ?? {};
    return MatchSession(
      gameId: json['gameId'] as String,
      currentPhaseIndex: json['currentPhaseIndex'] as int? ?? 0,
      actionUsageCount: usageRaw.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      timerProfile:
          TimerProfile.fromStorageKey(json['timerProfile'] as String?),
      timerElapsedSeconds: json['timerElapsedSeconds'] as int? ?? 0,
      timerRemainingSeconds: json['timerRemainingSeconds'] as int?,
      timerIsRunning: json['timerIsRunning'] as bool? ?? true,
      bo3PlayerWins: json['bo3PlayerWins'] as int? ?? 0,
      bo3OpponentWins: json['bo3OpponentWins'] as int? ?? 0,
      bo3CurrentGame: json['bo3CurrentGame'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'currentPhaseIndex': currentPhaseIndex,
      'actionUsageCount': actionUsageCount,
      'updatedAt': updatedAt.toIso8601String(),
      if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
      if (timerProfile != null) 'timerProfile': timerProfile!.storageKey,
      'timerElapsedSeconds': timerElapsedSeconds,
      if (timerRemainingSeconds != null)
        'timerRemainingSeconds': timerRemainingSeconds,
      'timerIsRunning': timerIsRunning,
      'bo3PlayerWins': bo3PlayerWins,
      'bo3OpponentWins': bo3OpponentWins,
      'bo3CurrentGame': bo3CurrentGame,
    };
  }

  MatchSession copyWith({
    String? gameId,
    int? currentPhaseIndex,
    Map<String, int>? actionUsageCount,
    DateTime? updatedAt,
    DateTime? startedAt,
    TimerProfile? timerProfile,
    int? timerElapsedSeconds,
    int? timerRemainingSeconds,
    bool? timerIsRunning,
    int? bo3PlayerWins,
    int? bo3OpponentWins,
    int? bo3CurrentGame,
  }) {
    return MatchSession(
      gameId: gameId ?? this.gameId,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      actionUsageCount: actionUsageCount ?? this.actionUsageCount,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      timerProfile: timerProfile ?? this.timerProfile,
      timerElapsedSeconds: timerElapsedSeconds ?? this.timerElapsedSeconds,
      timerRemainingSeconds:
          timerRemainingSeconds ?? this.timerRemainingSeconds,
      timerIsRunning: timerIsRunning ?? this.timerIsRunning,
      bo3PlayerWins: bo3PlayerWins ?? this.bo3PlayerWins,
      bo3OpponentWins: bo3OpponentWins ?? this.bo3OpponentWins,
      bo3CurrentGame: bo3CurrentGame ?? this.bo3CurrentGame,
    );
  }
}
