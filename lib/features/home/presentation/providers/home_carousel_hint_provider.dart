import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/providers/auth_providers.dart';
import '../widgets/home_game_carousel.dart';

const _scrollHintSeenKey = 'home_carousel_scroll_hint_seen';

class HomeCarouselHintState {
  final bool seen;
  final int nudgeTick;

  const HomeCarouselHintState({
    required this.seen,
    this.nudgeTick = 0,
  });
}

/// Scroll-hint orchestration for the home game carousel (survives widget rebuilds).
final homeCarouselScrollHintSeenProvider =
    StateNotifierProvider<HomeCarouselScrollHintNotifier, HomeCarouselHintState>(
        (ref) {
  return HomeCarouselScrollHintNotifier(ref.watch(sharedPreferencesProvider));
});

class HomeCarouselScrollHintNotifier extends StateNotifier<HomeCarouselHintState> {
  final SharedPreferences _prefs;
  int _completedNudges = 0;
  Timer? _idleTimer;
  bool _catalogMounted = false;
  bool _catalogCanScroll = false;

  HomeCarouselScrollHintNotifier(this._prefs)
      : super(HomeCarouselHintState(
          seen: _prefs.getBool(_scrollHintSeenKey) ?? false,
        ));

  void onCatalogCarouselMounted({required int itemCount}) {
    _catalogMounted = true;
    _catalogCanScroll = itemCount > 2;
    if (_catalogCanScroll) {
      _scheduleNextNudge();
    }
  }

  void onCatalogCarouselUnmounted() {
    _catalogMounted = false;
    _cancelIdleTimer();
  }

  void onCatalogItemCountChanged(int itemCount) {
    _catalogCanScroll = itemCount > 2;
    if (!_catalogCanScroll) {
      _cancelIdleTimer();
      return;
    }
    if (_catalogMounted && !state.seen && _idleTimer == null) {
      _scheduleNextNudge();
    }
  }

  void onUserScrollInteraction() {
    markHintSeen();
  }

  void onNudgeCycleComplete() {
    if (state.seen) return;
    _completedNudges++;
    if (_completedNudges >= HomeGameCarousel.maxScrollNudges) {
      markHintSeen();
      return;
    }
    _scheduleNextNudge();
  }

  Future<void> markHintSeen() async {
    _cancelIdleTimer();
    if (state.seen) return;
    await _prefs.setBool(_scrollHintSeenKey, true);
    state = HomeCarouselHintState(seen: true, nudgeTick: state.nudgeTick);
  }

  void _scheduleNextNudge() {
    _cancelIdleTimer();
    if (state.seen ||
        !_catalogMounted ||
        !_catalogCanScroll ||
        _completedNudges >= HomeGameCarousel.maxScrollNudges) {
      return;
    }

    final delay = _completedNudges == 0
        ? HomeGameCarousel.scrollNudgeInitialDelay
        : HomeGameCarousel.scrollNudgeRepeatDelay;

    _idleTimer = Timer(delay, () {
      _idleTimer = null;
      if (state.seen || !_catalogMounted || !_catalogCanScroll) return;
      state = HomeCarouselHintState(
        seen: false,
        nudgeTick: state.nudgeTick + 1,
      );
    });
  }

  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  @override
  void dispose() {
    _cancelIdleTimer();
    super.dispose();
  }
}
