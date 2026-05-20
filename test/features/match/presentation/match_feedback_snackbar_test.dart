import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_semantic_colors.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';
import 'package:turnwise_tcg/features/match/domain/match_feedback.dart';
import 'package:turnwise_tcg/features/match/presentation/utils/match_feedback_snackbar.dart';

Widget _scaffold({required void Function(BuildContext) onReady}) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) => onReady(context));
          return const SizedBox.shrink();
        },
      ),
    ),
  );
}

void main() {
  group('showMatchFeedbackSnackBar', () {
    testWidgets('renders error variant using danger tokens and 3s duration', (tester) async {
      await tester.pumpWidget(_scaffold(
        onReady: (ctx) {
          showMatchFeedbackSnackBar(
            ctx,
            const MatchFeedback(message: 'Erro de fase', type: MatchFeedbackType.error),
          );
        },
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final snack = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snack.backgroundColor, AppSemanticTheme.dark.dangerMuted);
      expect(snack.duration, const Duration(seconds: 3));
      expect(find.text('Erro de fase'), findsOneWidget);
      expect(find.byIcon(Icons.block_rounded), findsOneWidget);
    });

    testWidgets('renders success variant using success tokens', (tester) async {
      await tester.pumpWidget(_scaffold(
        onReady: (ctx) {
          showMatchFeedbackSnackBar(
            ctx,
            const MatchFeedback(message: 'Pronto!', type: MatchFeedbackType.success),
          );
        },
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final snack = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snack.backgroundColor, AppSemanticTheme.dark.successMuted);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('renders info variant on surface color', (tester) async {
      late ThemeData capturedTheme;
      await tester.pumpWidget(_scaffold(
        onReady: (ctx) {
          capturedTheme = Theme.of(ctx);
          showMatchFeedbackSnackBar(
            ctx,
            const MatchFeedback(message: 'Info', type: MatchFeedbackType.info),
          );
        },
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final snack = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snack.backgroundColor, capturedTheme.colorScheme.surface);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
