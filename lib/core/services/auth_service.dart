import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  GoogleSignIn? _googleSignIn;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    late UserCredential userCredential;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      userCredential = await _auth.signInWithPopup(provider);
    } else {
      if (_googleSignIn == null) {
        _googleSignIn = GoogleSignIn.instance;
        await _googleSignIn!.initialize(
          clientId: '579497868233-d1f6gsolt27p489loa8tir83jb7o6b8t.apps.googleusercontent.com',
        );
      }
      final account = await _googleSignIn!.authenticate();
      final idToken = account.authentication.idToken;
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      userCredential = await _auth.signInWithCredential(credential);
    }

    await _saveUserToFirestore(userCredential.user!);
    return userCredential;
  }

  Future<void> _saveUserToFirestore(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final userModel = UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
      );
      await docRef.set(userModel.toMap());
    } else {
      await docRef.update({'lastSeen': Timestamp.now()});
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) await _googleSignIn?.signOut();
    await _auth.signOut();
  }
}
