import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'headline': 'Jogue com confiança.',
      'text':
          'TurnWise é seu assistente inteligente para partidas presenciais de TCG.',
    },
    {
      'headline': 'Nunca perca uma ação importante.',
      'text':
          'Checklist de turno, controle de prêmios e lembretes inteligentes durante a partida.',
    },
    {
      'headline': 'Evolua a cada partida.',
      'text':
          'Histórico, estatísticas e conquistas para acompanhar a tua jornada.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingStateProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/home');
    }
  }

  bool get _isLastPage => _currentPage == _onboardingData.length - 1;

  void _handlePrimaryTap() {
    if (_isLastPage) {
      _completeOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text('Pular', style: AppTypography.bodyMuted(context)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSpacing.gapXl,
                        Text(
                          _onboardingData[index]['headline']!,
                          textAlign: TextAlign.center,
                          style: AppTypography.headline(context).copyWith(
                            fontSize: 28,
                          ),
                        ),
                        AppSpacing.gapLg,
                        Text(
                          _onboardingData[index]['text']!,
                          textAlign: TextAlign.center,
                          style: AppTypography.body(context).copyWith(
                            color: AppTheme.onSurfaceMuted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.xl,
                left: AppSpacing.xl,
                right: AppSpacing.xl,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        height: AppSpacing.sm,
                        width:
                            _currentPage == index ? AppSpacing.lg : AppSpacing.sm,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryColor
                              : Colors.white24,
                          borderRadius: AppRadius.smAll,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.gapXl,
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handlePrimaryTap,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _isLastPage ? 'Começar' : 'Seguinte',
                          key: ValueKey(_isLastPage),
                          style: AppTypography.button(context).copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
