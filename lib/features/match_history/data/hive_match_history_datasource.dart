import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../domain/match_record.dart';

class HiveMatchHistoryDataSource {
  static const boxName = 'match_history';

  Box<String>? _box;

  Future<Box<String>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<String>(boxName);
    return _box!;
  }

  Future<List<MatchRecord>> getAll() async {
    final records = <MatchRecord>[];
    final hiveBox = await box;

    for (final raw in hiveBox.values) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        records.add(MatchRecord.fromJson(json));
      } catch (_) {
        // Skip corrupted entries.
      }
    }

    records.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return records;
  }

  Future<void> upsert(MatchRecord record) async {
    final hiveBox = await box;
    await hiveBox.put(record.id, jsonEncode(record.toJson()));
  }

  Future<void> delete(String id) async {
    final hiveBox = await box;
    await hiveBox.delete(id);
  }

  Future<int> count() async {
    final hiveBox = await box;
    return hiveBox.length;
  }
}
