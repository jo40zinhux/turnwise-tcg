import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/feedback/haptics_player.dart';
import 'package:turnwise_tcg/core/feedback/match_feedback_service.dart';
import 'package:turnwise_tcg/core/feedback/match_feedback_service_provider.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/achievements/domain/achievement_definition.dart';
import 'package:turnwise_tcg/features/achievements/domain/achievement_metric.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_record.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_summary_args.dart';
import 'package:turnwise_tcg/features/match_history/domain/sync_status.dart';
import 'package:turnwise_tcg/features/match_history/presentation/match_summary_screen.dart';
import 'package:turnwise_tcg/features/settings/domain/feedback_preferences.dart';
import 'package:turnwise_tcg/features/timer/domain/timer_profile.dart';

class _RecordingHapticsPlayer implements HapticsPlayer {
  final List<String> events = [];

  @override
  Future<void> selection() async => events.add('selection');

  @override
  Future<void> light() async => events.add('light');

  @override
  Future<void> medium() async => events.add('medium');

  @override
  Future<void> heavy() async => events.add('heavy');
}

MatchRecord _record({
  MatchOutcome outcome = MatchOutcome.playerWin,
  String? notes,
  TimerProfile? timerProfile,
  int? roundsPlayed,
}) {
  final now = DateTime(2026, 5, 19, 20, 0);
  return MatchRecord(
    id: 'r-1',
    gameId: 'pokemon',
    startedAt: now.subtract(const Duration(minutes: 42)),
    endedAt: now,
    outcome: outcome,
    notes: notes,
    timerProfile: timerProfile,
    roundsPlayed: roundsPlayed,
    syncStatus: SyncStatus.pending,
    updatedAt: now,
  );
}

const _achievement = AchievementDefinition(
  id: 'first_win',
  title: 'Primeira vitória',
  description: 'Ganha a tua primeira partida.',
  metric: AchievementMetric.winCount,
  target: 1,
  iconCode: 'emoji_events_outlined',
);

MatchFeedbackService _defaultFeedback() => MatchFeedbackService(
      haptics: _RecordingHapticsPlayer(),
      preferencesProvider: () => FeedbackPreferences.defaults,
    );

Widget _wrap({
  required MatchSummaryArgs args,
  MatchFeedbackService? feedback,
}) {
  return ProviderScope(
    overrides: [
      matchFeedbackServiceProvider.overrideWithValue(
        feedback ?? _defaultFeedback(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      home: MatchSummaryScreen(args: args),
    ),
  );
}

void main() {
  group('MatchSummaryScreen', () {
    testWidgets('shows win headline and stats', (tester) async {
      await tester.pumpWidget(_wrap(
        args: MatchSummaryArgs(
          record: _record(timerProfile: TimerProfile.bo3, roundsPlayed: 2),
          newlyUnlocked: const [],
          gameName: 'Pokémon TCG',
        ),
      ));

      expect(find.text('Vitória!'), findsOneWidget);
      expect(find.text('Pokémon TCG'), findsOneWidget);
      expect(find.text('42min'), findsOneWidget);
      expect(find.text('BO3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Ir para o início'), findsOneWidget);
      expect(find.text('Ver histórico'), findsOneWidget);
    });

    testWidgets('shows notes when present', (tester) async {
      await tester.pumpWidget(_wrap(
        args: MatchSummaryArgs(
          record: _record(notes: 'Deck muito rápido'),
          newlyUnlocked: const [],
          gameName: 'Lorcana',
        ),
      ));

      expect(find.text('Observações'), findsOneWidget);
      expect(find.text('Deck muito rápido'), findsOneWidget);
    });

    testWidgets('lists unlocked achievements', (tester) async {
      await tester.pumpWidget(_wrap(
        args: MatchSummaryArgs(
          record: _record(),
          newlyUnlocked: const [_achievement],
          gameName: 'Lorcana',
        ),
      ));

      expect(find.text('Nova conquista'), findsOneWidget);
      expect(find.text('Primeira vitória'), findsOneWidget);
    });

    testWidgets('hides play again for abandoned matches', (tester) async {
      await tester.pumpWidget(_wrap(
        args: MatchSummaryArgs(
          record: _record(outcome: MatchOutcome.abandoned),
          newlyUnlocked: const [],
          gameName: 'Magic',
        ),
      ));

      expect(find.textContaining('Nova partida'), findsNothing);
    });

    testWidgets('triggers achievement haptic once', (tester) async {
      final haptics = _RecordingHapticsPlayer();
      final feedback = MatchFeedbackService(
        haptics: haptics,
        preferencesProvider: () => FeedbackPreferences.defaults,
      );

      await tester.pumpWidget(_wrap(
        args: MatchSummaryArgs(
          record: _record(),
          newlyUnlocked: const [_achievement],
          gameName: 'Lorcana',
        ),
        feedback: feedback,
      ));
      await tester.pump();

      expect(haptics.events, ['heavy']);
    });
  });
}
