import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/match_action_chip.dart';
import '../../domain/action_rule.dart';

/// Vertical fluid grid of action chips.
///
/// Two columns on mobile, chips wrap naturally so the player always sees
/// every available action without horizontal scrolling — a deliberate UX
/// choice for competitive play (no clutter, no hidden options).
class MatchActionsPanel extends StatelessWidget {
  final List<ActionRule> actions;
  final Map<String, int> actionUsageCount;
  final int? Function(ActionRule action) maxUsageForAction;
  final bool Function(String actionId)? isActionLocked;
  final ValueChanged<String> onActionPressed;
  final VoidCallback? onActionUnavailable;

  const MatchActionsPanel({
    super.key,
    required this.actions,
    required this.actionUsageCount,
    required this.maxUsageForAction,
    this.isActionLocked,
    required this.onActionPressed,
    this.onActionUnavailable,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 2;
        const spacing = AppSpacing.sm;
        final chipWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final action in actions)
              SizedBox(
                width: chipWidth,
                child: _buildChip(action),
              ),
          ],
        );
      },
    );
  }

  Widget _buildChip(ActionRule action) {
    final maxAllowed = maxUsageForAction(action);
    final currentUsage = actionUsageCount[action.id] ?? 0;
    final isExhausted = maxAllowed != null && currentUsage >= maxAllowed;
    final locked = isActionLocked?.call(action.id) ?? false;

    return MatchActionChip(
      label: action.name,
      isUsed: currentUsage > 0,
      isExhausted: isExhausted || locked,
      onPressed: () => onActionPressed(action.id),
      onExhaustedTap: onActionUnavailable,
      expand: true,
    );
  }
}
