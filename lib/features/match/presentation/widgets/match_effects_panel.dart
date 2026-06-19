import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../../shared/widgets/match_chip_surface.dart';
import '../../domain/active_effect.dart';
import '../../domain/effect_definition.dart';
import '../../domain/effect_type.dart';
import '../../domain/game_rules.dart';
import '../../domain/match_action_filter.dart';

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
          _LocksRow(rules: rules, lockedActionIds: lockedActionIds),
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
  final GameRules rules;
  final Set<String> lockedActionIds;

  const _LocksRow({required this.rules, required this.lockedActionIds});

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
        border: Border.all(color: semantic.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 18, color: semantic.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Ações bloqueadas: ${MatchActionFilter.resolveActionLabels(rules.actions, lockedActionIds).join(', ')}',
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
    final accent = isLock ? semantic.warning : semantic.info;
    final accentMuted = isLock ? semantic.warningMuted : semantic.infoMuted;

    final label = effect.durationLabel != null
        ? '${effect.name} · ${effect.durationLabel}'
        : effect.name;

    final style = MatchChipStyle.accent(accent: accent, accentMuted: accentMuted);

    return Tooltip(
      message: 'Toca no X para remover',
      child: Semantics(
        label: label,
        button: true,
        child: MatchChipSurface(
          backgroundColor: style.backgroundColor,
          borderSide: style.borderSide,
          animate: false,
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            right: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                getIconFromString(effect.iconCode ?? 'info_outline'),
                size: 18,
                color: accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.caption(context).copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: 'Remover $label',
                child: IconButton(
                  onPressed: onRemove,
                  iconSize: 18,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  icon: Icon(Icons.close_rounded, color: accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
