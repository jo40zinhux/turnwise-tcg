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
  /// banner). Prevents a debounced flush from recreating storage after clear.
  void abandon() {
    _abandoned = true;
    _debounce?.cancel();
    _pending = null;
  }

  void update(MatchSession Function(MatchSession current) apply) {
    _abandoned = false;
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
    if (_abandoned || _pending == null || _isFlushing) return;

    _isFlushing = true;
    try {
      final session = _pending!.copyWith(updatedAt: DateTime.now());
      await _repository.saveSession(session);
      if (_abandoned) return;
      _pending = session;
      _ref.invalidate(activeMatchSessionProvider);
    } finally {
      _isFlushing = false;
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
