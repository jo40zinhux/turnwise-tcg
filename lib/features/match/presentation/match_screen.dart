import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/observability/app_analytics_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/error_state_view.dart';
import '../../../shared/widgets/list_screen_skeleton.dart';
import '../../../shared/widgets/skeleton_box.dart';
import '../../match_history/domain/complete_match_params.dart';
import '../../match_history/domain/match_summary_args.dart';
import '../../match_history/presentation/providers/match_history_providers.dart';
import '../../timer/domain/timer_profile.dart';
import '../../timer/presentation/providers/match_timer_providers.dart';
import '../../timer/presentation/widgets/timer_profile_picker_sheet.dart';
import '../domain/game_rules.dart';
import 'providers/match_providers.dart';
import 'providers/match_session_providers.dart';
import 'widgets/complete_match_dialog.dart';
import 'widgets/match_body.dart';
import 'widgets/match_setup_sheet.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final String gameId;

  const MatchScreen({super.key, required this.gameId});

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  bool _loggedMatchStart = false;
  bool _pickerShown = false;
  bool _setupShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logMatchStarted();
      _ensureTimerProfile();
    });
  }

  Future<void> _ensureMatchSetup(GameRules rules) async {
    if (_setupShown || !mounted) return;
    final wentFirst =
        ref.read(matchStateProvider(widget.gameId)).effectsState.playerWentFirst;
    if (wentFirst != null) return;

    _setupShown = true;
    final setup = await showMatchSetupSheet(
      context,
      gameId: widget.gameId,
    );
    if (!mounted) return;

    if (setup == null) {
      context.goNamed('home');
      return;
    }

    final notifier = ref.read(matchStateProvider(widget.gameId).notifier);
    notifier.setPlayerWentFirst(setup.playerWentFirst);
    if (setup.initialLife != null) {
      notifier.setInitialLife(setup.initialLife!);
    }
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
            onSelected: (action) async {
              switch (action) {
                case _MatchMenuAction.endMatch:
                  _confirmEndMatch(context);
                case _MatchMenuAction.editSetup:
                  final rules =
                      ref.read(gameRulesProvider(widget.gameId)).valueOrNull;
                  if (rules == null || !context.mounted) return;
                  final setup = await showMatchSetupSheet(
                    context,
                    gameId: widget.gameId,
                    mode: MatchSetupMode.edit,
                  );
                  if (setup == null || !context.mounted) return;
                  ref
                      .read(matchStateProvider(widget.gameId).notifier)
                      .setPlayerWentFirst(setup.playerWentFirst);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: _MatchMenuAction.editSetup,
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded, size: 20),
                    SizedBox(width: AppSpacing.md),
                    Text('Quem joga primeiro'),
                  ],
                ),
              ),
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
          data: (rules) => MatchBody(
            gameId: widget.gameId,
            rules: rules,
            onRequestSetup: () => _ensureMatchSetup(rules),
          ),
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
    final matchState = ref.read(matchStateProvider(widget.gameId));
    final life = matchState.effectsState.life;

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
        lifePlayer: life.player.isNotEmpty ? life.player : null,
        lifeOpponent: life.opponent.isNotEmpty ? life.opponent : null,
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

enum _MatchMenuAction { editSetup, endMatch }
