import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/feedback/match_feedback_service_provider.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_semantic_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../achievements/domain/achievement_definition.dart';
import '../../timer/domain/timer_profile_labels.dart';
import '../domain/match_outcome.dart';
import '../domain/match_outcome_labels.dart';
import '../domain/match_record.dart';
import '../domain/match_summary_args.dart';
import 'widgets/match_outcome_visual.dart';

class MatchSummaryScreen extends ConsumerStatefulWidget {
  final MatchSummaryArgs args;

  const MatchSummaryScreen({super.key, required this.args});

  @override
  ConsumerState<MatchSummaryScreen> createState() => _MatchSummaryScreenState();
}

class _MatchSummaryScreenState extends ConsumerState<MatchSummaryScreen> {
  bool _playedAchievementHaptic = false;

  MatchRecord get _record => widget.args.record;
  List<AchievementDefinition> get _achievements => widget.args.newlyUnlocked;

  @override
  void initState() {
    super.initState();
    if (_achievements.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _playedAchievementHaptic) return;
        _playedAchievementHaptic = true;
        ref.read(matchFeedbackServiceProvider).achievementUnlocked();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final visual = MatchOutcomeVisual.of(_record.outcome, semantic);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _goHome(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.xl,
              bottom: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OutcomeHero(
                  visual: visual,
                  gameName: widget.args.gameName,
                  outcomeLabel: MatchOutcomeLabels.label(_record.outcome),
                ),
                AppSpacing.gapLg,
                _StatsCard(record: _record),
                if (_record.notes != null &&
                    _record.notes!.trim().isNotEmpty) ...[
                  AppSpacing.gapMd,
                  _NotesCard(notes: _record.notes!.trim()),
                ],
                if (_achievements.isNotEmpty) ...[
                  AppSpacing.gapLg,
                  Text(
                    _achievements.length == 1
                        ? 'Nova conquista'
                        : 'Novas conquistas',
                    style: AppTypography.cardTitle(context),
                  ),
                  AppSpacing.gapMd,
                  for (final achievement in _achievements)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _AchievementTile(achievement: achievement),
                    ),
                ],
                AppSpacing.gapXl,
                _SummaryActions(
                  gameName: widget.args.gameName,
                  showPlayAgain: _record.outcome != MatchOutcome.abandoned,
                  onGoHome: () => _goHome(context),
                  onViewHistory: () => context.goNamed('history'),
                  onPlayAgain: () => _playAgain(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    context.goNamed('home');
  }

  void _playAgain(BuildContext context) {
    context.goNamed(
      'match',
      pathParameters: {'gameId': _record.gameId},
    );
  }
}

/// Primary actions at the end of the scroll — avoids overlap with content above.
class _SummaryActions extends StatelessWidget {
  final String gameName;
  final bool showPlayAgain;
  final VoidCallback onGoHome;
  final VoidCallback onViewHistory;
  final VoidCallback onPlayAgain;

  const _SummaryActions({
    required this.gameName,
    required this.showPlayAgain,
    required this.onGoHome,
    required this.onViewHistory,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.92),
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: onGoHome,
              child: const Text('Ir para o início'),
            ),
            AppSpacing.gapSm,
            OutlinedButton(
              onPressed: onViewHistory,
              child: const Text('Ver histórico'),
            ),
            if (showPlayAgain) ...[
              AppSpacing.gapXs,
              TextButton(
                onPressed: onPlayAgain,
                child: Text(
                  'Nova partida — $gameName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OutcomeHero extends StatelessWidget {
  final MatchOutcomeVisual visual;
  final String gameName;
  final String outcomeLabel;

  const _OutcomeHero({
    required this.visual,
    required this.gameName,
    required this.outcomeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: visual.mutedBackground,
            shape: BoxShape.circle,
            border: Border.all(color: visual.accent.withOpacity(0.45)),
          ),
          child: Icon(visual.icon, color: visual.accent, size: 40),
        ),
        AppSpacing.gapMd,
        Text(
          visual.headline,
          style: AppTypography.headline(context),
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapXs,
        Text(
          gameName,
          style: AppTypography.title(context),
          textAlign: TextAlign.center,
        ),
        AppSpacing.gapXs,
        Text(
          outcomeLabel,
          style: AppTypography.bodyMuted(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final MatchRecord record;

  const _StatsCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _StatRow(
              icon: Icons.timer_outlined,
              label: 'Duração',
              value: DurationFormat.short(record.duration),
            ),
            if (record.timerProfile != null) ...[
              const Divider(height: AppSpacing.lg),
              _StatRow(
                icon: Icons.sports_esports_outlined,
                label: 'Formato',
                value: TimerProfileLabels.title(record.timerProfile!),
              ),
            ],
            if (record.roundsPlayed != null && record.roundsPlayed! > 0) ...[
              const Divider(height: AppSpacing.lg),
              _StatRow(
                icon: Icons.format_list_numbered_rounded,
                label: 'Jogos disputados',
                value: '${record.roundsPlayed}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label, style: AppTypography.bodyMuted(context)),
        ),
        Text(
          value,
          style: AppTypography.label(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.25),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Observações', style: AppTypography.label(context)),
            AppSpacing.gapSm,
            Text(notes, style: AppTypography.body(context)),
          ],
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final AchievementDefinition achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: semantic.successMuted,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: semantic.success.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: semantic.success.withOpacity(0.18),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              getIconFromString(achievement.iconCode),
              color: semantic.success,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTypography.cardTitle(context),
                ),
                AppSpacing.gapXs,
                Text(
                  achievement.description,
                  style: AppTypography.bodyMuted(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when [MatchSummaryScreen] is opened without navigation args.
class MatchSummaryFallback extends StatelessWidget {
  const MatchSummaryFallback({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.goNamed('home');
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
