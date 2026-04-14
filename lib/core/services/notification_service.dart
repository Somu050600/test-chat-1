import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/env.dart';

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;

  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initialize(String userId) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _saveFcmToken(userId);
      _messaging.onTokenRefresh.listen((token) => _saveFcmToken(userId));
    }
  }

  Future<void> _saveFcmToken(String userId) async {
    try {
      final token = await _messaging.getToken(
        vapidKey: Env.fcmVapidKey.isNotEmpty ? Env.fcmVapidKey : null,
      );
      if (token != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('tokens')
            .doc(token)
            .set({
          'token': token,
          'createdAt': Timestamp.now(),
          'platform': defaultTargetPlatform.name,
        });
      }
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  void setupForegroundHandler(void Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  void setupBackgroundTapHandler(void Function(RemoteMessage) onMessageTap) {
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageTap);
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  Future<void> deleteToken(String userId) async {
    try {
      final token = await _messaging.getToken(
        vapidKey: Env.fcmVapidKey.isNotEmpty ? Env.fcmVapidKey : null,
      );
      if (token != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('tokens')
            .doc(token)
            .delete();
      }
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Failed to delete FCM token: $e');
    }
  }
}
