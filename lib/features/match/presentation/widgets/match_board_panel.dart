import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/board_game_config.dart';
import '../../domain/board_metadata.dart';
import '../../domain/board_target.dart';
import '../../domain/match_board_state.dart';

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
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final spec in specs)
          FilterChip(
            label: Text(
              spec.label,
              style: AppTypography.caption(context),
            ),
            selected: spec.isActiveOn(target),
            onSelected: (_) {
              HapticFeedback.selectionClick();
              onChanged(spec.flag.toggle(target));
            },
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            showCheckmark: false,
          ),
      ],
    );
  }
}

/// Compact in-match board tracker with per-slot flag toggles.
class MatchBoardPanel extends StatefulWidget {
  final String gameId;
  final BoardMetadata boardMetadata;
  final MatchBoardState board;
  final ValueChanged<MatchBoardState> onChanged;

  const MatchBoardPanel({
    super.key,
    required this.gameId,
    this.boardMetadata = const BoardMetadata(),
    required this.board,
    required this.onChanged,
  });

  @override
  State<MatchBoardPanel> createState() => _MatchBoardPanelState();
}

class _MatchBoardPanelState extends State<MatchBoardPanel> {
  bool _expanded = true;

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

    final specs = BoardGameConfig.resolveFlagSpecs(
      widget.gameId,
      widget.boardMetadata,
    );
    final emptyHint = BoardGameConfig.resolveEmptyFlagsHint(
      widget.gameId,
      widget.boardMetadata,
    );
    final canAdd = widget.board.targets.length < BoardGameConfig.maxTargets;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.5),
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: AppRadius.smAll,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tabuleiro',
                      style: AppTypography.label(context),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.55),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            if (emptyHint != null) ...[
              AppSpacing.gapSm,
              Text(
                emptyHint,
                style: AppTypography.caption(context).copyWith(height: 1.35),
              ),
            ],
            AppSpacing.gapSm,
            for (final target in widget.board.targets) ...[
              _TargetRow(
                specs: specs,
                target: target,
                canRemove:
                    widget.board.targets.length > BoardGameConfig.minTargets,
                onChanged: _updateTarget,
                onRemove: () => _removeTarget(target.id),
              ),
              AppSpacing.gapSm,
            ],
            Row(
              children: [
                if (canAdd)
                  TextButton.icon(
                    onPressed: _addSlot,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Adicionar slot'),
                  ),
              ],
            ),
          ],
        ],
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
    final hasActiveFlag = specs.any((spec) => spec.isActiveOn(target));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.45),
        borderRadius: AppRadius.smAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasActiveFlag
                    ? Icons.layers_rounded
                    : Icons.layers_outlined,
                size: 16,
                color: hasActiveFlag
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.45),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(target.label, style: AppTypography.label(context)),
              ),
              if (canRemove)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.45),
                  ),
                ),
            ],
          ),
          BoardTargetFlagChips(
            specs: specs,
            target: target,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
