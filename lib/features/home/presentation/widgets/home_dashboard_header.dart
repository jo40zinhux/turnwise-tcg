import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class HomeDashboardHeader extends StatelessWidget {
  final bool hasActiveSession;
  final String? resumeGameName;

  const HomeDashboardHeader({
    super.key,
    required this.hasActiveSession,
    this.resumeGameName,
  });

  @override
  Widget build(BuildContext context) {
    final showResume = hasActiveSession && resumeGameName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          showResume ? 'Continua a tua partida' : 'Bem-vindo ao TurnWise',
          style: AppTypography.headline(context),
        ),
        AppSpacing.gapSm,
        Text(
          showResume
              ? 'Retoma $resumeGameName ou explora o teu painel.'
              : 'O teu painel de TCG — estatísticas, atalhos e jogos num só sítio.',
          style: AppTypography.bodyMuted(context),
        ),
      ],
    );
  }
}
