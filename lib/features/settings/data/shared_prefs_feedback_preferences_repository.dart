import 'package:shared_preferences/shared_preferences.dart';

import '../domain/feedback_preferences.dart';
import '../domain/feedback_preferences_repository.dart';

/// SharedPreferences-backed implementation of [FeedbackPreferencesRepository].
class SharedPrefsFeedbackPreferencesRepository
    implements FeedbackPreferencesRepository {
  static const _hapticKey = 'settings.feedback.haptic_enabled';
  static const _soundKey = 'settings.feedback.sound_enabled';

  final SharedPreferences _prefs;

  SharedPrefsFeedbackPreferencesRepository(this._prefs);

  @override
  FeedbackPreferences load() {
    return FeedbackPreferences(
      hapticEnabled:
          _prefs.getBool(_hapticKey) ?? FeedbackPreferences.defaults.hapticEnabled,
      soundEnabled:
          _prefs.getBool(_soundKey) ?? FeedbackPreferences.defaults.soundEnabled,
    );
  }

  @override
  Future<void> save(FeedbackPreferences preferences) async {
    await Future.wait([
      _prefs.setBool(_hapticKey, preferences.hapticEnabled),
      _prefs.setBool(_soundKey, preferences.soundEnabled),
    ]);
  }
}
