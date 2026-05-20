import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/async_value_body.dart';
import '../../../shared/widgets/empty_state_view.dart';
import 'providers/achievements_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(achievementProgressListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Conquistas', style: AppTypography.title(context)),
      ),
      body: SafeArea(
        child: AsyncValueBody(
          value: progressAsync,
          onRetry: () => ref.invalidate(achievementProgressListProvider),
          isEmpty: (items) => items.isEmpty,
          empty: () => const EmptyStateView(
            icon: Icons.emoji_events_outlined,
            title: 'Sem conquistas',
            message: 'As conquistas serão adicionadas em breve.',
          ),
          data: (items) {
            return ListView.separated(
              key: ValueKey(items.length),
              padding: AppSpacing.screen,
              itemCount: items.length,
              separatorBuilder: (_, __) => AppSpacing.gapMd,
              itemBuilder: (context, index) {
                final item = items[index];
                final theme = Theme.of(context);

                return Card(
                  elevation: 0,
                  color: item.isUnlocked
                      ? theme.colorScheme.primaryContainer.withOpacity(0.25)
                      : theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              getIconFromString(item.definition.iconCode),
                              color: item.isUnlocked
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.definition.title,
                                    style: AppTypography.cardTitle(context),
                                  ),
                                  Text(
                                    item.definition.description,
                                    style: AppTypography.caption(context),
                                  ),
                                ],
                              ),
                            ),
                            if (item.isUnlocked)
                              Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                              ),
                          ],
                        ),
                        AppSpacing.gapMd,
                        ClipRRect(
                          borderRadius: AppRadius.smAll,
                          child: LinearProgressIndicator(
                            value: item.progressFraction,
                            minHeight: 6,
                          ),
                        ),
                        AppSpacing.gapXs,
                        Text(
                          item.isUnlocked
                              ? 'Desbloqueada'
                              : '${item.current} / ${item.definition.target}',
                          style: AppTypography.caption(context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed('home'),
        icon: const Icon(Icons.sports_esports_outlined),
        label: const Text('Jogar'),
      ),
    );
  }
}
