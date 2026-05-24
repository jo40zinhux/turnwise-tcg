import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Shows the full manual-rule text for an action chip (long-press ℹ️).
Future<void> showMatchActionReminderSheet(
  BuildContext context, {
  required String actionName,
  required String ruleMessage,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      actionName,
                      style: AppTypography.label(ctx),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd,
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(ctx)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.55),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Text(
                  ruleMessage,
                  style: AppTypography.body(ctx).copyWith(height: 1.45),
                ),
              ),
              AppSpacing.gapSm,
              Text(
                'Confirma esta regra no tabuleiro físico antes de continuar.',
                style: AppTypography.caption(ctx),
              ),
              AppSpacing.gapMd,
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Entendi'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
