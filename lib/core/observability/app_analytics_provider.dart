import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_analytics.dart';

final appAnalyticsProvider = Provider<AppAnalytics>((ref) {
  try {
    return AppAnalytics(FirebaseAnalytics.instance);
  } catch (_) {
    return AppAnalytics();
  }
});
