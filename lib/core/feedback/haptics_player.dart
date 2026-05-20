import 'package:flutter/services.dart';

/// Thin abstraction over [HapticFeedback] so [MatchFeedbackService] can be
/// unit-tested without invoking platform channels.
abstract class HapticsPlayer {
  Future<void> selection();
  Future<void> light();
  Future<void> medium();
  Future<void> heavy();
}

class SystemHapticsPlayer implements HapticsPlayer {
  const SystemHapticsPlayer();

  @override
  Future<void> selection() => HapticFeedback.selectionClick();

  @override
  Future<void> light() => HapticFeedback.lightImpact();

  @override
  Future<void> medium() => HapticFeedback.mediumImpact();

  @override
  Future<void> heavy() => HapticFeedback.heavyImpact();
}
