import 'feedback_preferences.dart';

/// Repository contract for [FeedbackPreferences].
///
/// Kept transport-agnostic: today the implementation persists to
/// SharedPreferences; a future remote-sync implementation can swap in
/// without touching the presentation layer.
abstract class FeedbackPreferencesRepository {
  FeedbackPreferences load();
  Future<void> save(FeedbackPreferences preferences);
}
