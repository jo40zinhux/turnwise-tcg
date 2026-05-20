import '../domain/match_history_repository.dart';
import '../domain/match_record.dart';
import 'hive_match_history_datasource.dart';

class MatchHistoryRepositoryImpl implements MatchHistoryRepository {
  final HiveMatchHistoryDataSource _local;

  MatchHistoryRepositoryImpl(this._local);

  @override
  Future<List<MatchRecord>> getAllRecords() => _local.getAll();

  @override
  Future<List<MatchRecord>> getRecent({int limit = 20}) async {
    final all = await _local.getAll();
    if (all.length <= limit) return all;
    return all.sublist(0, limit);
  }

  @override
  Future<MatchRecord?> getById(String id) async {
    final all = await _local.getAll();
    for (final record in all) {
      if (record.id == id) return record;
    }
    return null;
  }

  @override
  Future<void> save(MatchRecord record) async {
    await _local.upsert(record);
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
  }

  @override
  Future<int> count() async {
    return _local.count();
  }
}
