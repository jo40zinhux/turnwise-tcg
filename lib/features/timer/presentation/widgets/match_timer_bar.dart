import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/feedback/match_feedback_service_provider.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/time_format.dart';
import '../../domain/match_timer_state.dart';
import '../../domain/timer_config.dart';
import '../../domain/timer_profile.dart';
import '../../domain/timer_profile_labels.dart';
import '../providers/match_timer_providers.dart';

class MatchTimerBar extends ConsumerStatefulWidget {
  final String gameId;

  const MatchTimerBar({super.key, required this.gameId});

  @override
  ConsumerState<MatchTimerBar> createState() => _MatchTimerBarState();
}

class _MatchTimerBarState extends ConsumerState<MatchTimerBar> {
  _TimerSeverity _lastSeverity = _TimerSeverity.normal;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(matchTimerProvider(widget.gameId));
    if (timerState == null) return const SizedBox.shrink();

    final notifier = ref.read(matchTimerProvider(widget.gameId).notifier);
    final theme = Theme.of(context);
    final semantic = context.semantic;

    final severity = _classifySeverity(timerState);
    final wasNormal = _lastSeverity == _TimerSeverity.normal;
    final escalated = severity.index > _lastSeverity.index;
    _lastSeverity = severity;

    if (escalated) {
      final feedback = ref.read(matchFeedbackServiceProvider);
      switch (severity) {
        case _TimerSeverity.warning:
          if (wasNormal) feedback.timerWarning();
        case _TimerSeverity.danger:
          feedback.timerWarning();
        case _TimerSeverity.expired:
          feedback.timerExpired();
        case _TimerSeverity.normal:
          break;
      }
    }

    final timerColor = switch (severity) {
      _TimerSeverity.normal => null,
      _TimerSeverity.warning => semantic.warning,
      _TimerSeverity.danger => semantic.danger,
      _TimerSeverity.expired => semantic.danger,
    };
    final progressColor = switch (severity) {
      _TimerSeverity.normal => theme.colorScheme.primary,
      _TimerSeverity.warning => semantic.warning,
      _TimerSeverity.danger => semantic.danger,
      _TimerSeverity.expired => semantic.danger,
    };

    final progress = _progressValue(timerState);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _ProfileChip(
                  label: TimerProfileLabels.title(timerState.profile),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    TimeFormat.mmSs(timerState.displaySeconds),
                    style: AppTypography.cardTitle(context).copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: timerColor,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: timerState.isRunning ? 'Pausar' : 'Retomar',
                  onPressed: notifier.togglePause,
                  icon: Icon(
                    timerState.isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 22,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  tooltip: 'Reiniciar ronda',
                  onPressed: notifier.resetRound,
                  icon: const Icon(Icons.replay_rounded, size: 22),
                ),
              ],
            ),
            if (progress != null) ...[
              AppSpacing.gapXs,
              ClipRRect(
                borderRadius: AppRadius.smAll,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                  color: progressColor,
                ),
              ),
            ],
            if (timerState.profile == TimerProfile.bo3) ...[
              AppSpacing.gapXs,
              Row(
                children: [
                  Text(
                    'Jogo ${timerState.currentBo3Game} · '
                    '${timerState.playerGamesWon}-${timerState.opponentGamesWon}',
                    style: AppTypography.caption(context),
                  ),
                  const Spacer(),
                  if (!timerState.isBo3SeriesComplete) ...[
                    _CompactBo3Button(
                      label: '+V',
                      tooltip: 'Vitória',
                      onPressed: notifier.recordPlayerGameWin,
                    ),
                    const SizedBox(width: 6),
                    _CompactBo3Button(
                      label: '+D',
                      tooltip: 'Derrota',
                      onPressed: notifier.recordOpponentGameWin,
                    ),
                  ],
                ],
              ),
            ],
            if (timerState.isRoundExpired)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Tempo esgotado',
                  style: AppTypography.caption(context).copyWith(
                    color: semantic.danger,
                  ),
                ),
              ),
            if (timerState.isBo3SeriesComplete)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Série concluída',
                  style: AppTypography.caption(context).copyWith(
                    color: semantic.success,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _TimerSeverity _classifySeverity(MatchTimerState state) {
    if (!state.isCountdown) return _TimerSeverity.normal;
    final seconds = state.displaySeconds;
    if (seconds <= 0) return _TimerSeverity.expired;
    if (seconds <= 60) return _TimerSeverity.danger;
    if (seconds <= 300) return _TimerSeverity.warning;
    return _TimerSeverity.normal;
  }

  double? _progressValue(MatchTimerState timerState) {
    if (!timerState.isCountdown) return null;

    const total = TimerConfig.roundDurationSeconds;
    if (total <= 0) return null;

    final remaining = timerState.remainingSeconds ?? 0;
    return (remaining / total).clamp(0.0, 1.0);
  }
}

class _ProfileChip extends StatelessWidget {
  final String label;

  const _ProfileChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.15),
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: AppTypography.caption(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CompactBo3Button extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  const _CompactBo3Button({
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Internal severity ladder used to drive timer colors and haptic feedback.
enum _TimerSeverity { normal, warning, danger, expired }
