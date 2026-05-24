import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
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
              ..._board.targets.map((target) {
                final selected = _selectedId == target.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Material(
                    color: selected
                        ? theme.colorScheme.primary.withOpacity(0.12)
                        : theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.45),
                    borderRadius: AppRadius.mdAll,
                    child: InkWell(
                      borderRadius: AppRadius.mdAll,
                      onTap: () => setState(() => _selectedId = target.id),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  selected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 18,
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  target.label,
                                  style: AppTypography.label(context),
                                ),
                              ],
                            ),
                            if (selected) ...[
                              AppSpacing.gapSm,
                              BoardTargetFlagChips(
                                specs: flagSpecs,
                                target: target,
                                onChanged: _updateTarget,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
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
              child: const Text('Confirmar alvo'),
            ),
          ],
        ),
      ),
    );
  }
}
