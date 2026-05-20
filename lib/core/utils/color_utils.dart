import 'package:flutter/material.dart';

Color colorFromHex(String hex) {
  final normalized = hex.replaceFirst('#', '');
  final value = int.parse(
    normalized.length == 6 ? 'FF$normalized' : normalized,
    radix: 16,
  );
  return Color(value);
}
