import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/notification_service.dart';
import '../core/services/push_notification_api.dart';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final pushNotificationApiProvider =
    Provider<PushNotificationApi>((ref) => PushNotificationApi());
