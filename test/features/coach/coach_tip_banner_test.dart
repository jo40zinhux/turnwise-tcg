import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/coach/presentation/widgets/coach_tip_banner.dart';

void main() {
  testWidgets('CoachTipBanner renders message and dismisses', (tester) async {
    var dismissed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CoachTipBanner(
            message: 'Dica de teste',
            onDismiss: () => dismissed = true,
          ),
        ),
      ),
    );

    expect(find.text('Dica de teste'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
  });
}
