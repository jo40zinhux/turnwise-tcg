import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/features/auth/providers/auth_providers.dart';
import 'package:turnwise_tcg/features/games/domain/game_summary.dart';
import 'package:turnwise_tcg/features/games/presentation/providers/game_catalog_providers.dart';
import 'package:turnwise_tcg/features/home/presentation/providers/home_dashboard_providers.dart';
import 'package:turnwise_tcg/features/match/data/shared_preferences_match_session_repository.dart';
import 'package:turnwise_tcg/features/match/domain/match_session.dart';
import 'package:turnwise_tcg/features/match/presentation/providers/match_session_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('resumeGameNameProvider', () {
    test('falls back to gameId when catalog is still loading', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final session = MatchSession(
        gameId: 'pokemon',
        currentPhaseIndex: 0,
        actionUsageCount: const {},
        updatedAt: DateTime.now(),
      );
      await SharedPreferencesMatchSessionRepository(prefs).saveSession(session);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          gameCatalogProvider.overrideWith(
            (ref) async {
              await Future<void>.delayed(const Duration(seconds: 10));
              return const [
                GameSummary(
                  id: 'pokemon',
                  name: 'Pokémon TCG',
                  iconCode: 'catching_pokemon',
                  accent: '#FFCB05',
                ),
              ];
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(resumeGameNameProvider), 'pokemon');
    });
  });
}
