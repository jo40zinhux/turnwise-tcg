import 'package:flutter/material.dart';

import '../../../../core/theme/app_semantic_colors.dart';
import '../../domain/match_outcome.dart';

class MatchOutcomeVisual {
  final IconData icon;
  final Color accent;
  final Color mutedBackground;
  final String headline;

  const MatchOutcomeVisual({
    required this.icon,
    required this.accent,
    required this.mutedBackground,
    required this.headline,
  });

  factory MatchOutcomeVisual.of(MatchOutcome outcome, AppSemanticTheme semantic) {
    return switch (outcome) {
      MatchOutcome.playerWin => MatchOutcomeVisual(
          icon: Icons.emoji_events_outlined,
          accent: semantic.success,
          mutedBackground: semantic.successMuted,
          headline: 'Vitória!',
        ),
      MatchOutcome.playerLoss => MatchOutcomeVisual(
          icon: Icons.flag_outlined,
          accent: semantic.danger,
          mutedBackground: semantic.dangerMuted,
          headline: 'Derrota',
        ),
      MatchOutcome.draw => MatchOutcomeVisual(
          icon: Icons.handshake_outlined,
          accent: semantic.info,
          mutedBackground: semantic.infoMuted,
          headline: 'Empate',
        ),
      MatchOutcome.abandoned => MatchOutcomeVisual(
          icon: Icons.exit_to_app_rounded,
          accent: semantic.warning,
          mutedBackground: semantic.warningMuted,
          headline: 'Partida encerrada',
        ),
    };
  }
}
