import '../../timer/domain/timer_profile.dart';
import 'match_outcome.dart';

class CompleteMatchParams {
  final String gameId;
  final MatchOutcome outcome;
  final String? notes;
  final DateTime? startedAt;
  final TimerProfile? timerProfile;
  final int? roundsPlayed;

  const CompleteMatchParams({
    required this.gameId,
    required this.outcome,
    this.notes,
    this.startedAt,
    this.timerProfile,
    this.roundsPlayed,
  });
}
