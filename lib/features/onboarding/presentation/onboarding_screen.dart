import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      "headline": "Jogue com confiança.",
      "text":
          "TurnWise é seu assistente inteligente para partidas presenciais de TCG."
    },
    {
      "headline": "Nunca perca uma ação importante.",
      "text":
          "Checklist de turno, controle de prêmios e lembretes inteligentes durante a partida."
    },
    {
      "headline": "Evolua junto com o jogo.",
      "text":
          "Histórico de partidas, calendário competitivo e muito mais em breve."
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSkip() async {
    await _completeOnboarding();
  }

  void _onStart() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingStateProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Primary color #7C5CFF
    const Color primaryPurple = Color(0xFF7C5CFF);

    return Scaffold(
      backgroundColor: Colors.black, // Dark minimalism
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onSkip,
                child: const Text(
                  'Pular',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            ),

            // Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Space for an illustration or icon if desired
                        const SizedBox(height: 40),
                        Text(
                          _onboardingData[index]['headline']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _onboardingData[index]['text']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Section (Dots and Start Button)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 40.0, left: 40.0, right: 40.0),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: _currentPage == index ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? primaryPurple
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Start Button Placeholder (To keep height consistent)
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: _currentPage == _onboardingData.length - 1
                          ? 1.0
                          : 0.0,
                      child: ElevatedButton(
                        onPressed: _currentPage == _onboardingData.length - 1
                            ? _onStart
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Começar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
