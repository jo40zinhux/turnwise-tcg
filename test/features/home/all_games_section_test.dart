import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/auth/providers/auth_providers.dart';
import 'package:turnwise_tcg/features/games/domain/game_summary.dart';
import 'package:turnwise_tcg/features/home/presentation/widgets/all_games_section.dart';

final _sampleGames = List<GameSummary>.generate(
  4,
  (i) => GameSummary(
    id: 'game_$i',
    name: 'Game $i',
    iconCode: 'sports_esports',
    accent: '#42A5F5',
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows game count and opens Ver todos sheet', (tester) async {
    SharedPreferences.setMockInitialValues({'home_carousel_scroll_hint_seen': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AllGamesSection(
              games: _sampleGames,
              onGameTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Todos os jogos (4)'), findsOneWidget);
    expect(find.text('Ver todos'), findsOneWidget);

    await tester.tap(find.text('Ver todos'));
    await tester.pumpAndSettle();

    expect(find.text('Escolhe um jogo para começar uma partida.'), findsOneWidget);
    expect(find.text('Game 3'), findsWidgets);
  });

  testWidgets('shows scroll coach tip before hint is dismissed', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AllGamesSection(
              games: _sampleGames,
              onGameTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Desliza para ver mais jogos'),
      findsOneWidget,
    );
  });

  testWidgets('hides scroll coach tip after dismiss', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AllGamesSection(
              games: _sampleGames,
              onGameTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('Desliza para ver mais jogos'), findsNothing);
    expect(prefs.getBool('home_carousel_scroll_hint_seen'), isTrue);
  });

  testWidgets('hides Ver todos when two or fewer games', (tester) async {
    SharedPreferences.setMockInitialValues({'home_carousel_scroll_hint_seen': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: AllGamesSection(
              games: _sampleGames.take(2).toList(),
              onGameTap: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Todos os jogos (2)'), findsOneWidget);
    expect(find.text('Ver todos'), findsNothing);
  });
}
