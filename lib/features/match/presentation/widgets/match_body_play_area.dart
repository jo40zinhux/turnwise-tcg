import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../coach/presentation/widgets/coach_tip_banner.dart';
import '../../domain/action_rule.dart';
import '../../domain/game_rules.dart';
import '../../domain/match_coach_tips.dart';
import '../../domain/match_effects_state.dart';
import '../../domain/match_engine_state.dart';
import 'match_actions_panel.dart';
import 'match_checkup_banner.dart';
import 'match_effects_panel.dart';
import 'match_tracker_notice.dart';

/// Effects, coach banners, and phase actions.
class MatchBodyPlayArea extends StatelessWidget {
  final GameRules rules;
  final MatchEngineState engineState;
  final List<ActionRule> phaseActions;
  final Map<String, int> actionUsageCount;
  final int? Function(ActionRule action) maxUsageForAction;
  final bool Function(String actionId) isActionLocked;
  final void Function(String actionId) onActionPressed;
  final void Function(String actionId) onActionRevert;
  final VoidCallback onActionUnavailable;
  final void Function(String effectDefinitionId) onApplyEffect;
  final void Function(String instanceId) onRemoveEffect;
  final void Function(String checkupId) onDismissCheckup;
  final bool showTrackerNotice;
  final VoidCallback onDismissTrackerNotice;
  final MatchCoachTip? contextualCoachTip;
  final VoidCallback onDismissContextualCoachTip;
  final bool showActionUndoCoach;
  final VoidCallback onDismissActionUndoCoach;

  const MatchBodyPlayArea({
    super.key,
    required this.rules,
    required this.engineState,
    required this.phaseActions,
    required this.actionUsageCount,
    required this.maxUsageForAction,
    required this.isActionLocked,
    required this.onActionPressed,
    required this.onActionRevert,
    required this.onActionUnavailable,
    required this.onApplyEffect,
    required this.onRemoveEffect,
    required this.onDismissCheckup,
    required this.showTrackerNotice,
    required this.onDismissTrackerNotice,
    required this.contextualCoachTip,
    required this.onDismissContextualCoachTip,
    required this.showActionUndoCoach,
    required this.onDismissActionUndoCoach,
  });

  MatchEffectsState get _effects => engineState.effectsState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_effects.pendingCheckups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: MatchCheckupBanner(
              reminder: _effects.pendingCheckups.first,
              onDismiss: () => onDismissCheckup(_effects.pendingCheckups.first.id),
            ),
          ),
        MatchEffectsPanel(
          rules: rules,
          activeEffects: _effects.activeEffects,
          lockedActionIds: _effects.lockedActionIds,
          onApplyEffect: onApplyEffect,
          onRemoveEffect: onRemoveEffect,
        ),
        AppSpacing.gapLg,
        Text(
          'Ações',
          style: AppTypography.label(context),
        ),
        if (showTrackerNotice) ...[
          AppSpacing.gapSm,
          MatchTrackerNotice(onDismiss: onDismissTrackerNotice),
        ],
        if (contextualCoachTip != null) ...[
          AppSpacing.gapSm,
          CoachTipBanner(
            message: contextualCoachTip!.message,
            onDismiss: onDismissContextualCoachTip,
          ),
        ],
        if (showActionUndoCoach) ...[
          AppSpacing.gapSm,
          CoachTipBanner(
            message:
                'Tocaste sem querer? Toca outra vez (ou mantém premido) para desfazer.',
            onDismiss: onDismissActionUndoCoach,
          ),
        ],
        AppSpacing.gapMd,
        if (phaseActions.isEmpty)
          Text(
            'Nenhuma ação nesta fase. Avança para a próxima.',
            style: AppTypography.bodyMuted(context),
          )
        else
          MatchActionsPanel(
            rules: rules,
            actions: phaseActions,
            actionUsageCount: actionUsageCount,
            maxUsageForAction: maxUsageForAction,
            isActionLocked: isActionLocked,
            onActionPressed: onActionPressed,
            onActionRevert: onActionRevert,
            onActionUnavailable: onActionUnavailable,
          ),
        AppSpacing.gapMd,
      ],
    );
  }
}
