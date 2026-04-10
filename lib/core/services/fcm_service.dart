// TODO(V2): Implement Cloud Function trigger to send push notifications
// when a new message is created in conversations/{id}/messages.
// The function should:
//   1. Read recipient UID from conversations/{conversationId}.members
//   2. Fetch their FCM tokens from users/{uid}/tokens
//   3. Call Firebase Admin SDK messaging.sendEachForMulticast()

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initialize({required String uid}) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    await _saveToken(uid);

    _messaging.onTokenRefresh.listen((token) => _saveToken(uid));

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<String?> getToken() => _messaging.getToken(
        // For web, pass your VAPID key here once you have it:
        // vapidKey: 'YOUR_VAPID_KEY',
      );

  Future<void> _saveToken(String uid) async {
    final token = await getToken();
    if (token == null) return;

    await _db
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(FirestoreCollections.tokens)
        .doc(token)
        .set({
      'token': token,
      'platform': defaultTargetPlatform.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Foreground messages are surfaced via in-app UI (SnackBar/Banner).
    // The ChatScreen already shows incoming messages via Firestore streams,
    // so no additional handling is needed beyond logging for now.
    debugPrint('[FCM] Foreground message: ${message.notification?.title}');
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    // Top-level background handler registered in main.dart.
    // When tapped, GoRouter will navigate to the correct conversation
    // using message.data['conversationId'].
    debugPrint('[FCM] Background message: ${message.notification?.title}');
  }
}
