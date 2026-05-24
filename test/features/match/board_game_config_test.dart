import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/board_game_config.dart';
import 'package:turnwise_tcg/features/match/domain/board_metadata.dart';

import 'support/rules_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BoardGameConfig per-game flags', () {
    test('pokemon uses evolve label only', () {
      final specs = BoardGameConfig.flagSpecs('pokemon');
      expect(specs, hasLength(1));
      expect(specs.first.label, 'Entrou em jogo neste turno');
    });

    test('one piece uses rested label', () {
      final specs = BoardGameConfig.flagSpecs('one_piece');
      expect(specs.single.label, 'Descansado (Rested)');
    });

    test('lorcana uses exerted label', () {
      final specs = BoardGameConfig.flagSpecs('lorcana');
      expect(specs.single.label, 'Exertado');
    });

    test('magic uses summoning sickness label', () {
      final specs = BoardGameConfig.flagSpecs('magic');
      expect(specs.single.label, 'Enjoo de invocação');
    });

    test('yugioh uses attack position only', () {
      final specs = BoardGameConfig.flagSpecs('yugioh');
      expect(specs.single.label, 'Em posição de ataque');
    });

    test('riftbound uses exhausted label', () {
      final specs = BoardGameConfig.flagSpecs('riftbound');
      expect(specs.single.label, 'Exaurida');
    });

    test('flesh and blood has no trackable flags', () {
      expect(BoardGameConfig.flagSpecs('flesh_and_blood'), isEmpty);
      expect(BoardGameConfig.emptyFlagsHint('flesh_and_blood'), isNotNull);
    });
  });

  group('BoardGameConfig from JSON metadata', () {
    test('riftbound uses Exaurida label from rules bundle', () async {
      final rules = await RulesTestHarness.loadRules('riftbound');
      final specs = BoardGameConfig.resolveFlagSpecs(
        'riftbound',
        rules.metadata.board,
      );
      expect(specs.single.label, 'Exaurida');
    });

    test('empty metadata falls back to dart config', () {
      const empty = BoardMetadata();
      expect(
        BoardGameConfig.resolveFlagSpecs('pokemon', empty).single.label,
        'Entrou em jogo neste turno',
      );
    });
  });
}
