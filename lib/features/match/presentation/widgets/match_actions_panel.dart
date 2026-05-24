import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/match_action_chip.dart';
import '../../domain/action_enforcement.dart';
import '../../domain/action_rule.dart';
import '../../domain/game_rules.dart';
import 'match_action_reminder_sheet.dart';

/// Vertical fluid grid of action chips.
///
/// Two columns on mobile, chips wrap naturally so the player always sees
/// every available action without horizontal scrolling — a deliberate UX
/// choice for competitive play (no clutter, no hidden options).
class MatchActionsPanel extends StatelessWidget {
  final GameRules? rules;
  final List<ActionRule> actions;
  final Map<String, int> actionUsageCount;
  final int? Function(ActionRule action) maxUsageForAction;
  final bool Function(String actionId)? isActionLocked;
  final ValueChanged<String> onActionPressed;
  final ValueChanged<String> onActionRevert;
  final VoidCallback? onActionUnavailable;

  const MatchActionsPanel({
    super.key,
    this.rules,
    required this.actions,
    required this.actionUsageCount,
    required this.maxUsageForAction,
    this.isActionLocked,
    required this.onActionPressed,
    required this.onActionRevert,
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
                child: _buildChip(context, action),
              ),
          ],
        );
      },
    );
  }

  Widget _buildChip(BuildContext context, ActionRule action) {
    final maxAllowed = maxUsageForAction(action);
    final currentUsage = actionUsageCount[action.id] ?? 0;
    final isUsed = currentUsage > 0;
    final isExhausted = maxAllowed != null && currentUsage >= maxAllowed;
    final locked = isActionLocked?.call(action.id) ?? false;
    final canUndoOnTap = isUsed && maxAllowed == 1 && !locked;
    final canUndoOnLongPress =
        isUsed && !locked && (maxAllowed == null || maxAllowed > 1);
    final enforcement =
        rules != null ? ActionEnforcement.analyze(rules!, action) : null;
    final showReminder = enforcement?.showsReminderBadge ?? false;
    final reminderMessage = enforcement?.primaryReminderMessage;

    VoidCallback? longPressHandler;
    if (canUndoOnLongPress) {
      longPressHandler = () => onActionRevert(action.id);
    } else if (showReminder && reminderMessage != null) {
      longPressHandler = () {
        showMatchActionReminderSheet(
          context,
          actionName: action.name,
          ruleMessage: reminderMessage,
        );
      };
    }

    return MatchActionChip(
      label: action.name,
      isUsed: isUsed,
      isExhausted: isExhausted || locked,
      canUndoOnTap: canUndoOnTap,
      showReminderBadge: showReminder,
      onPressed: () {
        if (canUndoOnTap) {
          onActionRevert(action.id);
        } else {
          onActionPressed(action.id);
        }
      },
      onLongPress: longPressHandler,
      onExhaustedTap: onActionUnavailable,
      expand: true,
    );
  }
}
