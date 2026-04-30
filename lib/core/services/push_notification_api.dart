import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/env.dart';

class PushNotificationApi {
  Future<void> sendNotification({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    if (Env.notifyApiUrl.isEmpty) return;

    try {
      await http.post(
        Uri.parse(Env.notifyApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': Env.notifyApiKey,
        },
        body: jsonEncode({
          'conversationId': conversationId,
          'senderId': senderId,
          'text': text,
        }),
      );
    } catch (e) {
      debugPrint('Push notification API error: $e');
    }
  }
}
