import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_phase_progress.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );

void main() {
  group('MatchPhaseProgress', () {
    testWidgets('renders position label without repeating phase title',
        (tester) async {
      await tester.pumpWidget(_wrap(const MatchPhaseProgress(
        currentPhase: 1,
        totalPhases: 5,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Fase 2 de 5'), findsOneWidget);
      expect(find.text('Combate'), findsNothing);
    });

    testWidgets('progress bar value scales with phase index', (tester) async {
      await tester.pumpWidget(_wrap(const MatchPhaseProgress(
        currentPhase: 0,
        totalPhases: 4,
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
      )));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
