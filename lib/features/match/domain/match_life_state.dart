import 'life_counter_config.dart';
import 'life_starting_preset.dart';
import 'life_tracker_config.dart';

/// Runtime values for life, prizes, lore, or victory-point counters.
class MatchLifeState {
  final Map<String, int> player;
  final Map<String, int> opponent;

  const MatchLifeState({
    this.player = const {},
    this.opponent = const {},
  });

  static const empty = MatchLifeState();

  factory MatchLifeState.initial(LifeTrackerConfig config) {
    final player = <String, int>{};
    final opponent = <String, int>{};
    for (final counter in config.counters) {
      player[counter.id] = counter.playerStart;
      opponent[counter.id] = counter.opponentStart;
    }
    return MatchLifeState(player: player, opponent: opponent);
  }

  /// Applies a [LifeStartingPreset] to the primary counter in [config].
  factory MatchLifeState.fromPreset(
    LifeTrackerConfig config,
    LifeStartingPreset preset,
  ) {
    if (config.counters.isEmpty) return MatchLifeState.initial(config);

    final primaryId = config.counters.first.id;
    final player = <String, int>{};
    final opponent = <String, int>{};
    for (final counter in config.counters) {
      if (counter.id == primaryId) {
        player[counter.id] = preset.playerStart;
        opponent[counter.id] = preset.opponentStart;
      } else {
        player[counter.id] = counter.playerStart;
        opponent[counter.id] = counter.opponentStart;
      }
    }
    return MatchLifeState(player: player, opponent: opponent);
  }

  int valueFor({
    required String counterId,
    required bool isPlayer,
    required LifeCounterConfig config,
  }) {
    final map = isPlayer ? player : opponent;
    return map[counterId] ??
        (isPlayer ? config.playerStart : config.opponentStart);
  }

  /// Applies a signed delta to [counterId] for the local player or opponent.
  MatchLifeState adjust({
    required String counterId,
    required bool isPlayer,
    required int delta,
    required LifeCounterConfig config,
  }) {
    if (delta == 0) return this;

    final map = Map<String, int>.from(isPlayer ? player : opponent);
    final current =
        map[counterId] ?? (isPlayer ? config.playerStart : config.opponentStart);
    map[counterId] = config.clamp(current + delta);

    return MatchLifeState(
      player: isPlayer ? map : player,
      opponent: isPlayer ? opponent : map,
    );
  }

  MatchLifeState copyWith({
    Map<String, int>? player,
    Map<String, int>? opponent,
  }) {
    return MatchLifeState(
      player: player ?? this.player,
      opponent: opponent ?? this.opponent,
    );
  }

  factory MatchLifeState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MatchLifeState.empty;

    return MatchLifeState(
      player: _parseCounterMap(json['player']),
      opponent: _parseCounterMap(json['opponent']),
    );
  }

  static Map<String, int> _parseCounterMap(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map(
      (key, value) => MapEntry(key.toString(), (value as num).toInt()),
    );
  }

  Map<String, dynamic> toJson() => {
        'player': player,
        'opponent': opponent,
      };
}
