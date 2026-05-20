import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'home_section_header.dart';

class HomeDashboardShortcut {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeDashboardShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// Horizontal row of tappable shortcuts for secondary navigation (history, etc.).
class HomeDashboardShortcuts extends StatelessWidget {
  final List<HomeDashboardShortcut> shortcuts;

  const HomeDashboardShortcuts({super.key, required this.shortcuts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HomeSectionHeader(title: 'Explorar'),
        AppSpacing.gapMd,
        Row(
          children: [
            for (var i = 0; i < shortcuts.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: _ShortcutTile(shortcut: shortcuts[i])),
            ],
          ],
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final HomeDashboardShortcut shortcut;

  const _ShortcutTile({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: shortcut.onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                shortcut.icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              AppSpacing.gapXs,
              Text(
                shortcut.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
