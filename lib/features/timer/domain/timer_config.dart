import 'timer_profile.dart';

abstract final class TimerConfig {
  static const int roundDurationSeconds = 50 * 60;
  static const int gamesToWinBo3 = 2;

  static int? initialRemainingSeconds(TimerProfile profile) {
    return switch (profile) {
      TimerProfile.casual => null,
      TimerProfile.bo1 ||
      TimerProfile.bo3 ||
      TimerProfile.round =>
        roundDurationSeconds,
    };
  }

  static bool usesCountdown(TimerProfile profile) => profile != TimerProfile.casual;
}
