import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Shared dimensions for horizontal game carousels on the home dashboard.
abstract final class HomeGameCarousel {
  static const double height = 100;

  /// Wide enough for long game names; still shows a peek of the next card (~2.1).
  static const double cardWidth = 182;

  static const double scrollFadeWidth = 28;

  static const int maxScrollNudges = 5;
  static const Duration scrollNudgeInitialDelay = Duration(seconds: 2);
  static const Duration scrollNudgeRepeatDelay = Duration(seconds: 3);
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
  final bool expandWidth;
  final VoidCallback onTap;

  const HomeGameCarouselCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.variant,
    this.expandWidth = false,
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

    final card = Card(
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
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label(context).copyWith(
                        height: 1.15,
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
                              color:
                                  isCatalog ? accent.withOpacity(0.95) : null,
                              fontWeight:
                                  isCatalog ? FontWeight.w600 : FontWeight.w400,
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
    );

    return SizedBox(
      width: expandWidth ? double.infinity : HomeGameCarousel.cardWidth,
      height: HomeGameCarousel.height,
      child: card,
    );
  }
}

/// Horizontal carousel with scroll affordances (fade edge, optional nudge).
class HomeGameCarouselStrip extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int nudgeTick;
  final VoidCallback? onNudgeCycleComplete;
  final VoidCallback? onUserScroll;

  const HomeGameCarouselStrip({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.nudgeTick = 0,
    this.onNudgeCycleComplete,
    this.onUserScroll,
  });

  @override
  State<HomeGameCarouselStrip> createState() => _HomeGameCarouselStripState();
}

class _HomeGameCarouselStripState extends State<HomeGameCarouselStrip> {
  final ScrollController _scrollController = ScrollController();
  bool _showRightFade = false;
  bool _nudgeAnimating = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateFade);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFade());
  }

  @override
  void didUpdateWidget(HomeGameCarouselStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.nudgeTick != oldWidget.nudgeTick && widget.nudgeTick > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_performScrollNudge());
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFade());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateFade);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFade() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final canScrollMore = position.maxScrollExtent > 4 &&
        position.pixels < position.maxScrollExtent - 4;
    if (canScrollMore != _showRightFade && mounted) {
      setState(() => _showRightFade = canScrollMore);
    }
  }

  void _onUserScroll() {
    widget.onUserScroll?.call();
    _updateFade();
  }

  Future<void> _performScrollNudge() async {
    if (!mounted || _nudgeAnimating) return;
    if (!_scrollController.hasClients) {
      widget.onNudgeCycleComplete?.call();
      return;
    }

    final max = _scrollController.position.maxScrollExtent;
    if (max <= 4) {
      widget.onNudgeCycleComplete?.call();
      return;
    }

    _nudgeAnimating = true;

    final nudgeOffset = (max * 0.35).clamp(48.0, 72.0);
    await _scrollController.animateTo(
      nudgeOffset,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );

    _nudgeAnimating = false;
    if (mounted) {
      widget.onNudgeCycleComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fadeColor = theme.scaffoldBackgroundColor;

    return SizedBox(
      height: HomeGameCarousel.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (_nudgeAnimating) return false;
              if (notification is ScrollUpdateNotification &&
                  notification.dragDetails != null) {
                _onUserScroll();
              }
              return false;
            },
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              itemCount: widget.itemCount,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
              itemBuilder: widget.itemBuilder,
            ),
          ),
          if (_showRightFade)
            Positioned(
              key: const Key('home_carousel_scroll_fade'),
              right: 0,
              top: 0,
              bottom: 0,
              width: HomeGameCarousel.scrollFadeWidth,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        fadeColor.withOpacity(0),
                        fadeColor.withOpacity(0.92),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
