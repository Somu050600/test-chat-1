import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'service_providers.dart';

/// Streams the raw Firebase [User] (null when signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Streams the full [UserModel] for the signed-in user from Firestore.
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(firestoreServiceProvider).userStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (error, stack) => Stream.value(null),
  );
});
