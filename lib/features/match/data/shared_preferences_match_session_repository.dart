import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/match_session.dart';
import '../domain/match_session_repository.dart';

class SharedPreferencesMatchSessionRepository implements MatchSessionRepository {
  static const _storageKey = 'active_match_session';

  final SharedPreferences _prefs;

  SharedPreferencesMatchSessionRepository(this._prefs);

  @override
  MatchSession? getActiveSession() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final jsonMap = json.decode(raw) as Map<String, dynamic>;
      return MatchSession.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSession(MatchSession session) async {
    await _prefs.setString(_storageKey, json.encode(session.toJson()));
  }

  @override
  Future<void> clearActiveSession() async {
    await _prefs.remove(_storageKey);
  }
}
