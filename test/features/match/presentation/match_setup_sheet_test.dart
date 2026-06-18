import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/match/domain/match_setup_result.dart';
import 'package:turnwise_tcg/features/match/presentation/providers/match_providers.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_setup_sheet.dart';

import '../support/rules_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Widget> buildSheet(
    WidgetTester tester, {
    required String gameId,
    required MatchSetupMode mode,
    required void Function(MatchSetupResult?) onResult,
  }) async {
    final rules = await RulesTestHarness.loadRules(gameId);
    return ProviderScope(
      overrides: [
        gameRulesProvider(gameId).overrideWith((ref) async => rules),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  onResult(
                    await showMatchSetupSheet(
                      context,
                      gameId: gameId,
                      mode: mode,
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Opens the sheet and pumps enough for the open animation to finish.
  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  // Taps a choice card and pumps enough for the close animation to finish.
  Future<void> tapChoice(WidgetTester tester, String title) async {
    await tester.tap(find.text(title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('initial mode: shows title, hint and returns initialLife',
      (tester) async {
    MatchSetupResult? result;
    await tester.pumpWidget(await buildSheet(
      tester,
      gameId: 'pokemon',
      mode: MatchSetupMode.initial,
      onResult: (r) => result = r,
    ));

    await openSheet(tester);

    expect(find.text('Preparar partida'), findsOneWidget);
    expect(find.text('Quem joga primeiro?'), findsOneWidget);
    expect(find.textContaining('Apoiador'), findsOneWidget);

    await tapChoice(tester, 'Eu jogo primeiro');

    expect(result?.playerWentFirst, isTrue);
    // Pokemon has life counters — initialLife must be populated on initial mode.
    expect(result?.initialLife, isNotNull);
    expect(find.text('Quem joga primeiro?'), findsNothing);
  });

  testWidgets(
      'initial mode with presets: shows life preset section for games that have them',
      (tester) async {
    MatchSetupResult? result;
    // Magic has Standard (20) / Commander (40) presets.
    await tester.pumpWidget(await buildSheet(
      tester,
      gameId: 'magic',
      mode: MatchSetupMode.initial,
      onResult: (r) => result = r,
    ));

    await openSheet(tester);

    // Life presets must appear in initial mode.
    expect(find.text('Pontos de vida iniciais'), findsOneWidget);

    // Close the sheet to avoid polluting subsequent tests.
    await tapChoice(tester, 'Eu jogo primeiro');
    expect(result?.initialLife, isNotNull);
  });

  testWidgets(
      'edit mode: hides life presets and returns null initialLife',
      (tester) async {
    MatchSetupResult? result;
    // flesh_and_blood has Classic/Blitz startingPresets, making the
    // "presets hidden in edit mode" assertion meaningful.
    await tester.pumpWidget(await buildSheet(
      tester,
      gameId: 'flesh_and_blood',
      mode: MatchSetupMode.edit,
      onResult: (r) => result = r,
    ));

    await openSheet(tester);

    expect(find.text('Ajustar turno'), findsOneWidget);
    expect(find.text('Quem joga primeiro?'), findsOneWidget);
    // Life presets must be hidden in edit mode even when the game has them.
    expect(find.text('Pontos de vida iniciais'), findsNothing);
    // Informational note about live counters being preserved.
    expect(
      find.textContaining('placar de vida atual não é afetado'),
      findsOneWidget,
    );

    await tapChoice(tester, 'Oponente joga primeiro');

    expect(result?.playerWentFirst, isFalse);
    // Edit mode must never reset life.
    expect(result?.initialLife, isNull);
  });
}
