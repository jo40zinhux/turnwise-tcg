import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/match_setup_copy.dart';
import '../providers/match_providers.dart';

/// Asks whether the local player won the coin flip (goes first).
/// Shown for every TCG — rules differ, but turn order is always decided.
Future<bool?> showMatchSetupSheet(
  BuildContext context, {
  required String gameId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _MatchSetupSheet(gameId: gameId),
  );
}

class _MatchSetupSheet extends ConsumerWidget {
  final String gameId;

  const _MatchSetupSheet({required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(gameRulesProvider(gameId));
    final hint = rulesAsync.when(
      data: (rules) => MatchSetupCopy.firstTurnHint(rules),
      loading: () => MatchSetupCopy.firstTurnHintByGameId(gameId),
      error: (_, __) => MatchSetupCopy.firstTurnHintByGameId(gameId),
    );

    return SafeArea(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quem joga primeiro?',
              style: AppTypography.headline(context),
            ),
            AppSpacing.gapSm,
            Text(
              'Em qualquer TCG a moeda define a ordem. '
              'Isto ativa lembretes e validações do primeiro turno.',
              style: AppTypography.bodyMuted(context),
            ),
            AppSpacing.gapMd,
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.35),
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      hint,
                      style: AppTypography.caption(context).copyWith(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,
            _SetupChoiceCard(
              title: 'Eu jogo primeiro',
              subtitle: 'Ganhei a moeda',
              icon: Icons.looks_one_outlined,
              onTap: () => Navigator.pop(context, true),
            ),
            AppSpacing.gapMd,
            _SetupChoiceCard(
              title: 'Oponente joga primeiro',
              subtitle: 'Começo em segundo',
              icon: Icons.looks_two_outlined,
              onTap: () => Navigator.pop(context, false),
            ),
            AppSpacing.gapMd,
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SetupChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdAll,
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.cardTitle(context)),
                    AppSpacing.gapXs,
                    Text(subtitle, style: AppTypography.bodyMuted(context)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
