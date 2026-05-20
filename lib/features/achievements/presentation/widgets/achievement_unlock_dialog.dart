import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/feedback/match_feedback_service_provider.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../domain/achievement_definition.dart';

Future<void> showAchievementUnlockDialog(
  BuildContext context,
  List<AchievementDefinition> achievements,
) async {
  if (achievements.isEmpty) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => _UnlockDialog(achievements: achievements),
  );
}

class _UnlockDialog extends ConsumerStatefulWidget {
  final List<AchievementDefinition> achievements;

  const _UnlockDialog({required this.achievements});

  @override
  ConsumerState<_UnlockDialog> createState() => _UnlockDialogState();
}

class _UnlockDialogState extends ConsumerState<_UnlockDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(matchFeedbackServiceProvider).achievementUnlocked();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMultiple = widget.achievements.length > 1;
    final title = isMultiple
        ? '${widget.achievements.length} conquistas desbloqueadas!'
        : 'Conquista desbloqueada!';

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(_scale),
        child: AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          title: Text(title, style: AppTypography.title(context)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final achievement in widget.achievements) ...[
                  _AchievementContent(achievement: achievement),
                  if (achievement != widget.achievements.last)
                    AppSpacing.gapMd,
                ],
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementContent extends StatelessWidget {
  final AchievementDefinition achievement;

  const _AchievementContent({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      decoration: BoxDecoration(
        color: semantic.successMuted,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: semantic.success.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: semantic.success.withOpacity(0.18),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              getIconFromString(achievement.iconCode),
              color: semantic.success,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title, style: AppTypography.cardTitle(context)),
                AppSpacing.gapXs,
                Text(
                  achievement.description,
                  style: AppTypography.bodyMuted(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
