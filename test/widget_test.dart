import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/core/theme/app_typography.dart';

void main() {
  testWidgets('App typography renders with dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) => Text(
            'TurnWise',
            style: AppTypography.headline(context),
          ),
        ),
      ),
    );

    expect(find.text('TurnWise'), findsOneWidget);
  });
}
