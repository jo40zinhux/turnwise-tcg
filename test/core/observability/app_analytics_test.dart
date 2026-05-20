import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/observability/analytics_events.dart';
import 'package:turnwise_tcg/core/observability/app_analytics.dart';

void main() {
  group('AppAnalytics', () {
    test('does not throw when analytics is unavailable', () async {
      final analytics = AppAnalytics();

      await expectLater(
        analytics.logMatchStarted(gameId: 'pokemon', resumed: false),
        completes,
      );
      await expectLater(
        analytics.logPhaseAdvanced(gameId: 'pokemon', phaseIndex: 1),
        completes,
      );
      await expectLater(
        analytics.logActionBlocked(gameId: 'pokemon', actionId: 'attack'),
        completes,
      );
      await expectLater(
        analytics.logMatchEnded(gameId: 'pokemon'),
        completes,
      );
      await expectLater(
        analytics.logMatchCompleted(
          gameId: 'pokemon',
          durationSeconds: 120,
          outcome: 'playerWin',
        ),
        completes,
      );
    });
  });

  group('AnalyticsEvents', () {
    test('event names are stable', () {
      expect(AnalyticsEvents.matchStarted, 'match_started');
      expect(AnalyticsEvents.matchResumed, 'match_resumed');
      expect(AnalyticsEvents.actionBlocked, 'action_blocked');
      expect(AnalyticsEvents.matchCompleted, 'match_completed');
      expect(AnalyticsEvents.googleSignIn, 'google_sign_in');
      expect(AnalyticsEvents.appleSignIn, 'apple_sign_in');
    });
  });
}
