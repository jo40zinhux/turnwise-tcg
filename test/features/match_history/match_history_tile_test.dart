import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_semantic_colors.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_record.dart';
import 'package:turnwise_tcg/features/match_history/domain/sync_status.dart';
import 'package:turnwise_tcg/features/match_history/presentation/widgets/match_history_tile.dart';

MatchRecord _record(MatchOutcome outcome) {
  final now = DateTime(2026, 5, 19, 20, 0);
  return MatchRecord(
    id: 'r-1',
    gameId: 'pokemon',
    startedAt: now.subtract(const Duration(minutes: 30)),
    endedAt: now,
    outcome: outcome,
    syncStatus: SyncStatus.pending,
    updatedAt: now,
  );
}

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  group('MatchHistoryTile outcome chip', () {
    testWidgets('win uses success semantic foreground', (tester) async {
      await tester.pumpWidget(_wrap(MatchHistoryTile(
        gameName: 'Pokémon TCG',
        record: _record(MatchOutcome.playerWin),
      )));

      final text = tester.widget<Text>(find.text('Vitória'));
      expect(text.style?.color, AppSemanticTheme.dark.success);
    });

    testWidgets('loss uses danger semantic foreground', (tester) async {
      await tester.pumpWidget(_wrap(MatchHistoryTile(
        gameName: 'Pokémon TCG',
        record: _record(MatchOutcome.playerLoss),
      )));

      final text = tester.widget<Text>(find.text('Derrota'));
      expect(text.style?.color, AppSemanticTheme.dark.danger);
    });

    testWidgets('draw uses info semantic foreground', (tester) async {
      await tester.pumpWidget(_wrap(MatchHistoryTile(
        gameName: 'Pokémon TCG',
        record: _record(MatchOutcome.draw),
      )));

      final text = tester.widget<Text>(find.text('Empate'));
      expect(text.style?.color, AppSemanticTheme.dark.info);
    });

    testWidgets('abandoned uses warning semantic foreground', (tester) async {
      await tester.pumpWidget(_wrap(MatchHistoryTile(
        gameName: 'Pokémon TCG',
        record: _record(MatchOutcome.abandoned),
      )));

      final text = tester.widget<Text>(find.text('Abandonada'));
      expect(text.style?.color, AppSemanticTheme.dark.warning);
    });
  });
}
