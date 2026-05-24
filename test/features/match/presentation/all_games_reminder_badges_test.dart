import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/match/domain/action_enforcement.dart';
import 'package:turnwise_tcg/features/match/domain/action_rule.dart';
import 'package:turnwise_tcg/features/match/domain/game_rules.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_actions_panel.dart';

import '../support/rules_test_harness.dart';

/// Actions expected to show manual-reminder badges per game.
const kExpectedReminderActions = {
  'pokemon': ['evolve'],
  'one_piece': ['attack'],
  'yugioh': ['declare_attack'],
  'lorcana': ['quest', 'challenge'],
  'magic': ['declare_attacker'],
  'flesh_and_blood': <String>[],
  'riftbound': ['move_unit', 'attack'],
};

Widget _panelFor(GameRules rules, List<ActionRule> actions) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MatchActionsPanel(
          rules: rules,
          actions: actions,
          actionUsageCount: const {},
          maxUsageForAction: (_) => null,
          onActionPressed: (_) {},
          onActionRevert: (_) {},
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Reminder badges across all games', () {
    for (final gameId in kAllGameIds) {
      testWidgets('$gameId shows info badge on condition actions', (tester) async {
        final rules = await RulesTestHarness.loadRules(gameId);
        final expectedIds = kExpectedReminderActions[gameId] ?? [];

        for (final action in rules.actions) {
          final enforcement = ActionEnforcement.analyze(rules, action);
          if (expectedIds.contains(action.id)) {
            expect(
              enforcement.showsReminderBadge,
              isTrue,
              reason: '${action.id} should show reminder badge',
            );
          }
        }

        if (expectedIds.isEmpty) {
          expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
          return;
        }

        final reminderActions = rules.actions
            .where((a) => expectedIds.contains(a.id))
            .toList();

        await tester.pumpWidget(_panelFor(rules, reminderActions));
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.info_outline_rounded),
          findsNWidgets(reminderActions.length),
        );
      });
    }
  });
}
