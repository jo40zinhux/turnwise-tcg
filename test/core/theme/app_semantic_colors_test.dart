import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/theme/app_semantic_colors.dart';
import 'package:turnwise_tcg/core/theme/app_theme.dart';

void main() {
  group('AppSemanticTheme', () {
    test('dark constant carries non-equal colors for each semantic role', () {
      const t = AppSemanticTheme.dark;
      final roles = {t.success, t.warning, t.danger, t.info};
      expect(roles.length, 4, reason: 'each role must have a unique color');
    });

    test('copyWith overrides only provided fields', () {
      const original = AppSemanticTheme.dark;
      final updated = original.copyWith(success: const Color(0xFF000000));

      expect(updated.success, const Color(0xFF000000));
      expect(updated.danger, original.danger);
      expect(updated.warning, original.warning);
      expect(updated.info, original.info);
    });

    test('lerp at t=0 returns this instance, t=1 returns other', () {
      const a = AppSemanticTheme.dark;
      final b = a.copyWith(success: const Color(0xFFFFFFFF));

      expect(a.lerp(b, 0).success, a.success);
      expect(a.lerp(b, 1).success, b.success);
    });
  });

  testWidgets('dark theme registers AppSemanticTheme extension', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) {
            final ext = Theme.of(context).extension<AppSemanticTheme>();
            expect(ext, isNotNull);
            expect(ext!.success, AppSemanticTheme.dark.success);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('context.semantic shortcut works without dependency on Theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(
          builder: (context) {
            expect(context.semantic.danger, AppSemanticTheme.dark.danger);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('context.semantic falls back to dark when extension missing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            expect(context.semantic.danger, AppSemanticTheme.dark.danger);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}
