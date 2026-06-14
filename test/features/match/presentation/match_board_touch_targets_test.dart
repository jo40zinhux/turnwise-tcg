import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/board_target.dart';
import 'package:turnwise_tcg/features/match/domain/match_board_state.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_board_panel.dart';
import 'package:turnwise_tcg/shared/widgets/board_flag_chip.dart';

void main() {
  group('MatchBoardPanel touch targets', () {
    testWidgets('flag chips and controls meet 44pt minimum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MatchBoardPanel(
              gameId: 'pokemon',
              board: MatchBoardState(
                targets: const [
                  BoardTarget(id: 'slot_0', label: 'Ativo'),
                  BoardTarget(id: 'slot_1', label: 'Banco 1'),
                ],
              ),
              onChanged: (_) {},
              initialExpanded: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final chip = tester.getRect(find.byType(BoardFlagChip).first);
      final removeBtn = tester.getRect(find.byType(IconButton).first);
      final headerTap = tester.getRect(find.byType(InkWell).first);

      expect(chip.height, greaterThanOrEqualTo(44));
      expect(removeBtn.height, greaterThanOrEqualTo(44));
      expect(removeBtn.width, greaterThanOrEqualTo(44));
      expect(headerTap.height, greaterThanOrEqualTo(44));
    });
  });
}
