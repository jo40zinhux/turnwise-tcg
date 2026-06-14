import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/board_flag_chip.dart';
import '../../domain/board_game_config.dart';
import '../../domain/board_metadata.dart';
import '../../domain/board_target.dart';
import '../../domain/match_board_state.dart';
import '../utils/match_board_summary.dart';

/// Toggle chips for a single board target's trackable flags.
class BoardTargetFlagChips extends StatelessWidget {
  final List<BoardFlagSpec> specs;
  final BoardTarget target;
  final ValueChanged<BoardTarget> onChanged;

  const BoardTargetFlagChips({
    super.key,
    required this.specs,
    required this.target,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (specs.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final spec in specs)
          BoardFlagChip(
            label: spec.label,
            isSelected: spec.isActiveOn(target),
            onPressed: () => onChanged(spec.flag.toggle(target)),
          ),
      ],
    );
  }
}

/// Compact in-match board tracker with per-slot flag toggles.
///
/// Collapsed by default with a one-line summary of slots and active states.
/// Expansion preference is persisted per game via [onExpandedChanged].
class MatchBoardPanel extends StatefulWidget {
  final String gameId;
  final BoardMetadata boardMetadata;
  final MatchBoardState board;
  final ValueChanged<MatchBoardState> onChanged;
  final bool initialExpanded;
  final ValueChanged<bool>? onExpandedChanged;
  final bool showIntroHint;
  final bool canUndo;
  final VoidCallback? onUndo;

  const MatchBoardPanel({
    super.key,
    required this.gameId,
    this.boardMetadata = const BoardMetadata(),
    required this.board,
    required this.onChanged,
    this.initialExpanded = false,
    this.onExpandedChanged,
    this.showIntroHint = false,
    this.canUndo = false,
    this.onUndo,
  });

  @override
  State<MatchBoardPanel> createState() => _MatchBoardPanelState();
}

class _MatchBoardPanelState extends State<MatchBoardPanel> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  void didUpdateWidget(MatchBoardPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameId != widget.gameId) {
      _expanded = widget.initialExpanded;
    }
  }

  void _setExpanded(bool expanded) {
    if (_expanded == expanded) return;
    setState(() => _expanded = expanded);
    widget.onExpandedChanged?.call(expanded);
  }

  void _updateTarget(BoardTarget updated) {
    widget.onChanged(widget.board.withTarget(updated));
  }

  void _removeTarget(String targetId) {
    if (widget.board.targets.length <= BoardGameConfig.minTargets) return;
    widget.onChanged(widget.board.removeTarget(targetId));
  }

  void _addSlot() {
    widget.onChanged(
      widget.board.addEmptySlot(widget.gameId, board: widget.boardMetadata),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.board.targets.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final specs = BoardGameConfig.resolveFlagSpecs(
      widget.gameId,
      widget.boardMetadata,
    );
    final emptyHint = BoardGameConfig.resolveEmptyFlagsHint(
      widget.gameId,
      widget.boardMetadata,
    );
    final canAdd = widget.board.targets.length < BoardGameConfig.maxTargets;
    final collapsedSummary = buildMatchBoardCollapsedSummary(
      board: widget.board,
      specs: specs,
    );
    final expandLabel =
        _expanded ? 'Recolher tabuleiro' : 'Expandir tabuleiro';

    return Semantics(
      container: true,
      expanded: _expanded,
      label: _expanded
          ? 'Tabuleiro expandido'
          : 'Tabuleiro recolhido. $collapsedSummary',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
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
            Semantics(
              button: true,
              label: expandLabel,
              child: InkWell(
                borderRadius: AppRadius.smAll,
                onTap: () => _setExpanded(!_expanded),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tabuleiro',
                                style: AppTypography.label(context),
                              ),
                              if (!_expanded &&
                                  collapsedSummary.isNotEmpty) ...[
                                AppSpacing.gapXs,
                                Text(
                                  collapsedSummary,
                                  style: AppTypography.bodyMuted(context)
                                      .copyWith(height: 1.35),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (_expanded && widget.canUndo && widget.onUndo != null)
                          Tooltip(
                            message: 'Desfazer última alteração',
                            child: Semantics(
                              button: true,
                              label: 'Desfazer última alteração no tabuleiro',
                              child: IconButton(
                                onPressed: widget.onUndo,
                                iconSize: 18,
                                constraints: const BoxConstraints(
                                  minWidth: 44,
                                  minHeight: 44,
                                ),
                                icon: Icon(
                                  Icons.undo_rounded,
                                  color: AppTheme.onSurfaceMuted,
                                ),
                              ),
                            ),
                          ),
                        Icon(
                          _expanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 20,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!_expanded && widget.showIntroHint) ...[
              AppSpacing.gapXs,
              Text(
                'Marca aqui o que está no tabuleiro físico — toca para expandir.',
                style: AppTypography.caption(context).copyWith(
                  color: theme.colorScheme.primary,
                  height: 1.35,
                ),
              ),
            ],
            if (_expanded) ...[
              if (emptyHint != null) ...[
                AppSpacing.gapSm,
                Text(
                  emptyHint,
                  style: AppTypography.caption(context).copyWith(height: 1.35),
                ),
              ],
              AppSpacing.gapSm,
              for (var i = 0; i < widget.board.targets.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.dividerTheme.color,
                  ),
                _TargetRow(
                  specs: specs,
                  target: widget.board.targets[i],
                  canRemove:
                      widget.board.targets.length > BoardGameConfig.minTargets,
                  onChanged: _updateTarget,
                  onRemove: () => _removeTarget(widget.board.targets[i].id),
                ),
              ],
              if (canAdd) ...[
                AppSpacing.gapSm,
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addSlot,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Adicionar alvo'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final BoardTarget target;
  final List<BoardFlagSpec> specs;
  final bool canRemove;
  final ValueChanged<BoardTarget> onChanged;
  final VoidCallback onRemove;

  const _TargetRow({
    required this.target,
    required this.specs,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFlag = specs.any((spec) => spec.isActiveOn(target));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                hasActiveFlag ? Icons.layers_rounded : Icons.layers_outlined,
                size: 16,
                color: hasActiveFlag
                    ? theme.colorScheme.primary
                    : AppTheme.onSurfaceMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(target.label, style: AppTypography.label(context)),
              ),
              if (canRemove)
                Tooltip(
                  message: 'Remover ${target.label}',
                  child: Semantics(
                    button: true,
                    label: 'Remover ${target.label}',
                    child: IconButton(
                      onPressed: onRemove,
                      iconSize: 18,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppTheme.onSurfaceMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (specs.isNotEmpty) ...[
            AppSpacing.gapSm,
            BoardTargetFlagChips(
              specs: specs,
              target: target,
              onChanged: onChanged,
            ),
          ],
        ],
      ),
    );
  }
}
