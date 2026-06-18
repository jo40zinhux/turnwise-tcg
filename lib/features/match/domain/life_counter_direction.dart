/// Whether a counter counts down (life, prizes) or up (lore, victory points).
enum LifeCounterDirection {
  down,
  up;

  static LifeCounterDirection fromJson(String? value) {
    return switch (value) {
      'up' => LifeCounterDirection.up,
      _ => LifeCounterDirection.down,
    };
  }

  String get storageKey => name;
}
