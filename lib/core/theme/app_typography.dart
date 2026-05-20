import 'package:flutter/material.dart';

/// Typography hierarchy for TurnWise screens and components.
abstract final class AppTypography {
  static TextTheme textTheme({
    required Color onSurface,
    required Color onSurfaceMuted,
  }) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.25,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: onSurfaceMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: onSurfaceMuted,
      ),
    );
  }

  static TextStyle display(BuildContext context) {
    return TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w300,
      height: 1.2,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle headline(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!;
  }

  static TextStyle title(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!;
  }

  static TextStyle cardTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!;
  }

  static TextStyle body(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!;
  }

  static TextStyle bodyMuted(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }

  static TextStyle label(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!;
  }

  static TextStyle caption(BuildContext context) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
    );
  }

  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!;
  }
}
