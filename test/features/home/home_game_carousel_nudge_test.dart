import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/auth/providers/auth_providers.dart';
import 'package:turnwise_tcg/features/games/domain/game_summary.dart';
import 'package:turnwise_tcg/features/home/presentation/widgets/all_games_section.dart';
import 'package:turnwise_tcg/features/home/presentation/widgets/home_game_carousel.dart';

final _games = List<GameSummary>.generate(
  6,
  (i) => GameSummary(
    id: 'g$i',
    name: 'Game $i',
    iconCode: 'sports_esports',
    accent: '#42A5F5',
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dismisses scroll hint after 3 nudge cycles', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: AllGamesSection(
                games: _games,
                onGameTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    for (var cycle = 0; cycle < HomeGameCarousel.maxScrollNudges; cycle++) {
      final idleDelay = cycle == 0
          ? HomeGameCarousel.scrollNudgeInitialDelay
          : HomeGameCarousel.scrollNudgeRepeatDelay;
      await tester.pump(idleDelay);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();
    }

    expect(prefs.getBool('home_carousel_scroll_hint_seen'), isTrue);
  });

  testWidgets('dismisses scroll hint immediately on user drag', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: AllGamesSection(
                games: _games,
                onGameTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.drag(find.byType(ListView), const Offset(-80, 0));
    await tester.pumpAndSettle();

    expect(prefs.getBool('home_carousel_scroll_hint_seen'), isTrue);
  });
}
