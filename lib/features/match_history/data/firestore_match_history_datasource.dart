import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/match_record.dart';

class FirestoreMatchHistoryDataSource {
  final FirebaseFirestore _firestore;

  FirestoreMatchHistoryDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> upsert({
    required String userId,
    required MatchRecord record,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('matches')
        .doc(record.id)
        .set(record.toJson(), SetOptions(merge: true));
  }

  Future<List<MatchRecord>> fetchAll(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('matches')
        .get();

    final records = <MatchRecord>[];
    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        records.add(MatchRecord.fromJson({...data, 'id': data['id'] ?? doc.id}));
      } catch (_) {
        // Skip malformed documents.
      }
    }
    return records;
  }
}
