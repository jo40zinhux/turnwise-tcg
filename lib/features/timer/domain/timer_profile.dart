/// Timer preset used during a match session or recorded match.
enum TimerProfile {
  casual,
  bo1,
  bo3,
  round;

  String get storageKey => name;

  static TimerProfile? fromStorageKey(String? value) {
    if (value == null) return null;
    for (final profile in TimerProfile.values) {
      if (profile.storageKey == value) return profile;
    }
    return null;
  }
}
