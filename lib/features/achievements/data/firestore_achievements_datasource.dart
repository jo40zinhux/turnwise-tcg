import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user_achievement.dart';

class FirestoreAchievementsDataSource {
  final FirebaseFirestore _firestore;

  FirestoreAchievementsDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> upsert({
    required String userId,
    required UserAchievement achievement,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .doc(achievement.achievementId)
        .set(achievement.toJson(), SetOptions(merge: true));
  }

  Future<List<UserAchievement>> fetchAll(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('achievements')
        .get();

    final achievements = <UserAchievement>[];
    for (final doc in snapshot.docs) {
      try {
        achievements.add(UserAchievement.fromJson(doc.data()));
      } catch (_) {
        // Skip malformed documents.
      }
    }
    return achievements;
  }
}
