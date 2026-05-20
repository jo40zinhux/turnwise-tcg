import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/match_feedback.dart';

/// Renders a [MatchFeedback] using semantic theme tokens.
///
/// Duration aligned across types (3s) to avoid the previous 5s "aggressive"
/// error toast. Error uses `dangerMuted` background + `danger` foreground so
/// it reads clearly without feeling hostile during fast play.
void showMatchFeedbackSnackBar(
  BuildContext context,
  MatchFeedback feedback,
) {
  final theme = Theme.of(context);
  final semantic = context.semantic;

  Color backgroundColor;
  Color foregroundColor;
  IconData icon;

  switch (feedback.type) {
    case MatchFeedbackType.success:
      backgroundColor = semantic.successMuted;
      foregroundColor = semantic.success;
      icon = Icons.check_circle_outline;
    case MatchFeedbackType.error:
      backgroundColor = semantic.dangerMuted;
      foregroundColor = semantic.danger;
      icon = Icons.block_rounded;
    case MatchFeedbackType.info:
      backgroundColor = theme.colorScheme.surface;
      foregroundColor = theme.colorScheme.onSurface;
      icon = Icons.info_outline;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              feedback.message,
              style: TextStyle(color: foregroundColor),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
    ),
  );
}
