import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/match_feedback_service_provider.dart';
import '../../../core/observability/app_analytics_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/list_screen_skeleton.dart';
import '../../../shared/widgets/phase_tile.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../domain/game_rules.dart';
import '../domain/match_feedback.dart';
import '../../match_history/domain/complete_match_params.dart';
import '../../match_history/presentation/providers/match_history_providers.dart';
import 'providers/match_providers.dart';
import 'providers/match_session_providers.dart';
import 'utils/match_feedback_snackbar.dart';
import 'widgets/complete_match_dialog.dart';
import '../../timer/domain/timer_profile.dart';
import '../../timer/presentation/providers/match_timer_providers.dart';
import '../../timer/presentation/widgets/match_timer_bar.dart';
import '../../match_history/domain/match_summary_args.dart';
import '../../timer/presentation/widgets/timer_profile_picker_sheet.dart';
import 'widgets/match_actions_panel.dart';
import 'widgets/match_checkup_banner.dart';
import 'widgets/match_effects_panel.dart';
import 'widgets/match_phase_progress.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final String gameId;

  const MatchScreen({super.key, required this.gameId});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  bool _loggedMatchStart = false;
  bool _pickerShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logMatchStarted();
      _ensureTimerProfile();
    });
  }

  Future<void> _ensureTimerProfile() async {
    if (_pickerShown || !mounted) return;

    final session = ref.read(activeMatchSessionProvider);
    final timerState = ref.read(matchTimerProvider(widget.gameId));
    final hasProfile = session?.gameId == widget.gameId &&
        session?.timerProfile != null &&
        timerState != null;

    if (hasProfile) return;

    _pickerShown = true;
    final profile = await showTimerProfilePickerSheet(context);
    if (!mounted) return;

    if (profile == null) {
      context.goNamed('home');
      return;
    }

    ref.read(matchTimerProvider(widget.gameId).notifier).setProfile(profile);
  }

  void _logMatchStarted() {
    if (_loggedMatchStart) return;
    _loggedMatchStart = true;

    final session = ref.read(activeMatchSessionProvider);
    final isResume = session?.gameId == widget.gameId &&
        ((session?.currentPhaseIndex ?? 0) > 0 ||
            (session?.actionUsageCount.isNotEmpty ?? false));

    ref.read(appAnalyticsProvider).logMatchStarted(
          gameId: widget.gameId,
          resumed: isResume,
        );
  }

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(gameRulesProvider(widget.gameId));

    return Scaffold(
      appBar: AppBar(
        title: rulesAsync.when(
          data: (rules) => Text(rules.name),
          loading: () => const Text('A carregar...'),
          error: (_, __) => const Text('Não foi possível carregar'),
        ),
        actions: [
          PopupMenuButton<_MatchMenuAction>(
            tooltip: 'Opções da partida',
            onSelected: (action) {
              switch (action) {
                case _MatchMenuAction.endMatch:
                  _confirmEndMatch(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _MatchMenuAction.endMatch,
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 20),
                    SizedBox(width: AppSpacing.md),
                    Text('Encerrar partida'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: rulesAsync.when(
          data: (rules) => _MatchBody(gameId: widget.gameId, rules: rules),
          loading: () => const Padding(
            padding: AppSpacing.screen,
            child: Column(
              children: [
                SkeletonBox(height: 56),
                AppSpacing.gapMd,
                Expanded(child: ListScreenSkeleton(itemCount: 4)),
              ],
            ),
          ),
          error: (error, stack) => ErrorStateView(
            message: 'Não foi possível carregar as regras deste jogo.',
            retryLabel: 'Voltar ao início',
            onRetry: () => context.goNamed('home'),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmEndMatch(BuildContext context) async {
    final result = await showCompleteMatchDialog(context);
    if (result == null || !context.mounted) return;

    final session = ref.read(activeMatchSessionProvider);

    final timerState = ref.read(matchTimerProvider(widget.gameId));
    final roundsPlayed = session?.timerProfile == TimerProfile.bo3
        ? (session!.bo3PlayerWins + session.bo3OpponentWins)
        : null;

    final rules = ref.read(gameRulesProvider(widget.gameId)).valueOrNull;
    final gameName = rules?.name ?? widget.gameId;

    final finishResult = await completeAndEndActiveMatch(
      ref,
      gameId: widget.gameId,
      params: CompleteMatchParams(
        gameId: widget.gameId,
        outcome: result.outcome,
        notes: result.notes,
        startedAt: session?.startedAt,
        timerProfile: session?.timerProfile ?? timerState?.profile,
        roundsPlayed: roundsPlayed,
      ),
    );

    if (!context.mounted) return;

    context.goNamed(
      'matchSummary',
      extra: MatchSummaryArgs(
        record: finishResult.record,
        newlyUnlocked: finishResult.newlyUnlocked,
        gameName: gameName,
      ),
    );
  }
}

enum _MatchMenuAction { endMatch }

class _MatchBody extends ConsumerStatefulWidget {
  final String gameId;
  final GameRules rules;

  const _MatchBody({required this.gameId, required this.rules});

  @override
  ConsumerState<_MatchBody> createState() => _MatchBodyState();
}

class _MatchBodyState extends ConsumerState<_MatchBody> {
  final _scrollController = ScrollController();
  bool _showAllPhases = false;
  int? _lastScrolledPhaseIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(matchStateProvider(widget.gameId).notifier)
          .reconcilePhaseIndex(widget.rules.phases.length);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentPhase(int phaseIndex) {
    if (_lastScrolledPhaseIndex == phaseIndex) return;
    _lastScrolledPhaseIndex = phaseIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final targetOffset = _showAllPhases
          ? (phaseIndex * 88.0).clamp(0.0, _scrollController.position.maxScrollExtent)
          : 0.0;

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchStateProvider(widget.gameId));
    final notifier = ref.read(matchStateProvider(widget.gameId).notifier);
    final engine = ref.read(matchEngineProvider);
    final feedbackService = ref.read(matchFeedbackServiceProvider);

    ref.listen(matchStateProvider(widget.gameId), (previous, next) {
      final feedback = next.feedback;
      if (feedback != null && feedback != previous?.feedback) {
        switch (feedback.type) {
          case MatchFeedbackType.success:
            feedbackService.actionUsed();
          case MatchFeedbackType.error:
            feedbackService.actionInvalid();
          case MatchFeedbackType.info:
            break;
        }
        showMatchFeedbackSnackBar(context, feedback);
        notifier.clearFeedback();
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
    final isLastPhase = matchState.currentPhaseIndex == phases.length - 1;

    final visiblePhaseIndices = _showAllPhases
        ? List.generate(phases.length, (i) => i)
        : [currentPhaseIndex];

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MatchTimerBar(gameId: widget.gameId),
              AppSpacing.gapMd,
              MatchPhaseProgress(
                currentPhase: currentPhaseIndex,
                totalPhases: phases.length,
                currentPhaseTitle: phases[currentPhaseIndex].title,
              ),
            ],
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
                            onPressed: () =>
                                setState(() => _showAllPhases = true),
                            icon: const Icon(Icons.unfold_more_rounded, size: 18),
                            label: Text(
                              'Ver todas as fases (${phases.length})',
                              style: AppTypography.caption(context),
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
                            onPressed: () =>
                                setState(() => _showAllPhases = false),
                            icon: const Icon(Icons.unfold_less_rounded, size: 18),
                            label: Text(
                              'Mostrar só fase atual',
                              style: AppTypography.caption(context),
                            ),
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
                      key: ValueKey('phase_$index'),
                      phase: phase,
                      isCurrent: matchState.currentPhaseIndex == index,
                      isPast: matchState.currentPhaseIndex > index,
                    );
                  },
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
                      if (matchState.effectsState.pendingCheckups.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: MatchCheckupBanner(
                            reminder:
                                matchState.effectsState.pendingCheckups.first,
                            onDismiss: () => notifier.dismissCheckup(
                              matchState
                                  .effectsState.pendingCheckups.first.id,
                            ),
                          ),
                        ),
                      MatchEffectsPanel(
                        rules: widget.rules,
                        activeEffects: matchState.effectsState.activeEffects,
                        lockedActionIds:
                            matchState.effectsState.lockedActionIds,
                        onApplyEffect: notifier.applyEffect,
                        onRemoveEffect: notifier.removeActiveEffect,
                      ),
                      AppSpacing.gapLg,
                      Text(
                        'Ações disponíveis',
                        style: AppTypography.label(context),
                      ),
                      AppSpacing.gapMd,
                      MatchActionsPanel(
                        actions: widget.rules.actions,
                        actionUsageCount: matchState.actionUsageCount,
                        maxUsageForAction: (action) =>
                            engine.maxUsagePerTurn(widget.rules, action),
                        isActionLocked: notifier.isActionLocked,
                        onActionPressed: notifier.attemptAction,
                        onActionUnavailable: feedbackService.actionUnavailable,
                      ),
                      AppSpacing.gapMd,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Material(
          elevation: 8,
          color: theme.scaffoldBackgroundColor,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: AppSpacing.screen,
              child: ElevatedButton(
                onPressed: () {
                  if (isLastPhase) {
                    feedbackService.turnEnd();
                  } else {
                    feedbackService.phaseAdvance();
                  }
                  notifier.nextPhase();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  isLastPhase ? 'Terminar turno' : 'Próxima fase',
                  style: AppTypography.button(context).copyWith(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
