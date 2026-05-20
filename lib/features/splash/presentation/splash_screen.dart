import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/domain/auth_repository.dart';
import '../../auth/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _fadeDuration = Duration(milliseconds: 800);
  static const _loaderFallback = Duration(milliseconds: 1500);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _animationDone = false;
  bool _navigated = false;
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _fadeDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().whenComplete(() {
      _animationDone = true;
      _tryNavigate();
    });

    Future.delayed(_loaderFallback, () {
      if (!mounted || _navigated) return;
      setState(() => _showLoader = true);
    });
  }

  void _tryNavigate() {
    if (_navigated || !_animationDone || !mounted) return;

    final authState = ref.read(authStateProvider);
    if (authState.isLoading) return;

    _navigated = true;
    if (authState.value != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthUser?>>(authStateProvider, (previous, next) {
      if (!next.isLoading) {
        _tryNavigate();
      }
    });

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.change_history_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              AppSpacing.gapLg,
              Text(
                'TurnWise',
                style: AppTypography.headline(context).copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              AppSpacing.gapXl,
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _showLoader ? 1.0 : 0.0,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
