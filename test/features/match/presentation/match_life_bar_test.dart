import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/life_counter_config.dart';
import 'package:turnwise_tcg/features/match/domain/life_tracker_config.dart';
import 'package:turnwise_tcg/features/match/domain/match_life_state.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_life_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const config = LifeTrackerConfig(
    enabled: true,
    counters: [
      LifeCounterConfig(
        id: 'life',
        label: 'Vida',
        playerStart: 40,
        opponentStart: 40,
        min: 0,
      ),
    ],
  );

  testWidgets('shows compact values and opens adjust sheet', (tester) async {
    final life = MatchLifeState.initial(config);
    var adjusted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MatchLifeBar(
            config: config,
            life: life,
            onAdjust: ({
              required counterId,
              required isPlayer,
              required delta,
              required counter,
            }) {
              adjusted = true;
            },
          ),
        ),
      ),
    );

    expect(
      find.textContaining('Vida · Você 40 · Oponente 40'),
      findsOneWidget,
    );

    await tester.tap(find.byType(MatchLifeBar));
    await tester.pumpAndSettle();

    expect(find.text('Controle de vida'), findsOneWidget);
    expect(find.text('Valor'), findsOneWidget);

    await tester.tap(find.text('Perder 1').first);
    await tester.pump();
    expect(adjusted, isTrue);
  });
}
