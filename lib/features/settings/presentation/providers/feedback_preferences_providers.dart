import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../data/shared_prefs_feedback_preferences_repository.dart';
import '../../domain/feedback_preferences.dart';
import '../../domain/feedback_preferences_repository.dart';

final feedbackPreferencesRepositoryProvider =
    Provider<FeedbackPreferencesRepository>((ref) {
  return SharedPrefsFeedbackPreferencesRepository(
    ref.watch(sharedPreferencesProvider),
  );
});

class FeedbackPreferencesNotifier extends StateNotifier<FeedbackPreferences> {
  final FeedbackPreferencesRepository _repo;

  FeedbackPreferencesNotifier(this._repo) : super(_repo.load());

  Future<void> setHapticEnabled(bool value) async {
    if (state.hapticEnabled == value) return;
    state = state.copyWith(hapticEnabled: value);
    await _repo.save(state);
  }

  Future<void> setSoundEnabled(bool value) async {
    if (state.soundEnabled == value) return;
    state = state.copyWith(soundEnabled: value);
    await _repo.save(state);
  }
}

final feedbackPreferencesProvider =
    StateNotifierProvider<FeedbackPreferencesNotifier, FeedbackPreferences>(
        (ref) {
  return FeedbackPreferencesNotifier(
    ref.watch(feedbackPreferencesRepositoryProvider),
  );
});
