import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/firebase_auth_repository.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class OnboardingStateNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  OnboardingStateNotifier(this._prefs)
      : super(_prefs.getBool('hasCompletedOnboarding') ?? false);

  Future<void> completeOnboarding() async {
    await _prefs.setBool('hasCompletedOnboarding', true);
    state = true;
  }
}

final onboardingStateProvider =
    StateNotifierProvider<OnboardingStateNotifier, bool>((ref) {
  return OnboardingStateNotifier(ref.watch(sharedPreferencesProvider));
});
