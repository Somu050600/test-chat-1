import 'package:cloud_firestore/cloud_firestore.dart';

/// Mirrors `users/{userId}` in Firestore.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.createdAt,
    this.lastSeen,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime? createdAt;
  final DateTime? lastSeen;

  static AppUser? fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;
    final created = data['createdAt'];
    final seen = data['lastSeen'];
    return AppUser(
      uid: data['uid'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: created is Timestamp ? created.toDate() : null,
      lastSeen: seen is Timestamp ? seen.toDate() : null,
    );
  }
}
