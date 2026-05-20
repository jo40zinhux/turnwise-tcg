import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/games/domain/game_summary.dart';

void main() {
  group('GameSummary', () {
    test('fromJson parses all fields', () {
      final game = GameSummary.fromJson({
        'id': 'pokemon',
        'name': 'Pokémon TCG',
        'iconCode': 'catching_pokemon',
        'accent': '#FBC02D',
      });

      expect(game.id, 'pokemon');
      expect(game.name, 'Pokémon TCG');
      expect(game.iconCode, 'catching_pokemon');
      expect(game.accent, '#FBC02D');
    });
  });
}
