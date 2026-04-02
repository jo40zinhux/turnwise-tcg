import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/icon_mapper.dart';
import '../domain/turn_phase.dart';
import 'providers/match_providers.dart';

class MatchScreen extends ConsumerWidget {
  final String gameId;

  const MatchScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(gameRulesProvider(gameId));

    return Scaffold(
      appBar: AppBar(
        title: rulesAsync.when(
          data: (rules) => Text(rules.name),
          loading: () => const Text('Loading Match...'),
          error: (_, __) => const Text('Error'),
        ),
      ),
      body: SafeArea(
        child: rulesAsync.when(
          data: (rules) => _MatchBody(gameId: gameId),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Failed to load rules: $error')),
        ),
      ),
    );
  }
}

class _MatchBody extends ConsumerWidget {
  final String gameId;

  const _MatchBody({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(gameRulesProvider(gameId)).value!;
    final matchState = ref.watch(matchStateProvider(gameId));
    final notifier = ref.read(matchStateProvider(gameId).notifier);

    // Listen for feedback messages to show friendly SnackBars
    ref.listen(matchStateProvider(gameId), (previous, next) {
      if (next.currentFeedback != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.currentFeedback!,
              style: const TextStyle(color: Colors.white),
            ),
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

    return Padding(
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
              itemCount: rules.phases.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final phase = rules.phases[index];
                final isCurrent = matchState.currentPhaseIndex == index;
                final isPast = matchState.currentPhaseIndex > index;

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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: rules.actions.map((action) {
              int? maxAllowed;
              for (final validationId in action.validations) {
                try {
                  final validation = rules.validations.firstWhere((v) => v.id == validationId);
                  if (validation.type == 'limit') {
                    maxAllowed = validation.params['max'] as int? ?? 1;
                    break;
                  }
                } catch (_) {}
              }

              final currentUsage = matchState.actionUsageCount[action.id] ?? 0;
              final isExhausted = maxAllowed != null && currentUsage >= maxAllowed;

              return Opacity(
                opacity: isExhausted ? 0.5 : 1.0,
                child: ElevatedButton(
                  onPressed: () => notifier.attemptAction(action.id),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: isExhausted ? Theme.of(context).colorScheme.primary : null),
                  child: Text(action.name),
                ),
              );
            }).toList(),
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
              matchState.currentPhaseIndex == rules.phases.length - 1
                  ? 'End Turn'
                  : 'Next Phase',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseTile extends StatelessWidget {
  final TurnPhase phase;
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

    final computedIcon = getIconFromString(phase.iconCode);

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
            isPast ? Icons.check_circle_rounded : computedIcon,
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
