import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    final availableGames = [
      {
        'id': 'flesh_and_blood',
        'name': 'Flesh and Blood',
        'icon': Icons.bloodtype,
        'color': Colors.redAccent
      },
      {
        'id': 'lorcana',
        'name': 'Disney Lorcana',
        'icon': Icons.auto_awesome,
        'color': Colors.purpleAccent
      },
      {
        'id': 'pokemon',
        'name': 'Pokémon TCG',
        'icon': Icons.catching_pokemon,
        'color': Colors.yellow.shade700
      },
      {
        'id': 'magic',
        'name': 'Magic: The Gathering',
        'icon': Icons.fireplace,
        'color': Colors.greenAccent
      },
      {
        'id': 'practice_tcg',
        'name': 'Practice TCG',
        'icon': Icons.extension,
        'color': Colors.greenAccent
      },
    ];

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'Welcome to TurnWise.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a game to start mastering its phases.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: ListView.separated(
                  itemCount: availableGames.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final game = availableGames[index];
                    return ElevatingGameCard(
                      title: game['name'] as String,
                      icon: game['icon'] as IconData,
                      color: game['color'] as Color,
                      onTap: () {
                        context.goNamed('match',
                            pathParameters: {'gameId': game['id'] as String});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElevatingGameCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ElevatingGameCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color:
                Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
