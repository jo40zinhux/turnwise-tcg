import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/features/match/domain/match_resources_state.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_resource_bar.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_tracker_notice.dart';
import 'package:turnwise_tcg/features/match/presentation/widgets/match_turn_context_bar.dart';

void main() {
  group('Match touch targets', () {
    testWidgets('turn context opponent button meets 44pt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MatchTurnContextBar(
              turnNumber: 2,
              isOpponentTurn: true,
              onCompleteOpponentTurn: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final btn = tester.getRect(find.byType(TextButton));
      expect(btn.height, greaterThanOrEqualTo(44));
    });

    testWidgets('resource bar buttons meet 44pt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MatchResourceBar(
              gameId: 'one_piece',
              resources: const MatchResourcesState(don: 5),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final btn = tester.getRect(find.byType(IconButton).first);
      expect(btn.height, greaterThanOrEqualTo(44));
      expect(btn.width, greaterThanOrEqualTo(44));
    });

    testWidgets('tracker notice dismiss button meets 44pt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MatchTrackerNotice(onDismiss: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final btn = tester.getRect(find.byType(IconButton));
      expect(btn.height, greaterThanOrEqualTo(44));
      expect(btn.width, greaterThanOrEqualTo(44));
    });
  });
}
