import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/features/auth/providers/auth_providers.dart';
import 'package:turnwise_tcg/features/match/data/shared_preferences_match_session_repository.dart';
import 'package:turnwise_tcg/features/match/domain/match_session.dart';
import 'package:turnwise_tcg/features/match/domain/match_session_repository.dart';
import 'package:turnwise_tcg/features/match/presentation/providers/match_session_providers.dart';
import 'package:turnwise_tcg/features/match/presentation/services/match_session_persist_coordinator.dart';
import 'package:turnwise_tcg/features/timer/domain/timer_profile.dart';

class _BlockingMatchSessionRepository implements MatchSessionRepository {
  final Completer<void> _releaseSave = Completer<void>();
  MatchSession? _stored;

  void releaseSave() {
    if (!_releaseSave.isCompleted) {
      _releaseSave.complete();
    }
  }

  @override
  MatchSession? getActiveSession() => _stored;

  @override
  Future<void> saveSession(MatchSession session) async {
    await _releaseSave.future;
    _stored = session;
  }

  @override
  Future<void> clearActiveSession() async {
    _stored = null;
  }
}

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
      await coordinator.abandon();
      await coordinator.flushNow();

      expect(
        container.read(matchSessionRepositoryProvider).getActiveSession(),
        isNull,
      );
    });

    test('update after abandon does not resurrect session', () async {
      final coordinator =
          container.read(matchSessionPersistCoordinatorProvider('pokemon'));

      coordinator.update((session) => session.copyWith(currentPhaseIndex: 3));
      await coordinator.abandon();
      coordinator.update(
        (session) => session.copyWith(
          timerProfile: TimerProfile.bo1,
          timerElapsedSeconds: 999,
        ),
      );
      await coordinator.flushNow();

      expect(
        container.read(matchSessionRepositoryProvider).getActiveSession(),
        isNull,
      );
      expect(coordinator.snapshot, isNull);
    });

    test('abandon cancels debounced flush after dismiss', () async {
      final coordinator =
          container.read(matchSessionPersistCoordinatorProvider('pokemon'));

      coordinator.update((session) => session.copyWith(currentPhaseIndex: 2));
      await coordinator.abandon();
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

    test('isAbandoned is true after abandon', () async {
      final coordinator =
          container.read(matchSessionPersistCoordinatorProvider('pokemon'));

      coordinator.update((session) => session.copyWith(currentPhaseIndex: 1));
      expect(coordinator.isAbandoned, isFalse);

      await coordinator.abandon();
      expect(coordinator.isAbandoned, isTrue);
    });

    test(
      'in-flight flush does not resurrect session after abandon',
      () async {
        final blockingRepo = _BlockingMatchSessionRepository();
        final blockingContainer = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            matchSessionRepositoryProvider.overrideWithValue(blockingRepo),
          ],
        );
        addTearDown(blockingContainer.dispose);

        final coordinator = blockingContainer.read(
          matchSessionPersistCoordinatorProvider('pokemon'),
        );
        coordinator.update(
          (session) => session.copyWith(currentPhaseIndex: 2),
        );

        final flushFuture = coordinator.flushNow();
        await Future<void>.delayed(Duration.zero);

        final abandonFuture = coordinator.abandon();
        blockingRepo.releaseSave();

        await flushFuture;
        await abandonFuture;
        await blockingRepo.clearActiveSession();

        expect(blockingRepo.getActiveSession(), isNull);
      },
    );
  });
}
