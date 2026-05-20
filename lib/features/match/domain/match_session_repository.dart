import 'match_session.dart';

abstract class MatchSessionRepository {
  MatchSession? getActiveSession();

  Future<void> saveSession(MatchSession session);

  Future<void> clearActiveSession();
}
