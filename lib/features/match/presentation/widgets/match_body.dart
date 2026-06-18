import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/feedback/match_feedback_service_provider.dart';
import '../../../../core/observability/app_analytics_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/list_screen_skeleton.dart';
import '../../../../shared/widgets/phase_tile.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import '../../../timer/presentation/providers/match_timer_providers.dart';
import '../../domain/action_enforcement.dart';
import '../../domain/game_rules.dart';
import '../../domain/match_action_filter.dart';
import '../../domain/match_coach_tips.dart';
import '../../domain/match_feedback.dart';
import '../providers/match_board_panel_preferences_provider.dart';
import '../providers/match_providers.dart';
import '../utils/match_feedback_snackbar.dart';
import '../../domain/game_rules_metadata.dart';
import 'match_board_panel.dart';
import 'match_body_header.dart';
import 'match_body_phase_button.dart';
import 'match_body_play_area.dart';
import 'match_resource_bar.dart';
import 'match_target_picker_sheet.dart';

/// Scrollable match play area: phases, effects, actions, phase advance CTA.
class MatchBody extends ConsumerStatefulWidget {
  final String gameId;
  final GameRules rules;
  final VoidCallback onRequestSetup;

  const MatchBody({
    super.key,
    required this.gameId,
    required this.rules,
    required this.onRequestSetup,
  });

  @override
  ConsumerState<MatchBody> createState() => _MatchBodyState();
}

class _MatchBodyState extends ConsumerState<MatchBody> {
  final _scrollController = ScrollController();
  final _phaseTileKeys = <int, GlobalKey>{};
  bool _showAllPhases = false;
  int? _lastScrolledPhaseIndex;
  bool _undoCoachDismissed = false;
  bool _trackerNoticeDismissed = false;
  final Set<String> _dismissedCoachTipIds = {};

  int _totalActionUsage(Map<String, int> usage) {
    return usage.values.fold(0, (sum, count) => sum + count);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(matchStateProvider(widget.gameId).notifier)
          .reconcilePhaseIndex(widget.rules.phases.length);
      widget.onRequestSetup();
    });
  }

  @override
  void didUpdateWidget(MatchBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameId != widget.gameId) {
      _phaseTileKeys.clear();
      _lastScrolledPhaseIndex = null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _phaseKey(int index) =>
      _phaseTileKeys.putIfAbsent(index, GlobalKey.new);

  void _scrollToCurrentPhase(int phaseIndex) {
    if (_lastScrolledPhaseIndex == phaseIndex) return;
    _lastScrolledPhaseIndex = phaseIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final phaseContext = _phaseTileKeys[phaseIndex]?.currentContext;
      if (phaseContext != null) {
        await Scrollable.ensureVisible(
          phaseContext,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: 0.05,
        );
        return;
      }

      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _handleActionPressed(String actionId) async {
    final action =
        widget.rules.actions.firstWhere((a) => a.id == actionId);

    if (!ActionEnforcement.needsTargetSelection(widget.rules, action)) {
      ref.read(matchStateProvider(widget.gameId).notifier).attemptAction(
            actionId,
          );
      return;
    }

    final matchState = ref.read(matchStateProvider(widget.gameId));
    final selection = await showMatchTargetPickerSheet(
      context,
      gameId: widget.gameId,
      boardMetadata: widget.rules.metadata.board,
      action: action,
      board: matchState.effectsState.board,
    );
    if (selection == null || !mounted) return;

    ref.read(matchStateProvider(widget.gameId).notifier).attemptAction(
          actionId,
          targetId: selection.targetId,
          board: selection.board,
        );
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchStateProvider(widget.gameId));
    final isOpponentTurn = ref.watch(
      matchStateProvider(widget.gameId)
          .select((s) => s.effectsState.isOpponentTurn),
    );
    final notifier = ref.read(matchStateProvider(widget.gameId).notifier);
    final engine = ref.read(matchEngineProvider);
    final feedbackService = ref.read(matchFeedbackServiceProvider);

    final actionUsageTotal = _totalActionUsage(matchState.actionUsageCount);
    final showActionUndoCoach =
        actionUsageTotal > 0 && !_undoCoachDismissed;

    ref.listen(matchStateProvider(widget.gameId), (previous, next) {
      final feedback = next.feedback;
      if (feedback != null && feedback != previous?.feedback) {
        switch (feedback.type) {
          case MatchFeedbackType.success:
            feedbackService.actionUsed();
          case MatchFeedbackType.error:
            feedbackService.actionInvalid();
          case MatchFeedbackType.info:
            feedbackService.actionUsed();
        }
        showMatchFeedbackSnackBar(context, feedback);
        notifier.clearFeedback();
      }

      final prevTotal =
          _totalActionUsage(previous?.actionUsageCount ?? const {});
      final nextTotal = _totalActionUsage(next.actionUsageCount);
      if (nextTotal > prevTotal && _undoCoachDismissed) {
        setState(() => _undoCoachDismissed = false);
      }
      if (nextTotal == 0 && _undoCoachDismissed) {
        setState(() => _undoCoachDismissed = false);
      }

      if (previous?.currentPhaseIndex != next.currentPhaseIndex) {
        _scrollToCurrentPhase(next.currentPhaseIndex);
      }
    });

    final timerState = ref.watch(matchTimerProvider(widget.gameId));

    if (timerState == null) {
      return const Padding(
        padding: AppSpacing.screen,
        child: Column(
          children: [
            SkeletonBox(height: 56),
            AppSpacing.gapMd,
            Expanded(child: ListScreenSkeleton(itemCount: 4)),
          ],
        ),
      );
    }

    final phases = widget.rules.phases;
    final currentPhaseIndex =
        matchState.currentPhaseIndex.clamp(0, phases.length - 1);
    final currentPhaseId = phases[currentPhaseIndex].id;
    final isLastPhase = matchState.currentPhaseIndex == phases.length - 1;
    final phaseActions = MatchActionFilter.forMatchContext(
      actions: widget.rules.actions,
      phaseId: currentPhaseId,
      isOpponentTurn: isOpponentTurn,
    );
    final contextualCoachTip = MatchCoachTips.activeTip(
      rules: widget.rules,
      state: matchState.engineState,
      dismissedTipIds: _dismissedCoachTipIds,
    );

    final visiblePhaseIndices = _showAllPhases
        ? List.generate(phases.length, (i) => i)
        : [currentPhaseIndex];
    final showResourceBar =
        GameRulesMetadata.showResourceBarFor(widget.gameId);
    final board = matchState.effectsState.board;
    final showBoardPanel = board.targets.isNotEmpty;
    final boardPrefs = ref.watch(matchBoardPanelPreferencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MatchBodyHeader(
          gameId: widget.gameId,
          currentPhaseIndex: currentPhaseIndex,
          totalPhases: phases.length,
          turnNumber: matchState.effectsState.turnNumber,
          playerWentFirst: matchState.effectsState.playerWentFirst,
          isOpponentTurn: isOpponentTurn,
          onPlayerWentFirst: notifier.setPlayerWentFirst,
          onCompleteOpponentTurn: isOpponentTurn
              ? notifier.completeOpponentTurn
              : null,
          lifeTracker: widget.rules.metadata.lifeTracker,
          effectsState: matchState.effectsState,
          onLifeAdjust: ({
            required counterId,
            required isPlayer,
            required delta,
            required counter,
          }) =>
              notifier.adjustLife(
            counterId: counterId,
            isPlayer: isPlayer,
            delta: delta,
            counter: counter,
          ),
        ),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: AppSpacing.screenHorizontal,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (!_showAllPhases && phases.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => setState(() {
                              _showAllPhases = true;
                              _lastScrolledPhaseIndex = null;
                            }),
                            icon: const Icon(Icons.unfold_more_rounded, size: 18),
                            label: Text(
                              'Ver todas as fases (${phases.length})',
                            ),
                          ),
                        ),
                      ),
                    if (_showAllPhases && phases.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => setState(() {
                              _showAllPhases = false;
                              _lastScrolledPhaseIndex = null;
                            }),
                            icon: const Icon(Icons.unfold_less_rounded, size: 18),
                            label: const Text('Mostrar só fase atual'),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
              SliverPadding(
                padding: AppSpacing.screenHorizontal,
                sliver: SliverList.separated(
                  itemCount: visiblePhaseIndices.length,
                  separatorBuilder: (context, index) => AppSpacing.gapMd,
                  itemBuilder: (context, listIndex) {
                    final index = visiblePhaseIndices[listIndex];
                    final phase = phases[index];
                    return PhaseTile(
                      key: _phaseKey(index),
                      phase: phase,
                      isCurrent: matchState.currentPhaseIndex == index,
                      isPast: matchState.currentPhaseIndex > index,
                    );
                  },
                ),
              ),
              if (showResourceBar || showBoardPanel)
                SliverPadding(
                  padding: AppSpacing.screenHorizontal,
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSpacing.gapMd,
                        if (showResourceBar)
                          MatchResourceBar(
                            gameId: widget.gameId,
                            resources: matchState.effectsState.resources,
                            onChanged: notifier.updateResources,
                          ),
                        if (showResourceBar && showBoardPanel) AppSpacing.gapSm,
                        if (showBoardPanel)
                          MatchBoardPanel(
                            key: ValueKey('board_${widget.gameId}'),
                            gameId: widget.gameId,
                            boardMetadata: widget.rules.metadata.board,
                            board: board,
                            onChanged: notifier.updateBoard,
                            canUndo: notifier.hasManualBoardUndo,
                            onUndo: notifier.revertLastBoardEdit,
                            initialExpanded:
                                boardPrefs.isExpanded(widget.gameId),
                            showIntroHint: !boardPrefs.introSeen,
                            onExpandedChanged: (expanded) async {
                              await boardPrefs.setExpanded(
                                widget.gameId,
                                expanded,
                              );
                              if (expanded) {
                                await boardPrefs.markIntroSeen();
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              SliverPadding(
                padding: AppSpacing.screenHorizontal,
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSpacing.gapLg,
                      const Divider(),
                      AppSpacing.gapMd,
                      MatchBodyPlayArea(
                        rules: widget.rules,
                        engineState: matchState.engineState,
                        phaseActions: phaseActions,
                        actionUsageCount: matchState.actionUsageCount,
                        maxUsageForAction: (action) =>
                            engine.maxUsagePerTurn(widget.rules, action),
                        isActionLocked: notifier.isActionLocked,
                        onActionPressed: _handleActionPressed,
                        onActionRevert: notifier.revertAction,
                        onActionUnavailable: feedbackService.actionUnavailable,
                        onApplyEffect: notifier.applyEffect,
                        onRemoveEffect: notifier.removeActiveEffect,
                        onDismissCheckup: notifier.dismissCheckup,
                        showTrackerNotice: !_trackerNoticeDismissed,
                        onDismissTrackerNotice: () =>
                            setState(() => _trackerNoticeDismissed = true),
                        contextualCoachTip: contextualCoachTip,
                        onDismissContextualCoachTip: () {
                          if (contextualCoachTip == null) return;
                          setState(() {
                            _dismissedCoachTipIds.add(contextualCoachTip.id);
                          });
                          ref.read(appAnalyticsProvider).logCoachTipDismissed(
                                tipId: contextualCoachTip.id,
                              );
                        },
                        showActionUndoCoach: showActionUndoCoach,
                        onDismissActionUndoCoach: () {
                          setState(() => _undoCoachDismissed = true);
                          ref.read(appAnalyticsProvider).logCoachTipDismissed(
                                tipId: 'match_action_undo',
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        MatchBodyPhaseButton(
          isLastPhase: isLastPhase,
          isOpponentTurn: isOpponentTurn,
          onPressed: () {
            if (isLastPhase) {
              feedbackService.turnEnd();
            } else {
              feedbackService.phaseAdvance();
            }
            notifier.nextPhase();
          },
        ),
      ],
    );
  }
}
