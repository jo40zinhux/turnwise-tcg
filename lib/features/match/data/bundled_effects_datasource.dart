import 'package:flutter/services.dart';

import '../domain/game_effects_bundle.dart';

/// Loads per-game effects libraries from assets.
class BundledEffectsDataSource {
  Future<GameEffectsBundle?> loadEffectsBundle(String gameId) async {
    final path = 'assets/rules/effects/${gameId}_effects.json';
    try {
      final raw = await rootBundle.loadString(path);
      return GameEffectsBundle.fromRawJson(gameId, raw);
    } catch (_) {
      return null;
    }
  }
}
