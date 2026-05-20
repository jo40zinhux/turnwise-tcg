import 'timer_profile.dart';

abstract final class TimerProfileLabels {
  static String title(TimerProfile profile) {
    return switch (profile) {
      TimerProfile.casual => 'Casual',
      TimerProfile.bo1 => 'BO1',
      TimerProfile.bo3 => 'BO3',
      TimerProfile.round => 'Round timer',
    };
  }

  static String description(TimerProfile profile) {
    return switch (profile) {
      TimerProfile.casual => 'Cronómetro livre sem limite.',
      TimerProfile.bo1 => 'Partida única com timer de ronda (50 min).',
      TimerProfile.bo3 => 'Melhor de 3 com timer por jogo.',
      TimerProfile.round => 'Countdown configurável por ronda (50 min).',
    };
  }
}
