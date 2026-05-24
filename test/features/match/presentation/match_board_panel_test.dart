import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/match/domain/board_target.dart';
import 'package:turnwise_tcg/features/match/domain/match_board_state.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_board_panel.dart';

void main() {
  testWidgets('MatchBoardPanel toggles target flags', (tester) async {
    MatchBoardState board = MatchBoardState(
      targets: const [
        BoardTarget(id: 'slot_0', label: 'Ativo'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: MatchBoardPanel(
            gameId: 'pokemon',
            board: board,
            onChanged: (next) => board = next,
          ),
        ),
      ),
    );

    expect(find.text('Tabuleiro'), findsOneWidget);
    expect(find.text('Ativo'), findsOneWidget);

    await tester.tap(find.text('Entrou em jogo neste turno'));
    await tester.pumpAndSettle();

    expect(board.targets.first.enteredThisTurn, isTrue);
  });
}
