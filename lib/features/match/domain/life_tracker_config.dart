import 'life_counter_config.dart';
import 'life_starting_preset.dart';

/// Life / prizes / lore tracker configuration from game rules metadata.
class LifeTrackerConfig {
  final bool enabled;
  final List<LifeCounterConfig> counters;
  final List<LifeStartingPreset> startingPresets;

  const LifeTrackerConfig({
    this.enabled = false,
    this.counters = const [],
    this.startingPresets = const [],
  });

  bool get hasCounters => enabled && counters.isNotEmpty;

  LifeCounterConfig? counterById(String id) {
    for (final counter in counters) {
      if (counter.id == id) return counter;
    }
    return null;
  }

  factory LifeTrackerConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LifeTrackerConfig();

    final rawCounters = json['counters'] as List<dynamic>?;
    final counters = rawCounters
            ?.map(
              (e) => LifeCounterConfig.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        const <LifeCounterConfig>[];

    final presets = (json['startingPresets'] as List<dynamic>?)
            ?.map(
              (e) => LifeStartingPreset.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        const <LifeStartingPreset>[];

    return LifeTrackerConfig(
      enabled: json['enabled'] as bool? ?? counters.isNotEmpty,
      counters: counters,
      startingPresets: presets,
    );
  }
}
