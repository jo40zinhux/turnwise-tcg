import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/observability/app_analytics_provider.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/auth_result.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn(
    Future<AuthResult> Function() signIn, {
    void Function()? onSuccess,
  }) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final result = await signIn();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      final analytics = ref.read(appAnalyticsProvider);
      onSuccess?.call();
      await analytics.setUserId(result.userId);
      return;
    }

    if (result.isCancelled) return;

    final message = result.message ??
        'Não foi possível iniciar sessão. Tenta novamente.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authRepositoryProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: AppSpacing.screenHorizontal,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  Icon(
                    Icons.change_history_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  AppSpacing.gapLg,
                  Text(
                    'Bem-vindo ao\nTurnWise',
                    textAlign: TextAlign.center,
                    style: AppTypography.display(context),
                  ),
                  AppSpacing.gapSm,
                  Text(
                    'Assistente de turno para mesas presenciais.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMuted(context),
                  ),
                  const Spacer(flex: 2),
                  ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _handleSignIn(
                              auth.signInAnonymously,
                              onSuccess: () => ref
                                  .read(appAnalyticsProvider)
                                  .logGuestSignIn(),
                            ),
                    icon: const Icon(Icons.sports_esports_outlined),
                    label: const Text('Jogar sem conta'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                  AppSpacing.gapSm,
                  Text(
                    'Funciona offline após a primeira entrada.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(context),
                  ),
                  AppSpacing.gapXl,
                  _LoginButton(
                    icon: Icons.g_mobiledata_rounded,
                    label: 'Continuar com Google',
                    enabled: !_isLoading,
                    onPressed: () => _handleSignIn(
                      auth.signInWithGoogle,
                      onSuccess: () =>
                          ref.read(appAnalyticsProvider).logGoogleSignIn(),
                    ),
                  ),
                  AppSpacing.gapMd,
                  _LoginButton(
                    icon: Icons.apple_rounded,
                    label: 'Continuar com Apple',
                    enabled: !_isLoading,
                    onPressed: () => _handleSignIn(
                      auth.signInWithApple,
                      onSuccess: () =>
                          ref.read(appAnalyticsProvider).logAppleSignIn(),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            if (_isLoading)
              const ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _LoginButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdAll,
          side: const BorderSide(color: Colors.white12),
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Icon(icon, size: 28),
          ),
          Center(
            child: Text(label, style: AppTypography.button(context)),
          ),
        ],
      ),
    );
  }
}
