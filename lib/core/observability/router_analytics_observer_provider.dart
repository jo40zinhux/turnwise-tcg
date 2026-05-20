import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerAnalyticsObserversProvider =
    Provider<List<NavigatorObserver>>((ref) {
  try {
    return [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ];
  } catch (_) {
    return const [];
  }
});
