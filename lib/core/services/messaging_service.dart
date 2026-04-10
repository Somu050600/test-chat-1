import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'user_repository.dart';

/// FCM setup: permission, token persistence, foreground handling.
class MessagingService {
  MessagingService({
    FirebaseMessaging? messaging,
    required UserRepository userRepository,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _userRepository = userRepository;

  final FirebaseMessaging _messaging;
  final UserRepository _userRepository;

  Future<void> bootstrap({
    required String uid,
    void Function(RemoteMessage message)? onForegroundMessage,
  }) async {
    if (kIsWeb) {
      // Optional: use VAPID key via Firebase Console for web FCM.
      return;
    }

    await _messaging.setAutoInitEnabled(true);
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    final token = await _messaging.getToken();
    if (token != null) {
      await _userRepository.saveFcmToken(uid: uid, token: token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _userRepository.saveFcmToken(uid: uid, token: newToken);
    });

    if (onForegroundMessage != null) {
      FirebaseMessaging.onMessage.listen(onForegroundMessage);
    }
  }
}
