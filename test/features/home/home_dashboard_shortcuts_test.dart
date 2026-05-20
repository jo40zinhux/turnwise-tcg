import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/home/presentation/widgets/home_dashboard_shortcuts.dart';

void main() {
  testWidgets('HomeDashboardShortcuts renders all shortcut labels', (tester) async {
    var historyTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: HomeDashboardShortcuts(
            shortcuts: [
              HomeDashboardShortcut(
                icon: Icons.history_rounded,
                label: 'Histórico',
                onTap: () => historyTapped = true,
              ),
              HomeDashboardShortcut(
                icon: Icons.emoji_events_outlined,
                label: 'Conquistas',
                onTap: () {},
              ),
              HomeDashboardShortcut(
                icon: Icons.bar_chart_rounded,
                label: 'Estatísticas',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Histórico'), findsOneWidget);
    expect(find.text('Conquistas'), findsOneWidget);
    expect(find.text('Estatísticas'), findsOneWidget);
    expect(find.text('Explorar'), findsOneWidget);

    await tester.tap(find.text('Histórico'));
    expect(historyTapped, true);
  });
}
