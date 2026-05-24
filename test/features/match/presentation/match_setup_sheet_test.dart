import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/match/presentation/providers/match_providers.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_setup_sheet.dart';

import '../support/rules_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('match setup sheet returns went first choice', (tester) async {
    bool? result;
    final rules = await RulesTestHarness.loadRules('pokemon');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameRulesProvider('pokemon').overrideWith((ref) async => rules),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await showMatchSetupSheet(
                        context,
                        gameId: 'pokemon',
                      );
                    },
                    child: const Text('Open'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Quem joga primeiro?'), findsOneWidget);
    expect(
      find.textContaining('Apoiador'),
      findsOneWidget,
    );

    await tester.tap(find.text('Eu jogo primeiro'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(result, isTrue);
    expect(find.text('Quem joga primeiro?'), findsNothing);
  });
}
