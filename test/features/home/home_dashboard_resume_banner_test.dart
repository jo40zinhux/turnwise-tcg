import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/core/observability/app_analytics.dart';
import 'package:turnwise_tcg/core/observability/app_analytics_provider.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/auth/providers/auth_providers.dart';
import 'package:turnwise_tcg/features/games/domain/game_summary.dart';
import 'package:turnwise_tcg/features/games/presentation/providers/game_catalog_providers.dart';
import 'package:turnwise_tcg/features/home/presentation/providers/home_dashboard_providers.dart';
import 'package:turnwise_tcg/features/home/presentation/widgets/home_dashboard_content.dart';
import 'package:turnwise_tcg/features/match/data/shared_preferences_match_session_repository.dart';
import 'package:turnwise_tcg/features/match/domain/match_session.dart';
import 'package:turnwise_tcg/features/match/presentation/providers/match_providers.dart';
import 'package:turnwise_tcg/features/match/presentation/providers/match_session_providers.dart';
import 'package:turnwise_tcg/features/stats/domain/match_stats.dart';
import 'package:turnwise_tcg/features/stats/presentation/providers/match_stats_providers.dart';

const _games = [
  GameSummary(
    id: 'pokemon',
    name: 'Pokémon TCG',
    iconCode: 'catching_pokemon',
    accent: '#FFCB05',
  ),
];

List<Override> _dashboardOverrides(SharedPreferences prefs) => [
      sharedPreferencesProvider.overrideWithValue(prefs),
      gameCatalogProvider.overrideWith((ref) async => _games),
      recentGamesProvider.overrideWith((ref) async => const []),
      matchStatsProvider.overrideWith((ref) async => MatchStats.empty),
      appAnalyticsProvider.overrideWithValue(AppAnalytics()),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeDashboardContent resume banner', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('hides banner when there is no active session', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _dashboardOverrides(prefs),
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: HomeDashboardContent(
                games: _games,
                activeSession: null,
                onGameTap: (_) {},
                onDismissActiveSession: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Partida em andamento'), findsNothing);
      expect(find.text('Retomar partida'), findsNothing);
    });

    testWidgets('shows banner when active session exists', (tester) async {
      final session = MatchSession(
        gameId: 'pokemon',
        currentPhaseIndex: 1,
        actionUsageCount: const {},
        updatedAt: DateTime.now(),
      );
      await SharedPreferencesMatchSessionRepository(prefs).saveSession(session);

      await tester.pumpWidget(
        ProviderScope(
          overrides: _dashboardOverrides(prefs),
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: HomeDashboardContent(
                games: _games,
                activeSession: session,
                onGameTap: (_) {},
                onDismissActiveSession: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Partida em andamento'), findsOneWidget);
      expect(find.text('Continuar Pokémon TCG'), findsOneWidget);
      expect(find.text('Retomar partida'), findsOneWidget);
    });

    testWidgets(
      'hides banner after dismiss clears active session provider',
      (tester) async {
        final session = MatchSession(
          gameId: 'pokemon',
          currentPhaseIndex: 1,
          actionUsageCount: const {},
          updatedAt: DateTime.now(),
        );
        await SharedPreferencesMatchSessionRepository(prefs).saveSession(session);

        await tester.pumpWidget(
          ProviderScope(
            overrides: _dashboardOverrides(prefs),
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: const _HomeDashboardWithActiveSessionProbe(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Partida em andamento'), findsOneWidget);

        await tester.tap(find.byTooltip('Descartar partida'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Partida em andamento'), findsNothing);
      },
    );
  });
}

class _HomeDashboardWithActiveSessionProbe extends ConsumerWidget {
  const _HomeDashboardWithActiveSessionProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeMatchSessionProvider);

    return Scaffold(
      body: HomeDashboardContent(
        games: _games,
        activeSession: activeSession,
        onGameTap: (_) {},
        onDismissActiveSession: () async {
          await dismissActiveMatch(ref, activeSession!.gameId);
        },
      ),
    );
  }
}
