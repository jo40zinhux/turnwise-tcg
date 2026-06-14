import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../data/match_board_panel_preferences.dart';

final matchBoardPanelPreferencesProvider =
    Provider<MatchBoardPanelPreferences>((ref) {
  return MatchBoardPanelPreferences(ref.watch(sharedPreferencesProvider));
});
