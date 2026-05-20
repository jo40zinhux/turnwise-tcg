import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/cloud_sync_providers.dart';

/// Activates background Firestore ↔ Hive sync when the user is authenticated.
class CloudSyncBootstrap extends ConsumerWidget {
  final Widget child;

  const CloudSyncBootstrap({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(cloudSyncListenerProvider);
    return child;
  }
}
