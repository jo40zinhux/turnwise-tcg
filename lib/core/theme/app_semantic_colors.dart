import 'package:flutter/material.dart';

/// Semantic color tokens for status, feedback, and outcomes.
///
/// Exposed via [AppSemanticTheme] as a [ThemeExtension] so widgets can read
/// `Theme.of(context).extension<AppSemanticTheme>()` instead of hardcoding
/// hex values. Keeps `colorScheme.primary` reserved for branding/active and
/// frees green/red/amber for outcomes (win/loss/warning).
@immutable
class AppSemanticTheme extends ThemeExtension<AppSemanticTheme> {
  final Color success;
  final Color successMuted;
  final Color warning;
  final Color warningMuted;
  final Color danger;
  final Color dangerMuted;
  final Color info;
  final Color infoMuted;

  const AppSemanticTheme({
    required this.success,
    required this.successMuted,
    required this.warning,
    required this.warningMuted,
    required this.danger,
    required this.dangerMuted,
    required this.info,
    required this.infoMuted,
  });

  static const AppSemanticTheme dark = AppSemanticTheme(
    success: Color(0xFF38C172),
    successMuted: Color(0xFF1F3D2C),
    warning: Color(0xFFE0A03B),
    warningMuted: Color(0xFF3D2F18),
    danger: Color(0xFFE5484D),
    dangerMuted: Color(0xFF3D1C1C),
    info: Color(0xFF5BC0EB),
    infoMuted: Color(0xFF1B2E3A),
  );

  @override
  AppSemanticTheme copyWith({
    Color? success,
    Color? successMuted,
    Color? warning,
    Color? warningMuted,
    Color? danger,
    Color? dangerMuted,
    Color? info,
    Color? infoMuted,
  }) {
    return AppSemanticTheme(
      success: success ?? this.success,
      successMuted: successMuted ?? this.successMuted,
      warning: warning ?? this.warning,
      warningMuted: warningMuted ?? this.warningMuted,
      danger: danger ?? this.danger,
      dangerMuted: dangerMuted ?? this.dangerMuted,
      info: info ?? this.info,
      infoMuted: infoMuted ?? this.infoMuted,
    );
  }

  @override
  AppSemanticTheme lerp(ThemeExtension<AppSemanticTheme>? other, double t) {
    if (other is! AppSemanticTheme) return this;
    return AppSemanticTheme(
      success: Color.lerp(success, other.success, t)!,
      successMuted: Color.lerp(successMuted, other.successMuted, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningMuted: Color.lerp(warningMuted, other.warningMuted, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerMuted: Color.lerp(dangerMuted, other.dangerMuted, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoMuted: Color.lerp(infoMuted, other.infoMuted, t)!,
    );
  }
}

/// Shortcut: `context.semantic.success` instead of
/// `Theme.of(context).extension<AppSemanticTheme>()!.success`.
extension AppSemanticThemeX on BuildContext {
  AppSemanticTheme get semantic =>
      Theme.of(this).extension<AppSemanticTheme>() ?? AppSemanticTheme.dark;
}
