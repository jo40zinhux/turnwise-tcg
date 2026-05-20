import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/complete_match_dialog.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';

void main() {
  group('showCompleteMatchDialog', () {
    testWidgets('lists every MatchOutcome as a tappable card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => showCompleteMatchDialog(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Vitória'), findsOneWidget);
      expect(find.text('Derrota'), findsOneWidget);
      expect(find.text('Empate'), findsOneWidget);
      expect(find.text('Abandonada'), findsOneWidget);

      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
      expect(find.byIcon(Icons.handshake_outlined), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app_rounded), findsOneWidget);
    });

    testWidgets('returns CompleteMatchResult with the selected outcome', (tester) async {
      CompleteMatchResult? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showCompleteMatchDialog(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Derrota'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Guardar e encerrar'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.outcome, MatchOutcome.playerLoss);
    });

    testWidgets('cancel returns null', (tester) async {
      CompleteMatchResult? result;
      var resolved = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  result = await showCompleteMatchDialog(context);
                  resolved = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(resolved, true);
      expect(result, isNull);
    });
  });
}
