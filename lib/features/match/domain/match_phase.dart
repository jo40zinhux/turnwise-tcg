// lib/features/match/domain/match_phase.dart

import 'package:flutter/material.dart';

enum MatchPhase {
  draw('Draw Phase', 'Start your turn by drawing a card.', Icons.copy_outlined),
  main1('Main Phase 1', 'Play cards, summon creatures or prepare your board.',
      Icons.back_hand_rounded),
  combat('Combat Phase', 'Declare attacks and engage the opponent.',
      Icons.sports_martial_arts_rounded),
  main2('Main Phase 2', 'Final preparations before ending your turn.',
      Icons.shield_rounded),
  end('End Phase', 'Cleanup effects and pass the turn.',
      Icons.front_hand_rounded);

  final String title;
  final String description;
  final IconData icon;

  const MatchPhase(this.title, this.description, this.icon);
}
