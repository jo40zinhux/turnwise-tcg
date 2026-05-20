import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_crashlytics.dart';

final appCrashlyticsProvider = Provider<AppCrashlytics>((ref) {
  try {
    return AppCrashlytics(FirebaseCrashlytics.instance);
  } catch (_) {
    return AppCrashlytics();
  }
});
