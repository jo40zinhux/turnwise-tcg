import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/shared/widgets/match_action_chip.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(body: Padding(padding: const EdgeInsets.all(8), child: child)),
  );
}

void main() {
  group('MatchActionChip', () {
    testWidgets('fires onPressed when idle', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(_wrap(MatchActionChip(
        label: 'Atacar',
        isUsed: false,
        isExhausted: false,
        onPressed: () => pressed++,
      )));

      await tester.tap(find.text('Atacar'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
    });

    testWidgets('fires onPressed when used but not exhausted', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(_wrap(MatchActionChip(
        label: 'Atacar',
        isUsed: true,
        isExhausted: false,
        onPressed: () => pressed++,
      )));

      await tester.tap(find.text('Atacar'));
      await tester.pumpAndSettle();

      expect(pressed, 1);
    });

    testWidgets('does NOT call onPressed when exhausted', (tester) async {
      var pressed = 0;
      var exhaustedTaps = 0;
      await tester.pumpWidget(_wrap(MatchActionChip(
        label: 'Atacar',
        isUsed: true,
        isExhausted: true,
        onPressed: () => pressed++,
        onExhaustedTap: () => exhaustedTaps++,
      )));

      await tester.tap(find.text('Atacar'));
      await tester.pumpAndSettle();

      expect(pressed, 0, reason: 'exhausted chip must not fire engine action');
      expect(exhaustedTaps, 1, reason: 'soft callback should fire instead');
    });

    testWidgets('shows lock icon when exhausted', (tester) async {
      await tester.pumpWidget(_wrap(MatchActionChip(
        label: 'Atacar',
        isUsed: true,
        isExhausted: true,
        onPressed: () {},
      )));

      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });

    testWidgets('does NOT show lock icon when not exhausted', (tester) async {
      await tester.pumpWidget(_wrap(MatchActionChip(
        label: 'Atacar',
        isUsed: true,
        isExhausted: false,
        onPressed: () {},
      )));

      expect(find.byIcon(Icons.lock_outline_rounded), findsNothing);
    });

    testWidgets('exhausted chip without onExhaustedTap does nothing on tap', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(_wrap(MatchActionChip(
        label: 'Atacar',
        isUsed: false,
        isExhausted: true,
        onPressed: () => pressed++,
      )));

      await tester.tap(find.text('Atacar'));
      await tester.pumpAndSettle();

      expect(pressed, 0);
    });

  });
}
