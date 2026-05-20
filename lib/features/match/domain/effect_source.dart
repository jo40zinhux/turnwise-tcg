/// Tracks why an active effect exists (action, definition, manual, checkup).
enum EffectSourceKind {
  action('action'),
  definition('definition'),
  manual('manual'),
  checkup('checkup');

  const EffectSourceKind(this.storageKey);

  final String storageKey;

  static EffectSourceKind fromStorageKey(String? value) {
    return EffectSourceKind.values.firstWhere(
      (kind) => kind.storageKey == value,
      orElse: () => EffectSourceKind.definition,
    );
  }
}

class EffectSource {
  final EffectSourceKind kind;
  final String? referenceId;

  const EffectSource({required this.kind, this.referenceId});

  factory EffectSource.fromJson(Map<String, dynamic> json) {
    return EffectSource(
      kind: EffectSourceKind.fromStorageKey(json['kind'] as String?),
      referenceId: json['referenceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.storageKey,
      if (referenceId != null) 'referenceId': referenceId,
    };
  }

  static EffectSource manual() => const EffectSource(kind: EffectSourceKind.manual);

  static EffectSource fromAction(String actionId) => EffectSource(
        kind: EffectSourceKind.action,
        referenceId: actionId,
      );

  static EffectSource fromDefinition(String effectId) => EffectSource(
        kind: EffectSourceKind.definition,
        referenceId: effectId,
      );
}
