import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/match_history/data/hive_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveInitializer.init();

  final prefs = await SharedPreferences.getInstance();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error (likely needs flutterfire configure): $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TurnWiseApp(),
    ),
  );
}

class TurnWiseApp extends ConsumerWidget {
  const TurnWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the GoRouter provider so it rebuilds correctly on auth state changes
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TurnWise',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
