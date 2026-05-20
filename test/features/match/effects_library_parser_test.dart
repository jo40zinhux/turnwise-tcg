import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/checkup_definition.dart';
import 'package:turnwise_tcg/features/match/domain/effect_duration.dart';
import 'package:turnwise_tcg/features/match/domain/effect_type.dart';
import 'package:turnwise_tcg/features/match/domain/effects_library_parser.dart';
import 'package:turnwise_tcg/features/match/domain/game_effects_bundle.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EffectsLibraryParser', () {
    test('maps blockedActions and library duration types', () {
      final effects = EffectsLibraryParser.parseEffects([
        {
          'id': 'attack_lock',
          'name': 'Attack Lock',
          'type': 'attack_restriction',
          'blockedActions': ['attack'],
          'duration': {'type': 'until_end_turn'},
        },
        {
          'id': 'silence',
          'name': 'Silence',
          'type': 'ability_lock',
          'blockedActions': ['ability'],
          'duration': {'type': 'continuous'},
        },
      ]);

      expect(effects, hasLength(2));
      expect(effects[0].type, EffectType.attackRestriction);
      expect(effects[0].lockedActionIds, ['attack']);
      expect(effects[0].duration.kind, EffectDurationKind.turns);
      expect(effects[0].duration.value, 1);

      expect(effects[1].type, EffectType.actionLock);
      expect(effects[1].duration.isPermanent, isTrue);
    });

    test('derives checkups from trigger + description', () {
      final raw = [
        {
          'id': 'poison',
          'name': 'Poison',
          'type': 'status',
          'trigger': 'pokemon_checkup',
          'description': 'Place damage counter.',
        },
      ];
      final effects = EffectsLibraryParser.parseEffects(raw);
      final checkups =
          EffectsLibraryParser.parseDerivedCheckups(effects, raw);

      expect(checkups, hasLength(1));
      expect(checkups.first.trigger, CheckupTrigger.betweenTurns);
      expect(checkups.first.effectIds, ['poison']);
    });
  });

  group('GameEffectsBundle assets', () {
    const games = [
      'pokemon',
      'magic',
      'yugioh',
      'lorcana',
      'one_piece',
      'flesh_and_blood',
      'riftbound',
    ];

    for (final gameId in games) {
      test('loads $gameId effects library from assets', () async {
        final raw = await rootBundle
            .loadString('assets/rules/effects/${gameId}_effects.json');
        final bundle = GameEffectsBundle.fromRawJson(gameId, raw);

        expect(bundle.gameId, gameId);
        expect(bundle.effects, isNotEmpty);
      });
    }

    test('pokemon poison blocks item action when applied in engine', () async {
      final raw =
          await rootBundle.loadString('assets/rules/effects/pokemon_effects.json');
      final bundle = GameEffectsBundle.fromRawJson('pokemon', raw);
      final poison = bundle.effects.firstWhere((e) => e.id == 'poison');

      expect(poison.reminderMessage, isNotNull);
      expect(
        bundle.checkups.any((c) => c.effectIds.contains('poison')),
        isTrue,
      );
    });
  });
}
