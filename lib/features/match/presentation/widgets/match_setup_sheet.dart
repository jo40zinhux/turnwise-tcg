import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/life_starting_preset.dart';
import '../../domain/life_tracker_config.dart';
import '../../domain/match_life_state.dart';
import '../../domain/match_setup_copy.dart';
import '../../domain/match_setup_result.dart';
import '../providers/match_providers.dart';

/// Controls whether the sheet is opened for an initial setup or an in-match
/// order correction.
///
/// - [initial]: shown before the first turn; life presets are offered.
/// - [edit]: shown mid-match; presets are hidden because the live counters are
///   managed through [MatchLifeBar] and resetting them from here would be
///   unexpected.
enum MatchSetupMode { initial, edit }

/// Asks whether the local player won the coin flip (goes first) and,
/// when the game supports it and the mode is [MatchSetupMode.initial],
/// lets the player choose a life-total preset.
Future<MatchSetupResult?> showMatchSetupSheet(
  BuildContext context, {
  required String gameId,
  MatchSetupMode mode = MatchSetupMode.initial,
}) {
  return showModalBottomSheet<MatchSetupResult>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _MatchSetupSheet(gameId: gameId, mode: mode),
  );
}

class _MatchSetupSheet extends ConsumerStatefulWidget {
  final String gameId;
  final MatchSetupMode mode;

  const _MatchSetupSheet({required this.gameId, required this.mode});

  @override
  ConsumerState<_MatchSetupSheet> createState() => _MatchSetupSheetState();
}

class _MatchSetupSheetState extends ConsumerState<_MatchSetupSheet> {
  LifeStartingPreset? _selectedPreset;

  bool get _isEditing => widget.mode == MatchSetupMode.edit;

  void _confirm(bool playerWentFirst, LifeTrackerConfig lifeTracker) {
    // In edit mode the sheet only corrects turn order; live counters are
    // intentionally left unchanged. Never produce initialLife here.
    final initialLife = _isEditing
        ? null
        : (_selectedPreset != null
            ? MatchLifeState.fromPreset(lifeTracker, _selectedPreset!)
            : (lifeTracker.hasCounters
                ? MatchLifeState.initial(lifeTracker)
                : null));

    Navigator.pop(
      context,
      MatchSetupResult(
        playerWentFirst: playerWentFirst,
        initialLife: initialLife,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rulesAsync = ref.watch(gameRulesProvider(widget.gameId));
    final hint = rulesAsync.when(
      data: (rules) => MatchSetupCopy.firstTurnHint(rules),
      loading: () => MatchSetupCopy.firstTurnHintByGameId(widget.gameId),
      error: (_, __) => MatchSetupCopy.firstTurnHintByGameId(widget.gameId),
    );
    final lifeTracker = rulesAsync.whenOrNull(
          data: (rules) => rules.metadata.lifeTracker,
        ) ??
        const LifeTrackerConfig();

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.screen.copyWith(
          bottom: AppSpacing.screen.bottom + bottomInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Ajustar turno' : 'Preparar partida',
              style: AppTypography.headline(context),
            ),
            AppSpacing.gapXs,
            Text(
              'Quem joga primeiro?',
              style: AppTypography.cardTitle(context),
            ),
            AppSpacing.gapSm,
            Text(
              _isEditing
                  ? 'Corrija a ordem de turno sem alterar o placar em andamento.'
                  : 'Em qualquer TCG a moeda define a ordem. '
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
                    .withValues(alpha: 0.35),
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isEditing
                        ? Icons.swap_horiz_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _isEditing
                          ? 'O placar de vida atual não é afetado. '
                              'Use o controle de vida para ajustar pontos durante a partida.'
                          : hint,
                      style: AppTypography.caption(context)
                          .copyWith(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            // Life presets are only shown on initial setup — mid-match edits
            // preserve live counters and do not offer a reset.
            if (!_isEditing && lifeTracker.startingPresets.isNotEmpty) ...[
              AppSpacing.gapLg,
              Text(
                'Pontos de vida iniciais',
                style: AppTypography.cardTitle(context),
              ),
              AppSpacing.gapSm,
              Wrap(
                spacing: AppSpacing.sm,
                children: lifeTracker.startingPresets.map((preset) {
                  final selected = _selectedPreset == preset ||
                      (_selectedPreset == null &&
                          lifeTracker.startingPresets.first == preset);
                  return ChoiceChip(
                    label: Text(preset.label),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedPreset = preset),
                  );
                }).toList(),
              ),
            ],
            AppSpacing.gapLg,
            _SetupChoiceCard(
              title: 'Eu jogo primeiro',
              subtitle: 'Ganhei a moeda',
              icon: Icons.looks_one_outlined,
              onTap: () => _confirm(true, lifeTracker),
            ),
            AppSpacing.gapMd,
            _SetupChoiceCard(
              title: 'Oponente joga primeiro',
              subtitle: 'Começo em segundo',
              icon: Icons.looks_two_outlined,
              onTap: () => _confirm(false, lifeTracker),
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
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.4),
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
