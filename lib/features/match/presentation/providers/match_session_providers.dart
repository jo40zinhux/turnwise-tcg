import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../data/shared_preferences_match_session_repository.dart';
import '../../domain/match_session.dart';
import '../../domain/match_session_repository.dart';

final matchSessionRepositoryProvider = Provider<MatchSessionRepository>((ref) {
  return SharedPreferencesMatchSessionRepository(
    ref.watch(sharedPreferencesProvider),
  );
});

final activeMatchSessionProvider = Provider<MatchSession?>((ref) {
  return ref.watch(matchSessionRepositoryProvider).getActiveSession();
});
