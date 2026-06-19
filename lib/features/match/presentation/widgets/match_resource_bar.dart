import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/match_resources_state.dart';

/// Manual resource tracker for games with cost validations.
class MatchResourceBar extends StatelessWidget {
  final String gameId;
  final MatchResourcesState resources;
  final ValueChanged<MatchResourcesState> onChanged;

  const MatchResourceBar({
    super.key,
    required this.gameId,
    required this.resources,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];

    if (gameId == 'one_piece') {
      rows.add(_ResourceRow(
        label: 'DON!!',
        value: resources.don,
        onDecrement: () {
          HapticFeedback.selectionClick();
          onChanged(resources.copyWith(don: (resources.don - 1).clamp(0, 99)));
        },
        onIncrement: () {
          HapticFeedback.selectionClick();
          onChanged(resources.copyWith(don: resources.don + 1));
        },
      ));
    }

    if (gameId == 'flesh_and_blood') {
      rows.add(_ResourceRow(
        label: 'Pontos de ação',
        value: resources.actionPoints,
        onDecrement: () {
          HapticFeedback.selectionClick();
          onChanged(
            resources.copyWith(
              actionPoints: (resources.actionPoints - 1).clamp(0, 99),
            ),
          );
        },
        onIncrement: () {
          HapticFeedback.selectionClick();
          onChanged(
            resources.copyWith(actionPoints: resources.actionPoints + 1),
          );
        },
      ));
    }

    if (gameId == 'riftbound') {
      rows.add(_ResourceRow(
        label: 'Energia',
        value: resources.energy,
        onDecrement: () {
          HapticFeedback.selectionClick();
          onChanged(
            resources.copyWith(
              energy: (resources.energy - 1).clamp(0, 99),
            ),
          );
        },
        onIncrement: () {
          HapticFeedback.selectionClick();
          onChanged(resources.copyWith(energy: resources.energy + 1));
        },
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Recursos', style: AppTypography.label(context)),
          AppSpacing.gapSm,
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) AppSpacing.gapSm,
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _ResourceRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: AppTypography.bodyMuted(context)),
        ),
        IconButton(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          onPressed: value > 0 ? onDecrement : null,
          tooltip: 'Diminuir $label',
          icon: const Icon(Icons.remove_circle_outline, size: 22),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTypography.cardTitle(context),
          ),
        ),
        IconButton(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          onPressed: onIncrement,
          tooltip: 'Aumentar $label',
          icon: const Icon(Icons.add_circle_outline, size: 22),
        ),
      ],
    );
  }
}
