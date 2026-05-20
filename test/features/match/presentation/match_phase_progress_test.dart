import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_phase_progress.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  group('MatchPhaseProgress', () {
    testWidgets('renders "Fase X de N" with the current title', (tester) async {
      await tester.pumpWidget(_wrap(const MatchPhaseProgress(
        currentPhase: 1,
        totalPhases: 5,
        currentPhaseTitle: 'Combate',
      )));
      await tester.pumpAndSettle();

      expect(find.text('Fase 2 de 5'), findsOneWidget);
      expect(find.text('Combate'), findsOneWidget);
    });

    testWidgets('progress bar value scales with phase index', (tester) async {
      await tester.pumpWidget(_wrap(const MatchPhaseProgress(
        currentPhase: 0,
        totalPhases: 4,
        currentPhaseTitle: 'Início',
      )));
      await tester.pumpAndSettle();

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, closeTo(0.25, 0.001));
    });

    testWidgets('handles totalPhases=0 without throwing', (tester) async {
      await tester.pumpWidget(_wrap(const MatchPhaseProgress(
        currentPhase: 0,
        totalPhases: 0,
        currentPhaseTitle: 'Vazio',
      )));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
