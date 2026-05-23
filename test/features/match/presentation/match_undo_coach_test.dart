import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/coach/presentation/widgets/coach_tip_banner.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_actions_panel.dart';
import 'package:turnwise_tcg/features/match/domain/action_rule.dart';

/// Minimal harness mirroring match undo coach visibility rules.
class MatchUndoCoachHarness extends StatefulWidget {
  final Map<String, int> usage;

  const MatchUndoCoachHarness({super.key, required this.usage});

  @override
  State<MatchUndoCoachHarness> createState() => _MatchUndoCoachHarnessState();
}

class _MatchUndoCoachHarnessState extends State<MatchUndoCoachHarness> {
  bool _dismissed = false;

  int _totalUsage(Map<String, int> usage) {
    return usage.values.fold(0, (sum, count) => sum + count);
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalUsage(widget.usage);
    final showCoach = total > 0 && !_dismissed;

    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showCoach)
              CoachTipBanner(
                message: 'Tocaste sem querer? Toca outra vez para desfazer.',
                onDismiss: () => setState(() => _dismissed = true),
              ),
            MatchActionsPanel(
              actions: const [
                ActionRule(
                  id: 'play',
                  name: 'Jogar carta',
                  allowedPhases: ['main'],
                  validations: [],
                ),
              ],
              actionUsageCount: widget.usage,
              maxUsageForAction: (_) => 1,
              onActionPressed: (_) {},
              onActionRevert: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('undo coach hidden until an action is registered', (tester) async {
    await tester.pumpWidget(
      const MatchUndoCoachHarness(usage: {}),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Tocaste sem querer'), findsNothing);
  });

  testWidgets('undo coach visible when action usage exists', (tester) async {
    await tester.pumpWidget(
      const MatchUndoCoachHarness(usage: {'play': 1}),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Tocaste sem querer'), findsOneWidget);
  });
}
