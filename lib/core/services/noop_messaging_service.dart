import 'package:firebase_messaging/firebase_messaging.dart';

import 'messaging_service.dart';

/// Test / headless builds where FCM is unavailable.
class NoOpMessagingService extends MessagingService {
  NoOpMessagingService({required super.userRepository}) : super();

  @override
  Future<void> bootstrap({
    required String uid,
    void Function(RemoteMessage message)? onForegroundMessage,
  }) async {}
}
