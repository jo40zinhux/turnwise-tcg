import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Sticky CTA to advance phase or end turn.
class MatchBodyPhaseButton extends StatelessWidget {
  final bool isLastPhase;
  final bool isOpponentTurn;
  final VoidCallback onPressed;

  const MatchBodyPhaseButton({
    super.key,
    required this.isLastPhase,
    required this.isOpponentTurn,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = isOpponentTurn
        ? 'Aguarda o turno do oponente'
        : (isLastPhase ? 'Terminar turno' : 'Próxima fase');

    return Material(
      elevation: 8,
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOpponentTurn) ...[
                Text(
                  'Usa "Oponente terminou" acima quando o oponente acabar o turno.',
                  style: AppTypography.caption(context),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.gapSm,
              ],
              ElevatedButton(
                onPressed: isOpponentTurn ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(
                  label,
                  style: AppTypography.button(context).copyWith(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
