import 'package:flutter/material.dart';

/// Border radius tokens aligned with cards, buttons, and chips.
abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
}
