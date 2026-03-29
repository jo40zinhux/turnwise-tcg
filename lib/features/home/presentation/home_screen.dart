import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TurnWise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authService.signOut();
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 24.0),
               child: Text(
                 'Welcome to TurnWise. Your journey to mastering TCGs starts here.',
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   fontSize: 18,
                   fontWeight: FontWeight.w300,
                   color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                 ),
               ),
             ),
             const SizedBox(height: 32),
             ElevatedButton.icon(
               onPressed: () {
                 context.goNamed('match');
               },
               icon: const Icon(Icons.play_arrow_rounded),
               label: const Text('Start Match Simulator'),
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                 textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
