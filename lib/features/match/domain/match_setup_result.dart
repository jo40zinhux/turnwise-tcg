import 'match_life_state.dart';

/// Result of the pre-match setup sheet (turn order + optional life preset).
class MatchSetupResult {
  final bool playerWentFirst;
  final MatchLifeState? initialLife;

  const MatchSetupResult({
    required this.playerWentFirst,
    this.initialLife,
  });
}
