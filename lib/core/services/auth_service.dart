import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) return null;

    final userModel = UserModel(
      uid: user.uid,
      name: user.displayName ?? 'Unknown',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastSeen: DateTime.now(),
    );

    await _upsertUser(userModel);
    return userModel;
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> _upsertUser(UserModel user) async {
    final ref = _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid);

    final snapshot = await ref.get();
    if (snapshot.exists) {
      await ref.update({'lastSeen': Timestamp.fromDate(DateTime.now())});
    } else {
      await ref.set(user.toMap());
    }
  }

  Future<void> updateLastSeen() async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .update({'lastSeen': Timestamp.fromDate(DateTime.now())});
  }
}
