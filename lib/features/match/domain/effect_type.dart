/// Categories of match effects supported by the effect engine.
enum EffectType {
  actionLock('action_lock'),
  status('status'),
  modifier('modifier'),
  trigger('trigger'),
  phaseSkip('phase_skip'),
  attackRestriction('attack_restriction');

  const EffectType(this.storageKey);

  final String storageKey;

  static EffectType fromStorageKey(String? value) {
    return switch (value) {
      'action_lock' ||
      'ability_lock' ||
      'summon_lock' ||
      'movement_lock' =>
        EffectType.actionLock,
      'attack_restriction' || 'block_restriction' => EffectType.attackRestriction,
      'modifier' || 'targeting_modifier' => EffectType.modifier,
      'trigger' => EffectType.trigger,
      'phase_skip' => EffectType.phaseSkip,
      'status' => EffectType.status,
      _ => EffectType.status,
    };
  }
}
