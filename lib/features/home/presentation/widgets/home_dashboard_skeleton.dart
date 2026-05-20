import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/skeleton_box.dart';
import 'home_game_carousel.dart';
import 'home_section_header.dart';

class HomeDashboardSkeleton extends StatelessWidget {
  const HomeDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SkeletonBox(height: 56),
        AppSpacing.gapLg,
        const SkeletonBox(height: 120),
        AppSpacing.gapLg,
        Row(
          children: [
            const Expanded(child: SkeletonBox(height: 72)),
            const SizedBox(width: AppSpacing.md),
            const Expanded(child: SkeletonBox(height: 72)),
            const SizedBox(width: AppSpacing.md),
            const Expanded(child: SkeletonBox(height: 72)),
          ],
        ),
        AppSpacing.gapLg,
        const HomeSectionHeader(title: 'Jogos recentes'),
        AppSpacing.gapMd,
        _CarouselSkeleton(),
        AppSpacing.gapLg,
        const HomeSectionHeader(title: 'Todos os jogos'),
        AppSpacing.gapMd,
        const _CarouselSkeleton(),
        AppSpacing.gapLg,
      ],
    );
  }
}

class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: HomeGameCarousel.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, __) => const SkeletonBox(
          width: HomeGameCarousel.cardWidth,
          height: HomeGameCarousel.height,
        ),
      ),
    );
  }
}
