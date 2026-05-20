import 'package:flutter/services.dart';

/// Verifies bundled rule JSON assets exist for a game id.
class RulesAssetChecker {
  Future<bool> hasRulesAsset(String gameId) async {
    try {
      await rootBundle.loadString('assets/rules/$gameId.json');
      return true;
    } catch (_) {
      return false;
    }
  }
}
