import 'package:flutter/material.dart';

/// TurnWise brand mark used across splash, auth, and other branding surfaces.
class TurnWiseLogo extends StatelessWidget {
  const TurnWiseLogo({
    super.key,
    this.size = 64,
    this.color,
  });

  static const assetPath = 'assets/icons/ic_wise.png';

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: effectiveColor,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
