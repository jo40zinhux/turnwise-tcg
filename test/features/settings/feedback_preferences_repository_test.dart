import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/features/settings/data/shared_prefs_feedback_preferences_repository.dart';
import 'package:turnwise_tcg/features/settings/domain/feedback_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPrefsFeedbackPreferencesRepository', () {
    test('load returns defaults when storage is empty', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsFeedbackPreferencesRepository(prefs);

      expect(repo.load(), FeedbackPreferences.defaults);
    });

    test('save then load round-trips both flags', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsFeedbackPreferencesRepository(prefs);

      await repo.save(
        const FeedbackPreferences(hapticEnabled: false, soundEnabled: false),
      );

      final loaded = repo.load();
      expect(loaded.hapticEnabled, false);
      expect(loaded.soundEnabled, false);
    });

    test('save persists each flag independently', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = SharedPrefsFeedbackPreferencesRepository(prefs);

      await repo.save(
        const FeedbackPreferences(hapticEnabled: true, soundEnabled: false),
      );

      final loaded = repo.load();
      expect(loaded.hapticEnabled, true);
      expect(loaded.soundEnabled, false);
    });
  });

  group('FeedbackPreferences value equality', () {
    test('equal when fields match', () {
      expect(
        const FeedbackPreferences(hapticEnabled: true, soundEnabled: true),
        const FeedbackPreferences(hapticEnabled: true, soundEnabled: true),
      );
    });

    test('not equal when a field differs', () {
      expect(
        const FeedbackPreferences(hapticEnabled: true, soundEnabled: true),
        isNot(const FeedbackPreferences(hapticEnabled: false, soundEnabled: true)),
      );
    });
  });
}
