import 'board_metadata.dart';
import 'board_target.dart';

/// Per-game board vocabulary and which flags apply.
abstract final class BoardGameConfig {
  static const maxTargets = 6;
  static const minTargets = 1;

  static List<String> resolveSlotLabels(String gameId, BoardMetadata? board) {
    if (board != null && board.slotLabels.isNotEmpty) return board.slotLabels;
    return _fallbackSlotLabels(gameId);
  }

  static String resolveNextSlotLabel(
    String gameId,
    int index,
    BoardMetadata? board,
  ) {
    final presets = resolveSlotLabels(gameId, board);
    if (index < presets.length) return presets[index];
    return 'Alvo ${index + 1}';
  }

  static List<BoardFlagSpec> resolveFlagSpecs(
    String gameId,
    BoardMetadata? board,
  ) {
    if (board != null && board.hasFlagSpecs) return board.flagSpecs;
    return _fallbackFlagSpecs(gameId);
  }

  static String? resolveEmptyFlagsHint(String gameId, BoardMetadata? board) {
    if (board?.emptyHint != null) return board!.emptyHint;
    return _fallbackEmptyFlagsHint(gameId);
  }

  static List<String> slotLabels(String gameId) =>
      resolveSlotLabels(gameId, null);

  static String nextSlotLabel(String gameId, int index) =>
      resolveNextSlotLabel(gameId, index, null);

  static List<BoardFlagSpec> flagSpecs(String gameId) =>
      resolveFlagSpecs(gameId, null);

  static String? emptyFlagsHint(String gameId) =>
      resolveEmptyFlagsHint(gameId, null);

  static List<String> _fallbackSlotLabels(String gameId) {
    return switch (gameId) {
      'pokemon' => ['Ativo', 'Banco 1', 'Banco 2'],
      'one_piece' => ['Leader', 'Personagem 1', 'Personagem 2'],
      'yugioh' => ['Monstro 1', 'Monstro 2', 'Monstro 3'],
      'lorcana' => ['Personagem 1', 'Personagem 2', 'Personagem 3'],
      'magic' => ['Criatura 1', 'Criatura 2', 'Criatura 3'],
      'flesh_and_blood' => ['Herói', 'Equipamento'],
      'riftbound' => ['Unidade 1', 'Unidade 2', 'Unidade 3'],
      _ => ['Alvo 1', 'Alvo 2', 'Alvo 3'],
    };
  }

  static List<BoardFlagSpec> _fallbackFlagSpecs(String gameId) {
    return switch (gameId) {
      'pokemon' => const [
        BoardFlagSpec(
          flag: BoardTargetFlag.enteredThisTurn,
          label: 'Entrou em jogo neste turno',
        ),
      ],
      'one_piece' => const [
        BoardFlagSpec(
          flag: BoardTargetFlag.exerted,
          label: 'Descansado',
        ),
      ],
      'yugioh' => const [
        BoardFlagSpec(
          flag: BoardTargetFlag.attackPosition,
          label: 'Em posição de ataque',
        ),
      ],
      'lorcana' => const [
        BoardFlagSpec(
          flag: BoardTargetFlag.exerted,
          label: 'Exertado',
        ),
      ],
      'magic' => const [
        BoardFlagSpec(
          flag: BoardTargetFlag.enteredThisTurn,
          label: 'Enjoo de invocação',
        ),
      ],
      'flesh_and_blood' => const [],
      'riftbound' => const [
        BoardFlagSpec(
          flag: BoardTargetFlag.exerted,
          label: 'Exaurida',
        ),
      ],
      _ => const [],
    };
  }

  static String? _fallbackEmptyFlagsHint(String gameId) {
    return switch (gameId) {
      'flesh_and_blood' =>
        'Slots para referência. FAB usa Action Points, não estados no tabuleiro.',
      _ => null,
    };
  }
}

/// UI label + underlying flag for a specific TCG.
class BoardFlagSpec {
  final BoardTargetFlag flag;
  final String label;

  const BoardFlagSpec({
    required this.flag,
    required this.label,
  });

  bool isActiveOn(BoardTarget target) => flag.valueOf(target);
}

enum BoardTargetFlag {
  enteredThisTurn,
  exerted,
  attackPosition,
}

extension BoardTargetFlagX on BoardTargetFlag {
  bool valueOf(BoardTarget target) {
    return switch (this) {
      BoardTargetFlag.enteredThisTurn => target.enteredThisTurn,
      BoardTargetFlag.exerted => target.exerted,
      BoardTargetFlag.attackPosition => target.inAttackPosition,
    };
  }

  BoardTarget toggle(BoardTarget target) {
    return switch (this) {
      BoardTargetFlag.enteredThisTurn =>
        target.copyWith(enteredThisTurn: !target.enteredThisTurn),
      BoardTargetFlag.exerted => target.copyWith(exerted: !target.exerted),
      BoardTargetFlag.attackPosition =>
        target.copyWith(inAttackPosition: !target.inAttackPosition),
    };
  }
}
