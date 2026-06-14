import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/action_rule.dart';
import '../../domain/board_game_config.dart';
import '../../domain/board_metadata.dart';
import '../../domain/board_target.dart';
import '../../domain/match_board_state.dart';
import 'match_board_panel.dart';

/// Result of picking a board target for an action.
class MatchTargetSelection {
  final String targetId;
  final MatchBoardState board;

  const MatchTargetSelection({
    required this.targetId,
    required this.board,
  });
}

/// Lets the player pick a slot and adjust per-target flags before an action.
Future<MatchTargetSelection?> showMatchTargetPickerSheet(
  BuildContext context, {
  required String gameId,
  BoardMetadata boardMetadata = const BoardMetadata(),
  required ActionRule action,
  required MatchBoardState board,
}) {
  return showModalBottomSheet<MatchTargetSelection>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _MatchTargetPickerSheet(
      gameId: gameId,
      boardMetadata: boardMetadata,
      action: action,
      board: board,
    ),
  );
}

class _MatchTargetPickerSheet extends StatefulWidget {
  final String gameId;
  final BoardMetadata boardMetadata;
  final ActionRule action;
  final MatchBoardState board;

  const _MatchTargetPickerSheet({
    required this.gameId,
    this.boardMetadata = const BoardMetadata(),
    required this.action,
    required this.board,
  });

  @override
  State<_MatchTargetPickerSheet> createState() =>
      _MatchTargetPickerSheetState();
}

class _MatchTargetPickerSheetState extends State<_MatchTargetPickerSheet> {
  late MatchBoardState _board;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _board = widget.board;
    if (_board.targets.isNotEmpty) {
      _selectedId = _board.targets.first.id;
    }
  }

  void _updateTarget(BoardTarget updated) {
    setState(() => _board = _board.withTarget(updated));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flagSpecs = BoardGameConfig.resolveFlagSpecs(
      widget.gameId,
      widget.boardMetadata,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Escolhe o alvo',
              style: AppTypography.headline(context),
            ),
            AppSpacing.gapXs,
            Text(
              widget.action.name,
              style: AppTypography.bodyMuted(context),
            ),
            AppSpacing.gapMd,
            if (_board.targets.isEmpty)
              Text(
                'Sem alvos no tabuleiro.',
                style: AppTypography.bodyMuted(context),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < _board.targets.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.dividerTheme.color,
                        ),
                      _TargetPickerRow(
                        target: _board.targets[i],
                        selected: _selectedId == _board.targets[i].id,
                        flagSpecs: flagSpecs,
                        onSelect: () =>
                            setState(() => _selectedId = _board.targets[i].id),
                        onTargetChanged: _updateTarget,
                      ),
                    ],
                  ],
                ),
              ),
            AppSpacing.gapMd,
            FilledButton(
              onPressed: _selectedId == null
                  ? null
                  : () {
                      Navigator.of(context).pop(
                        MatchTargetSelection(
                          targetId: _selectedId!,
                          board: _board,
                        ),
                      );
                    },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Confirmar alvo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetPickerRow extends StatelessWidget {
  final BoardTarget target;
  final bool selected;
  final List<BoardFlagSpec> flagSpecs;
  final VoidCallback onSelect;
  final ValueChanged<BoardTarget> onTargetChanged;

  const _TargetPickerRow({
    required this.target,
    required this.selected,
    required this.flagSpecs,
    required this.onSelect,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          selected: selected,
          label: target.label,
          child: InkWell(
            onTap: onSelect,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 20,
                      color: selected
                          ? theme.colorScheme.primary
                          : AppTheme.onSurfaceMuted,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        target.label,
                        style: AppTypography.label(context).copyWith(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (selected && flagSpecs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: BoardTargetFlagChips(
              specs: flagSpecs,
              target: target,
              onChanged: onTargetChanged,
            ),
          ),
      ],
    );
  }
}
