import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';

/// Confirms abandoning the in-progress match session from the home resume banner.
Future<bool> confirmDismissActiveMatch(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Descartar partida?', style: AppTypography.title(ctx)),
      content: Text(
        'O progresso deste turno será perdido. Esta ação não pode ser desfeita.',
        style: AppTypography.bodyMuted(ctx),
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Descartar'),
        ),
      ],
    ),
  );

  return result ?? false;
}
