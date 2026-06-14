import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/board_target.dart';
import 'package:turnwise_tcg/features/match/domain/match_board_state.dart';
import 'package:turnwise_tcg/features/match/domain/match_effects_state.dart';

void main() {
  group('manual board undo', () {
    final initial = MatchBoardState(
      targets: const [
        BoardTarget(id: 'slot_0', label: 'Ativo'),
      ],
    );

    test('pushManualBoardUndo restores previous snapshot', () {
      final edited = initial.withTarget(
        initial.targets.first.copyWith(enteredThisTurn: true),
      );

      final effects = MatchEffectsState(board: edited)
          .pushManualBoardUndo(initial);

      expect(effects.board.targets.first.enteredThisTurn, isTrue);
      expect(effects.manualBoardUndoStack, hasLength(1));

      final restored = effects.popManualBoardUndo();
      expect(restored.board.contentEquals(initial), isTrue);
      expect(restored.manualBoardUndoStack, isEmpty);
    });

    test('caps undo depth', () {
      var effects = const MatchEffectsState();
      for (var i = 0; i < 12; i++) {
        effects = effects.pushManualBoardUndo(
          MatchBoardState(
            targets: [BoardTarget(id: 'slot_$i', label: 'Alvo $i')],
          ),
        );
      }

      expect(
        effects.manualBoardUndoStack.length,
        MatchEffectsState.maxManualBoardUndoDepth,
      );
    });

    test('serializes manualBoardUndoStack', () {
      final effects = MatchEffectsState(board: initial)
          .pushManualBoardUndo(initial)
          .copyWith(
            board: initial.withTarget(
              initial.targets.first.copyWith(exerted: true),
            ),
          );

      final restored = MatchEffectsState.fromJson(effects.toJson());
      expect(restored.manualBoardUndoStack, hasLength(1));
      expect(
        restored.manualBoardUndoStack.first.contentEquals(initial),
        isTrue,
      );
    });
  });
}
