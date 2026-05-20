import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_providers.dart';
import 'providers/feedback_preferences_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(feedbackPreferencesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Definições', style: AppTypography.title(context)),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            Text('Experiência', style: AppTypography.label(context)),
            AppSpacing.gapSm,
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.mdAll,
                side: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Vibração háptica'),
                    subtitle: const Text(
                      'Feedback tátil em ações, fases e timer',
                    ),
                    value: prefs.hapticEnabled,
                    onChanged: (value) => ref
                        .read(feedbackPreferencesProvider.notifier)
                        .setHapticEnabled(value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Sons'),
                    subtitle: const Text(
                      'Efeitos sonoros durante a partida (em breve)',
                    ),
                    value: prefs.soundEnabled,
                    onChanged: (value) => ref
                        .read(feedbackPreferencesProvider.notifier)
                        .setSoundEnabled(value),
                  ),
                ],
              ),
            ),
            AppSpacing.gapXl,
            Text('Conta', style: AppTypography.label(context)),
            AppSpacing.gapSm,
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sair da conta'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sair da conta?', style: AppTypography.title(ctx)),
        content: Text(
          'A sessão atual será encerrada. Podes voltar a entrar a qualquer momento.',
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
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.goNamed('login');
    }
  }
}
