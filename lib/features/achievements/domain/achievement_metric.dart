enum AchievementMetric {
  matchCount,
  winCount;

  static AchievementMetric? fromStorageKey(String? value) {
    if (value == null) return null;
    for (final metric in AchievementMetric.values) {
      if (metric.storageKey == value) return metric;
    }
    return null;
  }

  String get storageKey => name;
}
