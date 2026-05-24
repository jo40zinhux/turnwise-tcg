import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Compact turn + coin-flip context below phase progress.
class MatchTurnContextBar extends StatelessWidget {
  final int turnNumber;
  final bool? playerWentFirst;
  final bool isOpponentTurn;
  final VoidCallback? onEditSetup;
  final VoidCallback? onCompleteOpponentTurn;

  const MatchTurnContextBar({
    super.key,
    required this.turnNumber,
    this.playerWentFirst,
    this.isOpponentTurn = false,
    this.onEditSetup,
    this.onCompleteOpponentTurn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wentFirstLabel = switch (playerWentFirst) {
      true => 'Você joga primeiro',
      false => 'Oponente joga primeiro',
      null => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Turno $turnNumber',
              style: AppTypography.caption(context).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (wentFirstLabel != null) ...[
              Text(
                ' · ',
                style: AppTypography.caption(context),
              ),
              Expanded(
                child: Text(
                  wentFirstLabel,
                  style: AppTypography.caption(context),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onEditSetup != null)
                TextButton(
                  onPressed: onEditSetup,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Alterar'),
                ),
            ],
          ],
        ),
        if (isOpponentTurn) ...[
          AppSpacing.gapXs,
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Turno do oponente',
                  style: AppTypography.caption(context).copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onCompleteOpponentTurn != null)
                TextButton(
                  onPressed: onCompleteOpponentTurn,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Oponente terminou'),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
