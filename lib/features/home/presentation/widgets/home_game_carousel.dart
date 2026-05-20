import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Shared dimensions for horizontal game carousels on the home dashboard.
abstract final class HomeGameCarousel {
  static const double height = 92;
  static const double cardWidth = 172;
}

enum HomeGameCardVariant {
  /// Activity-focused: neutral surface, match-count style subtitle.
  recent,

  /// Catalog / discovery: accent tint, play CTA subtitle.
  catalog,
}

class HomeGameCarouselCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final HomeGameCardVariant variant;
  final VoidCallback onTap;

  const HomeGameCarouselCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.variant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCatalog = variant == HomeGameCardVariant.catalog;

    final cardColor = isCatalog
        ? Color.alphaBlend(
            accent.withOpacity(0.14),
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
          )
        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.35);

    final borderSide = isCatalog
        ? BorderSide(color: accent.withOpacity(0.5), width: 1.2)
        : BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          );

    final iconDecoration = isCatalog
        ? BoxDecoration(
            color: accent.withOpacity(0.22),
            borderRadius: AppRadius.smAll,
            border: Border.all(color: accent.withOpacity(0.55)),
          )
        : BoxDecoration(
            color: accent.withOpacity(0.2),
            borderRadius: AppRadius.smAll,
          );

    return SizedBox(
      width: HomeGameCarousel.cardWidth,
      height: HomeGameCarousel.height,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: borderSide,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: iconDecoration,
                  child: Icon(
                    icon,
                    color: accent,
                    size: isCatalog ? 24 : 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label(context).copyWith(
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(context).copyWith(
                                    color: isCatalog
                                        ? accent.withOpacity(0.95)
                                        : null,
                                    fontWeight: isCatalog
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                            ),
                          ),
                          if (isCatalog)
                            Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                              color: accent,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeGameCarouselStrip extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const HomeGameCarouselStrip({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeGameCarousel.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
