import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<UserModel> createUserProfile({
    required String uid,
    required String phoneNumber,
    String? displayName,
  }) async {
    final now = DateTime.now();
    final user = UserModel(
      uid: uid,
      phoneNumber: phoneNumber,
      displayName: displayName ?? 'SAAMAgo User',
      createdAt: now,
      updatedAt: now,
    );

    await _db.collection('users').doc(uid).set(user.toMap());
    return user;
  }

    Stream<UserModel?> getUserProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection('users').doc(uid).update(data);
  }
}
