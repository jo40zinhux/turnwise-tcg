import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/life_counter_config.dart';
import '../../domain/life_counter_direction.dart';
import '../../domain/life_tracker_config.dart';
import '../../domain/match_life_state.dart';

/// Bottom sheet to adjust life / prizes / lore with a user-defined amount.
Future<void> showMatchLifeAdjustSheet(
  BuildContext context, {
  required LifeTrackerConfig config,
  required MatchLifeState life,
  required void Function({
    required String counterId,
    required bool isPlayer,
    required int delta,
    required LifeCounterConfig counter,
  }) onAdjust,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _MatchLifeAdjustSheet(
      config: config,
      life: life,
      onAdjust: onAdjust,
    ),
  );
}

class _MatchLifeAdjustSheet extends StatefulWidget {
  final LifeTrackerConfig config;
  final MatchLifeState life;
  final void Function({
    required String counterId,
    required bool isPlayer,
    required int delta,
    required LifeCounterConfig counter,
  }) onAdjust;

  const _MatchLifeAdjustSheet({
    required this.config,
    required this.life,
    required this.onAdjust,
  });

  @override
  State<_MatchLifeAdjustSheet> createState() => _MatchLifeAdjustSheetState();
}

class _MatchLifeAdjustSheetState extends State<_MatchLifeAdjustSheet> {
  final _amountController = TextEditingController(text: '1');
  late MatchLifeState _life;

  @override
  void initState() {
    super.initState();
    _life = widget.life;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int get _amount {
    final parsed = int.tryParse(_amountController.text.trim());
    if (parsed == null || parsed <= 0) return 1;
    return parsed.clamp(1, 99999);
  }

  void _apply({
    required String counterId,
    required bool isPlayer,
    required int delta,
    required LifeCounterConfig counter,
  }) {
    HapticFeedback.mediumImpact();
    widget.onAdjust(
      counterId: counterId,
      isPlayer: isPlayer,
      delta: delta,
      counter: counter,
    );
    setState(() {
      _life = _life.adjust(
        counterId: counterId,
        isPlayer: isPlayer,
        delta: delta,
        config: counter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Controle de vida', style: AppTypography.title(context)),
          AppSpacing.gapSm,
          Text(
            'Informe o valor e toque em diminuir ou aumentar.',
            style: AppTypography.bodyMuted(context),
          ),
          AppSpacing.gapMd,
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Valor',
              hintText: 'Ex.: 5',
              border: OutlineInputBorder(borderRadius: AppRadius.mdAll),
            ),
            onChanged: (_) => setState(() {}),
          ),
          AppSpacing.gapLg,
          for (var i = 0; i < widget.config.counters.length; i++) ...[
            if (i > 0) AppSpacing.gapLg,
            _CounterSection(
              counter: widget.config.counters[i],
              life: _life,
              amount: _amount,
              onApply: _apply,
            ),
          ],
        ],
      ),
    );
  }
}

class _CounterSection extends StatelessWidget {
  final LifeCounterConfig counter;
  final MatchLifeState life;
  final int amount;
  final void Function({
    required String counterId,
    required bool isPlayer,
    required int delta,
    required LifeCounterConfig counter,
  }) onApply;

  const _CounterSection({
    required this.counter,
    required this.life,
    required this.amount,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final increaseLabel = counter.direction == LifeCounterDirection.up
        ? 'Ganhar $amount'
        : 'Recuperar $amount';
    const decreaseLabel = 'Perder';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(counter.label, style: AppTypography.label(context)),
        AppSpacing.gapSm,
        _PlayerRow(
          title: 'Você',
          value: life.valueFor(
            counterId: counter.id,
            isPlayer: true,
            config: counter,
          ),
          decreaseLabel: '$decreaseLabel $amount',
          increaseLabel: increaseLabel,
          onDecrease: () => onApply(
            counterId: counter.id,
            isPlayer: true,
            delta: -amount,
            counter: counter,
          ),
          onIncrease: () => onApply(
            counterId: counter.id,
            isPlayer: true,
            delta: amount,
            counter: counter,
          ),
        ),
        AppSpacing.gapSm,
        _PlayerRow(
          title: 'Oponente',
          value: life.valueFor(
            counterId: counter.id,
            isPlayer: false,
            config: counter,
          ),
          decreaseLabel: '$decreaseLabel $amount',
          increaseLabel: increaseLabel,
          onDecrease: () => onApply(
            counterId: counter.id,
            isPlayer: false,
            delta: -amount,
            counter: counter,
          ),
          onIncrease: () => onApply(
            counterId: counter.id,
            isPlayer: false,
            delta: amount,
            counter: counter,
          ),
        ),
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final String title;
  final int value;
  final String decreaseLabel;
  final String increaseLabel;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _PlayerRow({
    required this.title,
    required this.value,
    required this.decreaseLabel,
    required this.increaseLabel,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: AppTypography.bodyMuted(context)),
              ),
              Text('$value', style: AppTypography.cardTitle(context)),
            ],
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecrease,
                  child: Text(decreaseLabel),
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: FilledButton(
                  onPressed: onIncrease,
                  child: Text(increaseLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
