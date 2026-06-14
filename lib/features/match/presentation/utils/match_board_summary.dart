import '../../domain/board_game_config.dart';
import '../../domain/board_target.dart';
import '../../domain/match_board_state.dart';

/// One-line collapsed summary for [MatchBoardPanel].
String buildMatchBoardCollapsedSummary({
  required MatchBoardState board,
  required List<BoardFlagSpec> specs,
}) {
  if (board.targets.isEmpty) return '';

  final slotLabels = board.targets.map((t) => t.label).toList(growable: false);
  final activeFlagCount = _countActiveFlags(board.targets, specs);

  if (specs.isEmpty) {
    return _formatSlotList(slotLabels);
  }

  if (activeFlagCount == 0) {
    final slots = _formatSlotList(slotLabels);
    return '$slots · nenhum estado marcado';
  }

  final highlighted = _highlightedSlots(board.targets, specs);
  final flagLabel = activeFlagCount == 1
      ? '1 estado ativo'
      : '$activeFlagCount estados ativos';

  if (highlighted.length <= 2) {
    return '${highlighted.join(' · ')} — $flagLabel';
  }

  return '${_formatSlotList(slotLabels.take(2).toList())} +${slotLabels.length - 2} — $flagLabel';
}

int _countActiveFlags(
  List<BoardTarget> targets,
  List<BoardFlagSpec> specs,
) {
  var count = 0;
  for (final target in targets) {
    for (final spec in specs) {
      if (spec.isActiveOn(target)) count++;
    }
  }
  return count;
}

List<String> _highlightedSlots(
  List<BoardTarget> targets,
  List<BoardFlagSpec> specs,
) {
  final lines = <String>[];
  for (final target in targets) {
    final activeLabels = specs
        .where((spec) => spec.isActiveOn(target))
        .map((spec) => spec.label)
        .toList();
    if (activeLabels.isEmpty) continue;

    if (activeLabels.length == 1) {
      lines.add('${target.label} (${activeLabels.first})');
    } else {
      lines.add('${target.label} (${activeLabels.join(', ')})');
    }
  }
  return lines;
}

String _formatSlotList(List<String> labels) {
  if (labels.length <= 3) return labels.join(' · ');
  return '${labels.take(2).join(' · ')} +${labels.length - 2}';
}
