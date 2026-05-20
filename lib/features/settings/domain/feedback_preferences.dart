/// User preferences for tactile and audio feedback.
///
/// Persisted via the settings repository; defaults to both enabled so the
/// app feels "alive" out of the box. Sound is treated as opt-out instead of
/// opt-in to match competitive-app expectations.
class FeedbackPreferences {
  final bool hapticEnabled;
  final bool soundEnabled;

  const FeedbackPreferences({
    required this.hapticEnabled,
    required this.soundEnabled,
  });

  static const FeedbackPreferences defaults = FeedbackPreferences(
    hapticEnabled: true,
    soundEnabled: true,
  );

  FeedbackPreferences copyWith({
    bool? hapticEnabled,
    bool? soundEnabled,
  }) {
    return FeedbackPreferences(
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackPreferences &&
          other.hapticEnabled == hapticEnabled &&
          other.soundEnabled == soundEnabled;

  @override
  int get hashCode => Object.hash(hapticEnabled, soundEnabled);
}
