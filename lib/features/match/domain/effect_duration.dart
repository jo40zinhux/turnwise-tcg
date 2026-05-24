/// How long an effect remains active.
enum EffectDurationKind {
  turns('turns'),
  phases('phases'),
  permanent('permanent');

  const EffectDurationKind(this.storageKey);

  final String storageKey;

  static EffectDurationKind fromStorageKey(String? value) {
    return EffectDurationKind.values.firstWhere(
      (kind) => kind.storageKey == value,
      orElse: () => EffectDurationKind.turns,
    );
  }
}

class EffectDuration {
  final EffectDurationKind kind;
  final int? value;

  /// Original library type from JSON (e.g. until_end_opponent_turn).
  final String? libraryKind;

  const EffectDuration({
    required this.kind,
    this.value,
    this.libraryKind,
  });

  bool get expiresOnOpponentTurnEnd => libraryKind == 'until_end_opponent_turn';

  bool get isPermanent => kind == EffectDurationKind.permanent;

  factory EffectDuration.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return const EffectDuration(kind: EffectDurationKind.permanent);
    }

    final rawKind = json['kind'] as String? ?? json['type'] as String?;
    final parsed = _fromLibraryKind(rawKind);
    return EffectDuration(
      kind: parsed.$1,
      value: parsed.$2 ?? json['value'] as int?,
      libraryKind: rawKind,
    );
  }

  static (EffectDurationKind, int?) _fromLibraryKind(String? raw) {
    return switch (raw) {
      'turns' => (EffectDurationKind.turns, null),
      'phases' => (EffectDurationKind.phases, null),
      'permanent' || 'continuous' => (EffectDurationKind.permanent, null),
      'until_end_turn' ||
      'until_end_opponent_turn' ||
      'until_next_turn' =>
        (EffectDurationKind.turns, 1),
      null => (EffectDurationKind.permanent, null),
      _ => (EffectDurationKind.turns, 1),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.storageKey,
      if (value != null) 'value': value,
      if (libraryKind != null) 'type': libraryKind,
    };
  }
}
