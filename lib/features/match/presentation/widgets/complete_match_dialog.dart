import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../match_history/domain/match_outcome.dart';
import '../../../match_history/domain/match_outcome_labels.dart';

class CompleteMatchResult {
  final MatchOutcome outcome;
  final String? notes;

  const CompleteMatchResult({
    required this.outcome,
    this.notes,
  });
}

Future<CompleteMatchResult?> showCompleteMatchDialog(BuildContext context) {
  return showDialog<CompleteMatchResult>(
    context: context,
    builder: (ctx) => const _CompleteMatchDialog(),
  );
}

class _CompleteMatchDialog extends StatefulWidget {
  const _CompleteMatchDialog();

  @override
  State<_CompleteMatchDialog> createState() => _CompleteMatchDialogState();
}

class _CompleteMatchDialogState extends State<_CompleteMatchDialog> {
  MatchOutcome _outcome = MatchOutcome.playerWin;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.sizeOf(context).width - AppSpacing.xl * 2;
    final contentWidth = dialogWidth.clamp(260.0, 360.0);

    return AlertDialog(
      title: Text('Encerrar partida', style: AppTypography.title(context)),
      content: SizedBox(
        width: contentWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Como terminou a partida?',
                style: AppTypography.bodyMuted(context),
              ),
              AppSpacing.gapMd,
              _OutcomeGrid(
                selected: _outcome,
                onChanged: (value) => setState(() => _outcome = value),
              ),
              AppSpacing.gapMd,
              TextField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              CompleteMatchResult(
                outcome: _outcome,
                notes: _notesController.text,
              ),
            );
          },
          child: const Text('Guardar e encerrar'),
        ),
      ],
    );
  }
}

class _OutcomeGrid extends StatelessWidget {
  final MatchOutcome selected;
  final ValueChanged<MatchOutcome> onChanged;

  const _OutcomeGrid({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        final width = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final outcome in MatchOutcome.values)
              SizedBox(
                width: width,
                child: _OutcomeCard(
                  outcome: outcome,
                  isSelected: outcome == selected,
                  onTap: () => onChanged(outcome),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  final MatchOutcome outcome;
  final bool isSelected;
  final VoidCallback onTap;

  const _OutcomeCard({
    required this.outcome,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semantic;
    final spec = _OutcomeSpec.of(outcome, semantic);

    final background = isSelected
        ? spec.accent.withOpacity(0.18)
        : theme.colorScheme.surface;
    final border = isSelected
        ? BorderSide(color: spec.accent, width: 1.5)
        : BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3));

    return Semantics(
      selected: isSelected,
      button: true,
      label: MatchOutcomeLabels.label(outcome),
      child: Material(
        color: background,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smAll,
              border: Border.fromBorderSide(border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  spec.icon,
                  color: spec.accent,
                  size: 22,
                ),
                AppSpacing.gapXs,
                Text(
                  MatchOutcomeLabels.label(outcome),
                  style: AppTypography.label(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutcomeSpec {
  final IconData icon;
  final Color accent;

  const _OutcomeSpec({required this.icon, required this.accent});

  factory _OutcomeSpec.of(MatchOutcome outcome, AppSemanticTheme semantic) {
    return switch (outcome) {
      MatchOutcome.playerWin => _OutcomeSpec(
          icon: Icons.emoji_events_outlined,
          accent: semantic.success,
        ),
      MatchOutcome.playerLoss => _OutcomeSpec(
          icon: Icons.flag_outlined,
          accent: semantic.danger,
        ),
      MatchOutcome.draw => _OutcomeSpec(
          icon: Icons.handshake_outlined,
          accent: semantic.info,
        ),
      MatchOutcome.abandoned => _OutcomeSpec(
          icon: Icons.exit_to_app_rounded,
          accent: semantic.warning,
        ),
    };
  }
}
