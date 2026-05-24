import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/action_enforcement.dart';
import 'package:turnwise_tcg/features/match/domain/action_rule.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/domain/turn_phase.dart';
import 'package:turnwise_tcg/features/match/domain/validation_rule.dart';

void main() {
  const evolveAction = ActionRule(
    id: 'evolve',
    name: 'Evoluir',
    allowedPhases: ['actions'],
    validations: ['first_turn_evolve_ban', 'evolve_entered_play'],
  );

  const supporterAction = ActionRule(
    id: 'supporter',
    name: 'Apoiador',
    allowedPhases: ['actions'],
    validations: ['supporter_limit', 'first_player_supporter_ban'],
  );

  final rules = GameRules(
    gameId: 'pokemon',
    name: 'Pokemon',
    phases: const [
      TurnPhase(
        id: 'actions',
        title: 'Actions',
        description: '',
        iconCode: 'back_hand_rounded',
      ),
    ],
    actions: const [evolveAction, supporterAction],
    validations: const [
      ValidationRule(
        id: 'first_turn_evolve_ban',
        type: 'player_first_turn',
        params: {},
        errorMessage: 'Sem evoluir no turno 1.',
      ),
      ValidationRule(
        id: 'evolve_entered_play',
        type: 'condition',
        params: {},
        errorMessage: 'Não evoluir no turno em que entrou.',
      ),
      ValidationRule(
        id: 'supporter_limit',
        type: 'limit',
        params: {'max': 1},
        errorMessage: 'Um apoiador por turno.',
      ),
      ValidationRule(
        id: 'first_player_supporter_ban',
        type: 'first_player_first_turn',
        params: {},
        errorMessage: 'Sem apoiador turno 1.',
      ),
    ],
    effects: const [],
  );

  group('ActionEnforcement', () {
    test('evolve has enforced and reminder rules', () {
      final e = ActionEnforcement.analyze(rules, evolveAction);
      expect(e.hasEnforcedRules, isTrue);
      expect(e.hasReminderRules, isTrue);
      expect(e.isReminderOnly, isFalse);
      expect(e.showsReminderBadge, isTrue);
    });

    test('supporter is fully enforced', () {
      final e = ActionEnforcement.analyze(rules, supporterAction);
      expect(e.hasEnforcedRules, isTrue);
      expect(e.isReminderOnly, isFalse);
    });
  });
}
