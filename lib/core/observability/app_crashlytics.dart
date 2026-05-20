import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AppCrashlytics {
  final FirebaseCrashlytics? _crashlytics;

  AppCrashlytics([FirebaseCrashlytics? crashlytics]) : _crashlytics = crashlytics;

  bool get isAvailable => _crashlytics != null;

  Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
    String? reason,
  }) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) {
      debugPrint('Crashlytics unavailable ($reason): $error\n$stack');
      return;
    }

    try {
      await crashlytics.recordError(
        error,
        stack,
        reason: reason,
        fatal: fatal,
      );
    } catch (e, recordStack) {
      debugPrint('Crashlytics recordError failed: $e\n$recordStack');
    }
  }

  Future<void> log(String message) async {
    final crashlytics = _crashlytics;
    if (crashlytics == null) return;
    try {
      await crashlytics.log(message);
    } catch (_) {}
  }
}
