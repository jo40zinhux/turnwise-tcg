import 'match_record.dart';

abstract class MatchHistoryRepository {
  Future<List<MatchRecord>> getAllRecords();

  Future<List<MatchRecord>> getRecent({int limit = 20});

  Future<MatchRecord?> getById(String id);

  Future<void> save(MatchRecord record);

  Future<void> delete(String id);

  Future<int> count();
}
