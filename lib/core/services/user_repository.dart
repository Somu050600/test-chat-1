import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';
import '../constants/firestore_paths.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirestorePaths.users);

  /// Creates or updates the signed-in user's profile document.
  Future<void> upsertCurrentUser(User user) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();
    final now = FieldValue.serverTimestamp();
    if (!snap.exists) {
      await ref.set({
        'uid': user.uid,
        'name': user.displayName ?? user.email ?? 'User',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'createdAt': now,
        'lastSeen': now,
      });
    } else {
      await ref.update({
        'name': user.displayName ?? user.email ?? 'User',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'lastSeen': now,
      });
    }
  }

  Stream<List<AppUser>> watchAllUsersExcept(String excludeUid) {
    return _users.snapshots().map((snapshot) {
      final list = <AppUser>[];
      for (final doc in snapshot.docs) {
        if (doc.id == excludeUid) continue;
        final u = AppUser.fromFirestore(doc);
        if (u != null) list.add(u);
      }
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    return AppUser.fromFirestore(doc);
  }

  /// `users/{uid}/tokens/{token}` — document id is the FCM token.
  Future<void> saveFcmToken({
    required String uid,
    required String token,
  }) async {
    await _users.doc(uid).collection('tokens').doc(token).set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
