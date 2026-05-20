import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/feedback/haptics_player.dart';
import 'package:turnwise_tcg/core/feedback/match_feedback_service.dart';
import 'package:turnwise_tcg/features/settings/domain/feedback_preferences.dart';

class _RecordingHapticsPlayer implements HapticsPlayer {
  final List<String> events = [];

  @override
  Future<void> selection() async => events.add('selection');

  @override
  Future<void> light() async => events.add('light');

  @override
  Future<void> medium() async => events.add('medium');

  @override
  Future<void> heavy() async => events.add('heavy');
}

void main() {
  group('MatchFeedbackService', () {
    late _RecordingHapticsPlayer haptics;
    late FeedbackPreferences prefs;
    late MatchFeedbackService service;

    setUp(() {
      haptics = _RecordingHapticsPlayer();
      prefs = FeedbackPreferences.defaults;
      service = MatchFeedbackService(
        haptics: haptics,
        preferencesProvider: () => prefs,
      );
    });

    test('actionUsed triggers selection haptic when enabled', () async {
      await service.actionUsed();
      expect(haptics.events, ['selection']);
    });

    test('actionUnavailable triggers light haptic when enabled', () async {
      await service.actionUnavailable();
      expect(haptics.events, ['light']);
    });

    test('actionInvalid triggers heavy haptic when enabled', () async {
      await service.actionInvalid();
      expect(haptics.events, ['heavy']);
    });

    test('phaseAdvance triggers selection haptic', () async {
      await service.phaseAdvance();
      expect(haptics.events, ['selection']);
    });

    test('turnEnd triggers medium haptic', () async {
      await service.turnEnd();
      expect(haptics.events, ['medium']);
    });

    test('achievementUnlocked triggers heavy haptic', () async {
      await service.achievementUnlocked();
      expect(haptics.events, ['heavy']);
    });

    test('timerWarning triggers light haptic', () async {
      await service.timerWarning();
      expect(haptics.events, ['light']);
    });

    test('timerExpired triggers heavy haptic', () async {
      await service.timerExpired();
      expect(haptics.events, ['heavy']);
    });

    test('all events skip haptics when hapticEnabled is false', () async {
      prefs = const FeedbackPreferences(
        hapticEnabled: false,
        soundEnabled: true,
      );

      await service.actionUsed();
      await service.actionUnavailable();
      await service.actionInvalid();
      await service.phaseAdvance();
      await service.turnEnd();
      await service.achievementUnlocked();
      await service.timerWarning();
      await service.timerExpired();

      expect(haptics.events, isEmpty);
    });

    test('preferences are read lazily on each call', () async {
      await service.actionUsed();
      expect(haptics.events, ['selection']);

      prefs = const FeedbackPreferences(
        hapticEnabled: false,
        soundEnabled: false,
      );
      await service.actionUsed();
      expect(haptics.events, ['selection']);

      prefs = FeedbackPreferences.defaults;
      await service.actionUsed();
      expect(haptics.events, ['selection', 'selection']);
    });
  });
}
