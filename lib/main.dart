import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/firebase/firebase_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/match_history/data/hive_initializer.dart';
import 'features/sync/presentation/cloud_sync_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveInitializer.init();

  final prefs = await SharedPreferences.getInstance();

  await bootstrapFirebase();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CloudSyncBootstrap(
        child: TurnWiseApp(),
      ),
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
