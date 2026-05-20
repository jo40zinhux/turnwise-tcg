import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/match/domain/action_rule.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_actions_panel.dart';
import 'package:turnwise_tcg/shared/widgets/match_action_chip.dart';

const _actions = [
  ActionRule(id: 'attack', name: 'Atacar', allowedPhases: ['main'], validations: []),
  ActionRule(id: 'defend', name: 'Defender', allowedPhases: ['main'], validations: []),
  ActionRule(id: 'play', name: 'Jogar carta', allowedPhases: ['main'], validations: []),
  ActionRule(id: 'pass', name: 'Passar', allowedPhases: ['main'], validations: []),
];

Widget _wrap({
  required Map<String, int> usage,
  required int? Function(ActionRule) maxUsage,
  required ValueChanged<String> onAction,
  VoidCallback? onUnavailable,
}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MatchActionsPanel(
          actions: _actions,
          actionUsageCount: usage,
          maxUsageForAction: maxUsage,
          onActionPressed: onAction,
          onActionUnavailable: onUnavailable,
        ),
      ),
    ),
  );
}

void main() {
  group('MatchActionsPanel', () {
    testWidgets('renders one chip per action', (tester) async {
      await tester.pumpWidget(_wrap(
        usage: const {},
        maxUsage: (_) => null,
        onAction: (_) {},
      ));
      await tester.pumpAndSettle();

      expect(find.byType(MatchActionChip), findsNWidgets(_actions.length));
    });

    testWidgets('does not use horizontal scroll (no SingleChildScrollView)', (tester) async {
      await tester.pumpWidget(_wrap(
        usage: const {},
        maxUsage: (_) => null,
        onAction: (_) {},
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('forwards action id on tap', (tester) async {
      String? pressed;
      await tester.pumpWidget(_wrap(
        usage: const {},
        maxUsage: (_) => null,
        onAction: (id) => pressed = id,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Defender'));
      await tester.pumpAndSettle();

      expect(pressed, 'defend');
    });

    testWidgets('exhausted action calls onActionUnavailable instead of onAction', (tester) async {
      String? pressed;
      var unavailable = 0;
      await tester.pumpWidget(_wrap(
        usage: const {'attack': 2},
        maxUsage: (a) => a.id == 'attack' ? 2 : null,
        onAction: (id) => pressed = id,
        onUnavailable: () => unavailable++,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Atacar'));
      await tester.pumpAndSettle();

      expect(pressed, isNull, reason: 'must not invoke engine action');
      expect(unavailable, 1);
    });

    testWidgets('empty actions list renders nothing', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: MatchActionsPanel(
            actions: const [],
            actionUsageCount: const {},
            maxUsageForAction: (_) => null,
            onActionPressed: (_) {},
          ),
        ),
      ));

      expect(find.byType(MatchActionChip), findsNothing);
    });
  });
}
