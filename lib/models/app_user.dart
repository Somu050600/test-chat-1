/// Mirrors `users/{userId}` (Step 3 / Firestore).
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
}
