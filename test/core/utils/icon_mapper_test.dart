import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnwise_tcg/core/utils/icon_mapper.dart';

void main() {
  group('getIconFromString', () {
    test('returns help_outline for unknown codes', () {
      expect(getIconFromString('unknown_icon_xyz'), Icons.help_outline);
    });

    test('returns mapped icon for a known code', () {
      expect(getIconFromString('copy_outlined'), Icons.copy_outlined);
      expect(getIconFromString('catching_pokemon'), Icons.catching_pokemon);
    });

    test('all achievement iconCodes resolve to non-fallback icons', () {
      final raw = File('assets/achievements.json').readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final achievements = (json['achievements'] as List).cast<Map<String, dynamic>>();
      expect(achievements, isNotEmpty);

      for (final achievement in achievements) {
        final code = achievement['iconCode'] as String;
        final icon = getIconFromString(code);
        expect(
          icon,
          isNot(Icons.help_outline),
          reason:
              'Achievement "${achievement['id']}" uses iconCode "$code" but it falls back to help_outline. '
              'Add it to icon_mapper.dart.',
        );
      }
    });

    test('all game manifest iconCodes resolve to non-fallback icons', () {
      final manifestFile = File('assets/games_manifest.json');
      if (!manifestFile.existsSync()) return; // manifest absence handled elsewhere

      final raw = manifestFile.readAsStringSync();
      final json = jsonDecode(raw);
      final games = json is Map<String, dynamic>
          ? (json['games'] as List? ?? const [])
          : (json as List);

      for (final entry in games) {
        if (entry is! Map<String, dynamic>) continue;
        final code = entry['iconCode'] as String?;
        if (code == null) continue;
        final icon = getIconFromString(code);
        expect(
          icon,
          isNot(Icons.help_outline),
          reason:
              'Game entry "${entry['id']}" uses iconCode "$code" but it falls back to help_outline.',
        );
      }
    });
  });
}
