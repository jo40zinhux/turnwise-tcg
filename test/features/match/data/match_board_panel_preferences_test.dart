import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/features/match/data/match_board_panel_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('MatchBoardPanelPreferences', () {
    test('persists expanded state per gameId', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = MatchBoardPanelPreferences(prefs);

      expect(store.isExpanded('pokemon'), isFalse);
      expect(store.isExpanded('magic'), isFalse);

      await store.setExpanded('pokemon', true);

      expect(store.isExpanded('pokemon'), isTrue);
      expect(store.isExpanded('magic'), isFalse);
    });

    test('intro seen is global across games', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = MatchBoardPanelPreferences(prefs);

      expect(store.introSeen, isFalse);

      await store.markIntroSeen();

      expect(store.introSeen, isTrue);
      expect(
        prefs.getBool(MatchBoardPanelPreferences.introSeenKey),
        isTrue,
      );
    });

    test('expanded keys are isolated per game', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = MatchBoardPanelPreferences(prefs);

      await store.setExpanded('pokemon', true);
      await store.setExpanded('one_piece', false);

      expect(
        prefs.getBool(MatchBoardPanelPreferences.expandedKey('pokemon')),
        isTrue,
      );
      expect(
        prefs.getBool(MatchBoardPanelPreferences.expandedKey('one_piece')),
        isFalse,
      );
    });
  });
}
