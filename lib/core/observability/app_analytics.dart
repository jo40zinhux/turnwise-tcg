import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_events.dart';

class AppAnalytics {
  final FirebaseAnalytics? _analytics;

  AppAnalytics([FirebaseAnalytics? analytics]) : _analytics = analytics;

  Future<void> logMatchStarted({
    required String gameId,
    required bool resumed,
  }) async {
    await _log(
      resumed ? AnalyticsEvents.matchResumed : AnalyticsEvents.matchStarted,
      {'game_id': gameId},
    );
  }

  Future<void> logMatchEnded({required String gameId}) async {
    await _log(AnalyticsEvents.matchEnded, {'game_id': gameId});
  }

  Future<void> logMatchCompleted({
    required String gameId,
    required int durationSeconds,
    required String outcome,
    String? timerProfile,
  }) async {
    await _log(
      AnalyticsEvents.matchCompleted,
      {
        'game_id': gameId,
        'duration_sec': durationSeconds,
        'outcome': outcome,
        if (timerProfile != null) 'timer_profile': timerProfile,
      },
    );
  }

  Future<void> logPhaseAdvanced({
    required String gameId,
    required int phaseIndex,
  }) async {
    await _log(
      AnalyticsEvents.phaseAdvanced,
      {'game_id': gameId, 'phase_index': phaseIndex},
    );
  }

  Future<void> logActionBlocked({
    required String gameId,
    required String actionId,
  }) async {
    await _log(
      AnalyticsEvents.actionBlocked,
      {'game_id': gameId, 'action_id': actionId},
    );
  }

  Future<void> logGuestSignIn() async {
    await _log(AnalyticsEvents.guestSignIn, const {});
  }

  Future<void> logGoogleSignIn() async {
    await _log(AnalyticsEvents.googleSignIn, const {});
  }

  Future<void> logAppleSignIn() async {
    await _log(AnalyticsEvents.appleSignIn, const {});
  }

  Future<void> setUserId(String? userId) async {
    final analytics = _analytics;
    if (analytics == null) return;
    try {
      await analytics.setUserId(id: userId);
    } catch (e, stack) {
      debugPrint('Analytics setUserId failed: $e\n$stack');
    }
  }

  Future<void> logAchievementUnlocked({
    required String achievementId,
  }) async {
    await _log(
      AnalyticsEvents.achievementUnlocked,
      {'achievement_id': achievementId},
    );
  }

  Future<void> _log(String name, Map<String, Object> parameters) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (e, stack) {
      debugPrint('Analytics event failed ($name): $e\n$stack');
    }
  }
}
