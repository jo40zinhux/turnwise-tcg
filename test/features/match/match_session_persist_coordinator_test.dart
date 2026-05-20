import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/features/auth/providers/auth_providers.dart';
import 'package:turnwise_tcg/features/match/data/shared_preferences_match_session_repository.dart';
import 'package:turnwise_tcg/features/match/domain/match_session.dart';
import 'package:turnwise_tcg/features/match/presentation/providers/match_session_providers.dart';
import 'package:turnwise_tcg/features/match/presentation/services/match_session_persist_coordinator.dart';
import 'package:turnwise_tcg/features/timer/domain/timer_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MatchSessionPersistCoordinator', () {
    late SharedPreferences prefs;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('merges phase and timer updates into one session', () async {
      final coordinator =
          container.read(matchSessionPersistCoordinatorProvider('pokemon'));

      coordinator.update(
        (session) => session.copyWith(currentPhaseIndex: 2),
      );
      coordinator.update(
        (session) => session.copyWith(
          timerProfile: TimerProfile.bo1,
          timerElapsedSeconds: 10,
        ),
      );

      await coordinator.flushNow();

      final stored = container
          .read(matchSessionRepositoryProvider)
          .getActiveSession();

      expect(stored?.gameId, 'pokemon');
      expect(stored?.currentPhaseIndex, 2);
      expect(stored?.timerProfile, TimerProfile.bo1);
      expect(stored?.timerElapsedSeconds, 10);
    });

    test('abandon prevents flushNow from persisting session', () async {
      final coordinator =
          container.read(matchSessionPersistCoordinatorProvider('pokemon'));

      coordinator.update((session) => session.copyWith(currentPhaseIndex: 1));
      coordinator.abandon();
      await coordinator.flushNow();

      expect(
        container.read(matchSessionRepositoryProvider).getActiveSession(),
        isNull,
      );
    });

    test('abandon cancels debounced flush after dismiss', () async {
      final coordinator =
          container.read(matchSessionPersistCoordinatorProvider('pokemon'));

      coordinator.update((session) => session.copyWith(currentPhaseIndex: 2));
      coordinator.abandon();
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(
        container.read(matchSessionRepositoryProvider).getActiveSession(),
        isNull,
      );
    });

    test('hydrateFromStorage loads existing session', () async {
      final repo = SharedPreferencesMatchSessionRepository(prefs);
      await repo.saveSession(
        MatchSession(
          gameId: 'magic',
          currentPhaseIndex: 1,
          actionUsageCount: const {},
          updatedAt: DateTime.now(),
        ),
      );

      final coordinator =
          container.read(matchSessionPersistCoordinatorProvider('magic'));

      expect(coordinator.snapshot?.currentPhaseIndex, 1);
    });
  });
}
