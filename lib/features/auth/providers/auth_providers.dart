import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/auth_service.dart';

// Provider for the AuthService instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StreamProvider observing the Firebase Authentication state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

// Provider for Onboarding state
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
