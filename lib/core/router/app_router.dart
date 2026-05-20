import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/match/presentation/match_screen.dart';
import '../../features/match_history/presentation/match_history_screen.dart';
import '../../features/achievements/presentation/achievements_screen.dart';
import '../../features/stats/presentation/match_stats_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/match_history/presentation/match_summary_screen.dart';
import '../../features/match_history/domain/match_summary_args.dart';

final analytics = FirebaseAnalytics.instance;

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final hasCompletedOnboarding = ref.watch(onboardingStateProvider);

  return GoRouter(
    initialLocation: '/',
    observers: [
      FirebaseAnalyticsObserver(analytics: analytics),
    ],
    redirect: (context, state) {
      final isAuthLoading = authState.isLoading;
      final user = authState.value;

      final isSplash = state.uri.path == '/';
      final isLogin = state.uri.path == '/login';
      final isOnboarding = state.uri.path == '/onboarding';

      // Still loading auth? Wait in splash.
      if (isAuthLoading) return null;

      // If user isn't logged in and not trying to access login view, force to login
      if (user == null && !isLogin && !isSplash) {
        return '/login';
      }

      // If user is logged in
      if (user != null) {
        // If hasn't completed onboarding, and not already there, force to onboarding
        if (!hasCompletedOnboarding && !isOnboarding) {
          return '/onboarding';
        }

        // If has completed onboarding and trying to access splash, login or onboarding, force to home
        if (hasCompletedOnboarding && (isLogin || isSplash || isOnboarding)) {
          return '/home';
        }
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => _buildFadeTransitionPage(
                context: context,
                state: state,
                child: const HomeScreen(),
              ),
          routes: [
            GoRoute(
              path: 'history',
              name: 'history',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                context: context,
                state: state,
                child: const MatchHistoryScreen(),
              ),
            ),
            GoRoute(
              path: 'achievements',
              name: 'achievements',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                context: context,
                state: state,
                child: const AchievementsScreen(),
              ),
            ),
            GoRoute(
              path: 'stats',
              name: 'stats',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                context: context,
                state: state,
                child: const MatchStatsScreen(),
              ),
            ),
            GoRoute(
              path: 'match/:gameId',
              name: 'match',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                context: context,
                state: state,
                child: MatchScreen(
                  gameId: state.pathParameters['gameId']!,
                ),
              ),
            ),
            GoRoute(
              path: 'settings',
              name: 'settings',
              pageBuilder: (context, state) => _buildFadeTransitionPage(
                context: context,
                state: state,
                child: const SettingsScreen(),
              ),
            ),
            GoRoute(
              path: 'match-summary',
              name: 'matchSummary',
              pageBuilder: (context, state) {
                final extra = state.extra;
                final child = extra is MatchSummaryArgs
                    ? MatchSummaryScreen(args: extra)
                    : const MatchSummaryFallback();
                return _buildFadeTransitionPage(
                  context: context,
                  state: state,
                  child: child,
                );
              },
            ),
          ]),
    ],
  );
});

// Custom Fade Transition matching 250ms spec
CustomTransitionPage<T> _buildFadeTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curveAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      return FadeTransition(
        opacity: curveAnimation,
        child: child,
      );
    },
  );
}
