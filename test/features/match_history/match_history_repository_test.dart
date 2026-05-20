import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:turnwise_tcg/features/match_history/data/hive_match_history_datasource.dart';
import 'package:turnwise_tcg/features/match_history/data/match_history_repository_impl.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_outcome.dart';
import 'package:turnwise_tcg/features/match_history/domain/match_record.dart';

void main() {
  late Directory tempDir;
  late HiveMatchHistoryDataSource dataSource;
  late MatchHistoryRepositoryImpl repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('turnwise_hive_test');
    Hive.init(tempDir.path);
    dataSource = HiveMatchHistoryDataSource();
    repository = MatchHistoryRepositoryImpl(dataSource);
  });

  tearDown(() async {
    if (Hive.isBoxOpen(HiveMatchHistoryDataSource.boxName)) {
      await Hive.box<String>(HiveMatchHistoryDataSource.boxName).close();
    }
    await Hive.deleteBoxFromDisk(HiveMatchHistoryDataSource.boxName);
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  MatchRecord buildRecord({
    required String id,
    required String gameId,
    required DateTime endedAt,
    MatchOutcome outcome = MatchOutcome.playerWin,
  }) {
    return MatchRecord(
      id: id,
      gameId: gameId,
      startedAt: endedAt.subtract(const Duration(minutes: 30)),
      endedAt: endedAt,
      outcome: outcome,
      updatedAt: endedAt,
    );
  }

  test('saves and returns recent matches ordered by endedAt desc', () async {
    await repository.save(
      buildRecord(
        id: 'older',
        gameId: 'pokemon',
        endedAt: DateTime.parse('2026-05-18T12:00:00.000'),
      ),
    );
    await repository.save(
      buildRecord(
        id: 'newer',
        gameId: 'magic',
        endedAt: DateTime.parse('2026-05-19T12:00:00.000'),
      ),
    );

    final recent = await repository.getRecent(limit: 10);

    expect(recent.length, 2);
    expect(recent.first.id, 'newer');
    expect(recent.last.id, 'older');
    expect(await repository.count(), 2);
  });

  test('getById returns a single record', () async {
    await repository.save(
      buildRecord(
        id: 'match-42',
        gameId: 'lorcana',
        endedAt: DateTime.parse('2026-05-19T08:00:00.000'),
      ),
    );

    final found = await repository.getById('match-42');
    expect(found?.gameId, 'lorcana');
    expect(await repository.getById('missing'), isNull);
  });

  test('delete removes record', () async {
    await repository.save(
      buildRecord(
        id: 'to-delete',
        gameId: 'yugioh',
        endedAt: DateTime.parse('2026-05-19T09:00:00.000'),
      ),
    );

    await repository.delete('to-delete');

    expect(await repository.count(), 0);
    expect(await repository.getById('to-delete'), isNull);
  });
}
