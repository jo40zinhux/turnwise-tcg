import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Single-line turn + coin-flip context; opponent turn uses the same strip.
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

  static const _actionButtonStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    ),
    minimumSize: WidgetStatePropertyAll(Size(44, 44)),
    tapTargetSize: MaterialTapTargetSize.padded,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isOpponentTurn) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.12),
          borderRadius: AppRadius.smAll,
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Turno $turnNumber · Turno do oponente',
                style: AppTypography.caption(context).copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onCompleteOpponentTurn != null)
              TextButton(
                onPressed: onCompleteOpponentTurn,
                style: _actionButtonStyle,
                child: const Text('Oponente terminou'),
              ),
          ],
        ),
      );
    }

    final wentFirstLabel = switch (playerWentFirst) {
      true => 'Você joga primeiro',
      false => 'Oponente joga primeiro',
      null => null,
    };

    return Row(
      children: [
        Text(
          'Turno $turnNumber',
          style: AppTypography.caption(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (wentFirstLabel != null) ...[
          Text(' · ', style: AppTypography.caption(context)),
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
              style: _actionButtonStyle,
              child: const Text('Alterar'),
            ),
        ],
      ],
    );
  }
}
