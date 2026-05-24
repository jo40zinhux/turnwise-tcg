import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules_metadata.dart';

void main() {
  group('GameRulesMetadata', () {
    test('requires coin flip setup by default', () {
      expect(const GameRulesMetadata().requiresWentFirstSetup, isTrue);
      expect(GameRulesMetadata.fromJson(null).requiresWentFirstSetup, isTrue);
      expect(
        GameRulesMetadata.fromJson({'themeColor': 'red'}).requiresWentFirstSetup,
        isTrue,
      );
    });

    test('can opt out with skip_coin_flip', () {
      const meta = GameRulesMetadata(setupPrompts: ['skip_coin_flip']);
      expect(meta.requiresWentFirstSetup, isFalse);
    });
  });
}
