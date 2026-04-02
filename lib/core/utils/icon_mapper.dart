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
    default:
      return Icons.help_outline; // Fallback
  }
}
