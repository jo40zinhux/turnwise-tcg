import 'package:shared_preferences/shared_preferences.dart';

/// Persists match board panel expand state and first-use coaching.
class MatchBoardPanelPreferences {
  static const introSeenKey = 'match_board_panel_intro_seen';

  static String expandedKey(String gameId) =>
      'match_board_panel_expanded_$gameId';

  final SharedPreferences _prefs;

  MatchBoardPanelPreferences(this._prefs);

  bool isExpanded(String gameId) =>
      _prefs.getBool(expandedKey(gameId)) ?? false;

  Future<void> setExpanded(String gameId, bool expanded) =>
      _prefs.setBool(expandedKey(gameId), expanded);

  bool get introSeen => _prefs.getBool(introSeenKey) ?? false;

  Future<void> markIntroSeen() => _prefs.setBool(introSeenKey, true);
}
