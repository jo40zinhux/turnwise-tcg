import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../domain/active_effect.dart';
import '../../domain/effect_definition.dart';
import '../../domain/effect_type.dart';
import '../../domain/game_rules.dart';

/// Shows active effects, locks, and quick apply controls.
class MatchEffectsPanel extends StatelessWidget {
  final GameRules rules;
  final List<ActiveEffect> activeEffects;
  final Set<String> lockedActionIds;
  final ValueChanged<String> onApplyEffect;
  final ValueChanged<String> onRemoveEffect;

  const MatchEffectsPanel({
    super.key,
    required this.rules,
    required this.activeEffects,
    required this.lockedActionIds,
    required this.onApplyEffect,
    required this.onRemoveEffect,
  });

  @override
  Widget build(BuildContext context) {
    final visible = activeEffects.where((e) => !e.isExpired).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Estado da mesa',
                style: AppTypography.label(context),
              ),
            ),
            if (rules.effects.isNotEmpty)
              TextButton.icon(
                onPressed: () => _showApplySheet(context),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Marcar efeito'),
              ),
          ],
        ),
        if (lockedActionIds.isNotEmpty) ...[
          AppSpacing.gapSm,
          _LocksRow(lockedActionIds: lockedActionIds),
        ],
        if (visible.isEmpty) ...[
          AppSpacing.gapSm,
          Text(
            'Sem efeitos ativos. Usa "Marcar efeito" para condições entre turnos.',
            style: AppTypography.caption(context),
          ),
        ] else ...[
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final effect in visible)
                _ActiveEffectChip(
                  effect: effect,
                  onRemove: () => onRemoveEffect(effect.instanceId),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _showApplySheet(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: AppSpacing.screen,
                child: Text(
                  'Marcar efeito',
                  style: AppTypography.title(ctx),
                ),
              ),
              for (final definition in rules.effects)
                ListTile(
                  leading: Icon(
                    getIconFromString(definition.iconCode ?? 'info_outline'),
                  ),
                  title: Text(definition.name),
                  subtitle: Text(_effectSubtitle(definition)),
                  onTap: () => Navigator.pop(ctx, definition.id),
                ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      onApplyEffect(selected);
    }
  }

  String _effectSubtitle(EffectDefinition definition) {
    final duration = switch (definition.duration.kind.storageKey) {
      'turns' => '${definition.duration.value ?? 1} turno(s)',
      'phases' => '${definition.duration.value ?? 1} fase(s)',
      _ => 'Até remover',
    };
    return '${definition.type.storageKey} · $duration';
  }
}

class _LocksRow extends StatelessWidget {
  final Set<String> lockedActionIds;

  const _LocksRow({required this.lockedActionIds});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: semantic.warningMuted,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: semantic.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 18, color: semantic.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Ações bloqueadas: ${lockedActionIds.join(', ')}',
              style: AppTypography.caption(context).copyWith(
                color: semantic.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveEffectChip extends StatelessWidget {
  final ActiveEffect effect;
  final VoidCallback onRemove;

  const _ActiveEffectChip({
    required this.effect,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final isLock = effect.type == EffectType.actionLock ||
        effect.type == EffectType.attackRestriction;

    final label = effect.durationLabel != null
        ? '${effect.name} · ${effect.durationLabel}'
        : effect.name;

    return InputChip(
      avatar: Icon(
        getIconFromString(effect.iconCode ?? 'info_outline'),
        size: 18,
        color: isLock ? semantic.warning : semantic.info,
      ),
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onRemove,
      visualDensity: VisualDensity.compact,
      labelStyle: AppTypography.caption(context),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      side: BorderSide(
        color: (isLock ? semantic.warning : semantic.info).withOpacity(0.45),
      ),
    );
  }
}
