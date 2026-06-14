import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/board_target.dart';
import 'package:turnwise_tcg/features/match/domain/match_board_state.dart';
import 'package:turnwise_tcg/features/match/presentation/utils/match_board_summary.dart';
import 'package:turnwise_tcg/features/match/domain/board_game_config.dart';

void main() {
  group('buildMatchBoardCollapsedSummary', () {
    test('lists slots when no flags are active', () {
      final board = MatchBoardState(
        targets: const [
          BoardTarget(id: 'a', label: 'Ativo'),
          BoardTarget(id: 'b', label: 'Banco 1'),
        ],
      );
      final specs = BoardGameConfig.flagSpecs('pokemon');

      expect(
        buildMatchBoardCollapsedSummary(board: board, specs: specs),
        'Ativo · Banco 1 · nenhum estado marcado',
      );
    });

    test('highlights active flags on slots', () {
      final board = MatchBoardState(
        targets: const [
          BoardTarget(
            id: 'a',
            label: 'Ativo',
            enteredThisTurn: true,
          ),
          BoardTarget(id: 'b', label: 'Banco 1'),
        ],
      );
      final specs = BoardGameConfig.flagSpecs('pokemon');

      expect(
        buildMatchBoardCollapsedSummary(board: board, specs: specs),
        'Ativo (Entrou em jogo neste turno) — 1 estado ativo',
      );
    });

    test('falls back to slot labels when game has no flag specs', () {
      final board = MatchBoardState(
        targets: const [
          BoardTarget(id: 'a', label: 'Herói'),
          BoardTarget(id: 'b', label: 'Equipamento'),
        ],
      );

      expect(
        buildMatchBoardCollapsedSummary(board: board, specs: const []),
        'Herói · Equipamento',
      );
    });
  });
}
