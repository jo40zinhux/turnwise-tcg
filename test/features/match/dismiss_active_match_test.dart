import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turnwise_tcg/core/observability/app_analytics.dart';
import 'package:turnwise_tcg/core/observability/app_analytics_provider.dart';
import 'package:turnwise_tcg/features/auth/providers/auth_providers.dart';
import 'package:turnwise_tcg/features/match/data/shared_preferences_match_session_repository.dart';
import 'package:turnwise_tcg/features/match/domain/match_session.dart';
import 'package:turnwise_tcg/features/match/presentation/providers/match_providers.dart';

class _DismissActiveMatchInvoker extends ConsumerStatefulWidget {
  const _DismissActiveMatchInvoker({
    required this.gameId,
    required this.onComplete,
  });

  final String gameId;
  final void Function() onComplete;

  @override
  ConsumerState<_DismissActiveMatchInvoker> createState() =>
      _DismissActiveMatchInvokerState();
}

class _DismissActiveMatchInvokerState
    extends ConsumerState<_DismissActiveMatchInvoker> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_run);
  }

  Future<void> _run() async {
    await dismissActiveMatch(ref, widget.gameId);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('dismissActiveMatch', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('clears active session from storage', (tester) async {
      final repo = SharedPreferencesMatchSessionRepository(prefs);
      await repo.saveSession(
        MatchSession(
          gameId: 'pokemon',
          currentPhaseIndex: 1,
          actionUsageCount: const {},
          updatedAt: DateTime.now(),
        ),
      );

      var dismissed = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            appAnalyticsProvider.overrideWithValue(AppAnalytics()),
          ],
          child: _DismissActiveMatchInvoker(
            gameId: 'pokemon',
            onComplete: () => dismissed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(repo.getActiveSession(), isNull);
    });
  });
}
