import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/timer_profile.dart';
import '../../domain/timer_profile_labels.dart';

Future<TimerProfile?> showTimerProfilePickerSheet(BuildContext context) {
  return showModalBottomSheet<TimerProfile>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _TimerProfilePickerSheet(),
  );
}

class _TimerProfilePickerSheet extends StatelessWidget {
  const _TimerProfilePickerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Escolhe o timer',
              style: AppTypography.headline(context),
            ),
            AppSpacing.gapSm,
            Text(
              'Podes mudar o modo em cada nova partida.',
              style: AppTypography.bodyMuted(context),
            ),
            AppSpacing.gapLg,
            ...TimerProfile.values.map((profile) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withOpacity(0.4),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: AppRadius.mdAll,
                    onTap: () => Navigator.pop(context, profile),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  TimerProfileLabels.title(profile),
                                  style: AppTypography.cardTitle(context),
                                ),
                                AppSpacing.gapXs,
                                Text(
                                  TimerProfileLabels.description(profile),
                                  style: AppTypography.caption(context),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
