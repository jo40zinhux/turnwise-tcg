import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/action_rule.dart';
import 'package:turnwise_tcg/features/match/domain/board_target.dart';
import 'package:turnwise_tcg/features/match/domain/match_board_state.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_target_picker_sheet.dart';

void main() {
  testWidgets('MatchTargetPickerSheet selects target and confirms',
      (tester) async {
    MatchTargetSelection? picked;

    const action = ActionRule(
      id: 'attack',
      name: 'Atacar',
      allowedPhases: ['main'],
      validations: [],
      requiresTarget: true,
    );

    final board = MatchBoardState(
      targets: const [
        BoardTarget(id: 'slot_0', label: 'Ativo'),
        BoardTarget(id: 'slot_1', label: 'Banco'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                picked = await showMatchTargetPickerSheet(
                  context,
                  gameId: 'pokemon',
                  action: action,
                  board: board,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Escolhe o alvo'), findsOneWidget);
    expect(find.text('Atacar'), findsOneWidget);

    await tester.tap(find.text('Banco'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirmar alvo'));
    await tester.pumpAndSettle();

    expect(picked, isNotNull);
    expect(picked!.targetId, 'slot_1');
    expect(picked!.board.targets.length, 2);
  });
}
