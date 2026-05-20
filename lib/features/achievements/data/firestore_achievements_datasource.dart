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
}
