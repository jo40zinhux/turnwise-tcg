import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/life_counter_config.dart';
import 'package:turnwise_tcg/features/match/domain/life_counter_direction.dart';
import 'package:turnwise_tcg/features/match/domain/life_tracker_config.dart';
import 'package:turnwise_tcg/features/match/domain/match_life_state.dart';

void main() {
  group('MatchLifeState', () {
    const tracker = LifeTrackerConfig(
      enabled: true,
      counters: [
        LifeCounterConfig(
          id: 'life',
          label: 'Vida',
          playerStart: 40,
          opponentStart: 40,
          min: 0,
          direction: LifeCounterDirection.down,
        ),
      ],
    );

    test('initializes from config', () {
      final life = MatchLifeState.initial(tracker);
      expect(life.player['life'], 40);
      expect(life.opponent['life'], 40);
    });

    test('adjust subtracts and clamps to min', () {
      var life = MatchLifeState.initial(tracker);
      final counter = tracker.counters.first;

      life = life.adjust(
        counterId: 'life',
        isPlayer: true,
        delta: -15,
        config: counter,
      );
      expect(life.player['life'], 25);

      life = life.adjust(
        counterId: 'life',
        isPlayer: true,
        delta: -100,
        config: counter,
      );
      expect(life.player['life'], 0);
    });

    test('adjust adds for recovery', () {
      var life = MatchLifeState.initial(tracker);
      final counter = tracker.counters.first;

      life = life.adjust(
        counterId: 'life',
        isPlayer: true,
        delta: -10,
        config: counter,
      );
      life = life.adjust(
        counterId: 'life',
        isPlayer: true,
        delta: 3,
        config: counter,
      );
      expect(life.player['life'], 33);
    });

    test('serializes and deserializes', () {
      final life = MatchLifeState.initial(tracker);
      final restored = MatchLifeState.fromJson(life.toJson());
      expect(restored.player, life.player);
      expect(restored.opponent, life.opponent);
    });
  });

  group('LifeTrackerConfig', () {
    test('parses from json', () {
      final config = LifeTrackerConfig.fromJson({
        'enabled': true,
        'counters': [
          {
            'id': 'prizes',
            'label': 'Prêmios',
            'playerStart': 6,
            'opponentStart': 6,
            'min': 0,
            'max': 6,
            'direction': 'down',
          },
        ],
      });

      expect(config.hasCounters, isTrue);
      expect(config.counters.first.label, 'Prêmios');
    });
  });
}
