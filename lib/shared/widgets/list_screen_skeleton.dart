import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import 'skeleton_box.dart';

class ListScreenSkeleton extends StatelessWidget {
  final int itemCount;

  const ListScreenSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: AppSpacing.screen,
      itemCount: itemCount,
      separatorBuilder: (_, __) => AppSpacing.gapMd,
      itemBuilder: (_, __) => const SkeletonBox(height: 96),
    );
  }
}
