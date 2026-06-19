import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/board_target.dart';
import 'package:turnwise_tcg/features/match/domain/match_board_state.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_board_panel.dart';

void main() {
  testWidgets('MatchBoardPanel shows collapsed summary before expanding',
      (tester) async {
    MatchBoardState board = MatchBoardState(
      targets: const [
        BoardTarget(id: 'slot_0', label: 'Ativo'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: MatchBoardPanel(
            gameId: 'pokemon',
            board: board,
            onChanged: (next) => board = next,
            showIntroHint: true,
          ),
        ),
      ),
    );

    expect(find.text('Tabuleiro'), findsOneWidget);
    expect(
      find.text('Ativo · nenhum estado marcado'),
      findsOneWidget,
    );
    expect(
      find.text('Marca aqui o que está no tabuleiro físico — toca para expandir.'),
      findsOneWidget,
    );
    expect(find.text('Ativo'), findsNothing);

    await tester.tap(find.text('Tabuleiro'));
    await tester.pumpAndSettle();

    expect(find.text('Ativo'), findsOneWidget);
    expect(find.text('Entrou em jogo neste turno'), findsOneWidget);
  });

  testWidgets('MatchBoardPanel toggles target flags when expanded',
      (tester) async {
    MatchBoardState board = MatchBoardState(
      targets: const [
        BoardTarget(id: 'slot_0', label: 'Ativo'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: MatchBoardPanel(
            gameId: 'pokemon',
            board: board,
            onChanged: (next) => board = next,
            initialExpanded: true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Entrou em jogo neste turno'));
    await tester.pumpAndSettle();

    expect(board.targets.first.enteredThisTurn, isTrue);
  });

  testWidgets('MatchBoardPanel shows undo when canUndo is true', (tester) async {
    var undoCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: MatchBoardPanel(
            gameId: 'pokemon',
            board: MatchBoardState(
              targets: const [BoardTarget(id: 'slot_0', label: 'Ativo')],
            ),
            onChanged: (_) {},
            initialExpanded: true,
            canUndo: true,
            onUndo: () => undoCount++,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.undo_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.undo_rounded));
    await tester.pumpAndSettle();

    expect(undoCount, 1);
  });

  testWidgets('MatchBoardPanel offers undo snackbar after removing a slot',
      (tester) async {
    var undoCount = 0;
  MatchBoardState board = MatchBoardState(
      targets: const [
        BoardTarget(id: 'slot_0', label: 'Ativo'),
        BoardTarget(id: 'slot_1', label: 'Banco'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: MatchBoardPanel(
            gameId: 'pokemon',
            board: board,
            onChanged: (next) => board = next,
            initialExpanded: true,
            onUndo: () => undoCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Banco removido'), findsOneWidget);
    expect(find.text('Desfazer'), findsOneWidget);
    expect(board.targets, hasLength(1));

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();

    expect(undoCount, 1);
  });

  testWidgets('MatchBoardPanel persists expansion callback', (tester) async {
    var expanded = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: MatchBoardPanel(
            gameId: 'pokemon',
            board: MatchBoardState(
              targets: const [BoardTarget(id: 'slot_0', label: 'Ativo')],
            ),
            onChanged: (_) {},
            onExpandedChanged: (value) => expanded = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tabuleiro'));
    await tester.pumpAndSettle();

    expect(expanded, isTrue);
  });
}
