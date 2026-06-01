import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/match_session.dart';
import '../../domain/match_session_repository.dart';
import '../providers/match_session_providers.dart';

/// Single writer for [MatchSession] to avoid read-modify-write races between
/// phase state and timer state.
class MatchSessionPersistCoordinator {
  final Ref _ref;
  final String gameId;
  final MatchSessionRepository _repository;

  MatchSession? _pending;
  Timer? _debounce;
  bool _isFlushing = false;
  bool _abandoned = false;
  Completer<void>? _flushCompleter;

  bool get isAbandoned => _abandoned;

  MatchSessionPersistCoordinator({
    required Ref ref,
    required this.gameId,
  })  : _ref = ref,
        _repository = ref.read(matchSessionRepositoryProvider);

  MatchSession? get snapshot => _pending;

  void hydrateFromStorage() {
    final stored = _repository.getActiveSession();
    if (stored != null && stored.gameId == gameId) {
      _pending = stored;
    }
  }

  /// Drops in-memory state and cancels pending writes (e.g. user dismissed resume
  /// banner). Waits for an in-flight flush so storage cannot be rewritten after
  /// [MatchSessionRepository.clearActiveSession].
  Future<void> abandon() async {
    _abandoned = true;
    _debounce?.cancel();
    _pending = null;
    final inFlight = _flushCompleter;
    if (inFlight != null) {
      await inFlight.future;
    }
  }

  void update(MatchSession Function(MatchSession current) apply) {
    if (_abandoned) return;
    final base = _pending ?? _emptySession();
    _pending = apply(base);
    _scheduleFlush();
  }

  Future<void> flushNow() async {
    _debounce?.cancel();
    await _flush();
  }

  void _scheduleFlush() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_flush());
    });
  }

  Future<void> _flush() async {
    if (_abandoned || _pending == null) return;
    if (_isFlushing) {
      final inFlight = _flushCompleter;
      if (inFlight != null) await inFlight.future;
      return;
    }

    final done = Completer<void>();
    _flushCompleter = done;
    _isFlushing = true;
    try {
      if (_abandoned || _pending == null) return;

      final session = _pending!.copyWith(updatedAt: DateTime.now());
      if (_abandoned) return;

      await _repository.saveSession(session);
      if (_abandoned) {
        await _repository.clearActiveSession();
        return;
      }

      _pending = session;
      _ref.invalidate(activeMatchSessionProvider);
    } finally {
      _isFlushing = false;
      done.complete();
      if (identical(_flushCompleter, done)) {
        _flushCompleter = null;
      }
    }
  }

  MatchSession _emptySession() {
    final now = DateTime.now();
    return MatchSession(
      gameId: gameId,
      currentPhaseIndex: 0,
      actionUsageCount: const {},
      updatedAt: now,
      startedAt: now,
    );
  }

  void dispose() {
    _debounce?.cancel();
    if (!_abandoned && _pending != null) {
      unawaited(_flush());
    }
  }
}

final matchSessionPersistCoordinatorProvider =
    Provider.family<MatchSessionPersistCoordinator, String>((ref, gameId) {
  final coordinator = MatchSessionPersistCoordinator(ref: ref, gameId: gameId);
  coordinator.hydrateFromStorage();
  ref.onDispose(coordinator.dispose);
  return coordinator;
});
