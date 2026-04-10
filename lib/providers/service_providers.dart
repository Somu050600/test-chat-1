import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/auth_service.dart';
import '../core/services/chat_repository.dart';
import '../core/services/messaging_service.dart';
import '../core/services/noop_messaging_service.dart';
import '../core/services/user_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(firebaseAuth: ref.watch(firebaseAuthProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final messagingServiceProvider = Provider<MessagingService>((ref) {
  final users = ref.watch(userRepositoryProvider);
  if (kIsWeb) {
    return NoOpMessagingService(userRepository: users);
  }
  return MessagingService(userRepository: users);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// Notifies [GoRouter] when [FirebaseAuth] session changes.
final authRefreshListenableProvider = Provider<AuthRefreshNotifier>((ref) {
  final notifier = AuthRefreshNotifier(ref.watch(firebaseAuthProvider));
  ref.onDispose(notifier.dispose);
  return notifier;
});

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(this._auth) {
    _sub = _auth.authStateChanges().listen((_) => notifyListeners());
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
