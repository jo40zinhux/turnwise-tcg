import 'active_effect.dart';
import 'checkup_reminder.dart';

/// Effect + checkup runtime state carried by [MatchEngineState].
class MatchEffectsState {
  final List<ActiveEffect> activeEffects;
  final int turnNumber;
  final List<CheckupReminder> pendingCheckups;

  const MatchEffectsState({
    this.activeEffects = const [],
    this.turnNumber = 1,
    this.pendingCheckups = const [],
  });

  static const empty = MatchEffectsState();

  List<ActiveEffect> get nonExpiredEffects =>
      activeEffects.where((effect) => !effect.isExpired).toList();

  Set<String> get lockedActionIds {
    final locks = <String>{};
    for (final effect in nonExpiredEffects) {
      if (effect.type.storageKey == 'action_lock' ||
          effect.type.storageKey == 'attack_restriction') {
        locks.addAll(effect.lockedActionIds);
      }
    }
    return locks;
  }

  MatchEffectsState copyWith({
    List<ActiveEffect>? activeEffects,
    int? turnNumber,
    List<CheckupReminder>? pendingCheckups,
    bool clearCheckups = false,
  }) {
    return MatchEffectsState(
      activeEffects: activeEffects ?? this.activeEffects,
      turnNumber: turnNumber ?? this.turnNumber,
      pendingCheckups:
          clearCheckups ? const [] : (pendingCheckups ?? this.pendingCheckups),
    );
  }

  factory MatchEffectsState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MatchEffectsState.empty;

    return MatchEffectsState(
      activeEffects: (json['activeEffects'] as List<dynamic>?)
              ?.map((e) => ActiveEffect.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      turnNumber: json['turnNumber'] as int? ?? 1,
      pendingCheckups: (json['pendingCheckups'] as List<dynamic>?)
              ?.map((e) => CheckupReminder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeEffects': activeEffects.map((e) => e.toJson()).toList(),
      'turnNumber': turnNumber,
      'pendingCheckups': pendingCheckups.map((e) => e.toJson()).toList(),
    };
  }
}
