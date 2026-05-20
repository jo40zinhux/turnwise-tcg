// lib/core/utils/icon_mapper.dart

import 'package:flutter/material.dart';

IconData getIconFromString(String iconCode) {
  switch (iconCode) {
    case 'copy_outlined':
      return Icons.copy_outlined;
    case 'back_hand_rounded':
      return Icons.back_hand_rounded;
    case 'sports_martial_arts_rounded':
      return Icons.sports_martial_arts_rounded;
    case 'shield_rounded':
      return Icons.shield_rounded;
    case 'front_hand_rounded':
      return Icons.front_hand_rounded;
    case 'play_arrow':
      return Icons.play_arrow;
    case 'flash_on':
      return Icons.flash_on;
    case 'pan_tool':
      return Icons.pan_tool;
    case 'refresh':
      return Icons.refresh;
    case 'bolt':
      return Icons.bolt;
    case 'stars':
      return Icons.stars;
    case 'sports_mma':
      return Icons.sports_mma;
    case 'fireplace':
      return Icons.fireplace;
    case 'dark_mode':
      return Icons.dark_mode;
    case 'bloodtype':
      return Icons.bloodtype;
    case 'auto_awesome':
      return Icons.auto_awesome;
    case 'catching_pokemon':
      return Icons.catching_pokemon;
    case 'sailing':
      return Icons.sailing;
    case 'style':
      return Icons.style;
    case 'emoji_events_outlined':
      return Icons.emoji_events_outlined;
    case 'military_tech_outlined':
      return Icons.military_tech_outlined;
    case 'workspace_premium_outlined':
      return Icons.workspace_premium_outlined;
    case 'flag_outlined':
      return Icons.flag_outlined;
    case 'handshake_outlined':
      return Icons.handshake_outlined;
    case 'exit_to_app_rounded':
      return Icons.exit_to_app_rounded;
    default:
      return Icons.help_outline; // Fallback
  }
}
