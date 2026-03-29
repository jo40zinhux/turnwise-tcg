import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turnwise_tcg/features/match/domain/match_phase.dart';
import 'providers/match_providers.dart';

class MatchScreen extends ConsumerWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPhase = ref.watch(matchStateProvider);
    final notifier = ref.read(matchStateProvider.notifier);

    // Listen for feedback messages to show friendly SnackBars
    ref.listen(matchStateProvider, (previous, next) {
      if (notifier.currentFeedback != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notifier.currentFeedback!),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Theme.of(context).colorScheme.surface,
            duration: const Duration(seconds: 4),
          ),
        );
        notifier.clearFeedback(); // Reset after showing
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Match'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Text(
                'Turn Phases Checklist',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Follow the flow below. Use the icons for help.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 32),

              // Phases list
              Expanded(
                child: ListView.separated(
                  itemCount: MatchPhase.values.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final phase = MatchPhase.values[index];
                    final isCurrent = currentPhase == phase;
                    final isPast =
                        MatchPhase.values.indexOf(currentPhase) > index;

                    return _PhaseTile(
                      phase: phase,
                      isCurrent: isCurrent,
                      isPast: isPast,
                    );
                  },
                ),
              ),

              // Action Buttons area to test blockers
              const Divider(color: Colors.white12),
              const SizedBox(height: 16),
              const Text(
                'Simulate Actions:',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          notifier.attemptInvalidAction('atacar oponente'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface),
                      child: const Text('Atacar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          notifier.attemptInvalidAction('baixar carta'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface),
                      child: const Text('Jogar Carta'),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Main Next Phase button
              ElevatedButton(
                onPressed: () {
                  notifier.nextPhase();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: Text(
                  currentPhase == MatchPhase.end ? 'End Turn' : 'Next Phase',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseTile extends StatelessWidget {
  final MatchPhase phase;
  final bool isCurrent;
  final bool isPast;

  const _PhaseTile({
    required this.phase,
    required this.isCurrent,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor = theme.colorScheme.surface;
    Color iconColor = Colors.white54;
    Color textColor = Colors.white54;

    if (isCurrent) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.15);
      iconColor = theme.colorScheme.primary;
      textColor = Colors.white;
    } else if (isPast) {
      iconColor = theme.colorScheme.primary.withOpacity(0.5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: isCurrent
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.5), width: 1.5)
            : Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            isPast ? Icons.check_circle_rounded : phase.icon,
            color: iconColor,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: 4),
                  Text(
                    phase.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  )
                ]
              ],
            ),
          ),
          if (isCurrent)
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, size: 20),
              color: theme.colorScheme.primary,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: Text(phase.title),
                          content: Text(phase.description),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Got it'),
                            )
                          ],
                        ));
              },
            )
        ],
      ),
    );
  }
}
