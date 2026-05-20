import '../../timer/domain/timer_profile.dart';
import 'match_outcome.dart';
import 'sync_status.dart';

/// Completed match archived for history, stats, and achievements.
class MatchRecord {
  final String id;
  final String gameId;
  final DateTime startedAt;
  final DateTime endedAt;
  final MatchOutcome outcome;
  final String? notes;
  final TimerProfile? timerProfile;
  final int? roundsPlayed;
  final SyncStatus syncStatus;
  final DateTime updatedAt;

  const MatchRecord({
    required this.id,
    required this.gameId,
    required this.startedAt,
    required this.endedAt,
    required this.outcome,
    this.notes,
    this.timerProfile,
    this.roundsPlayed,
    this.syncStatus = SyncStatus.pending,
    required this.updatedAt,
  });

  Duration get duration => endedAt.difference(startedAt);

  bool get isWin => outcome == MatchOutcome.playerWin;

  MatchRecord copyWith({
    String? id,
    String? gameId,
    DateTime? startedAt,
    DateTime? endedAt,
    MatchOutcome? outcome,
    String? notes,
    TimerProfile? timerProfile,
    int? roundsPlayed,
    SyncStatus? syncStatus,
    DateTime? updatedAt,
  }) {
    return MatchRecord(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      outcome: outcome ?? this.outcome,
      notes: notes ?? this.notes,
      timerProfile: timerProfile ?? this.timerProfile,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory MatchRecord.fromJson(Map<String, dynamic> json) {
    return MatchRecord(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      outcome: MatchOutcome.fromStorageKey(json['outcome'] as String?) ??
          MatchOutcome.abandoned,
      notes: json['notes'] as String?,
      timerProfile: TimerProfile.fromStorageKey(json['timerProfile'] as String?),
      roundsPlayed: json['roundsPlayed'] as int?,
      syncStatus: SyncStatus.fromStorageKey(json['syncStatus'] as String?),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'outcome': outcome.storageKey,
      if (notes != null) 'notes': notes,
      if (timerProfile != null) 'timerProfile': timerProfile!.storageKey,
      if (roundsPlayed != null) 'roundsPlayed': roundsPlayed,
      'syncStatus': syncStatus.storageKey,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
