import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_router_provider.dart';
import '../providers/service_providers.dart';
import '../routes/app_router.dart';

/// Registers FCM after sign-in; foreground snackbars and tap-to-open chat.
class MessagingBootstrap extends ConsumerStatefulWidget {
  const MessagingBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MessagingBootstrap> createState() =>
      _MessagingBootstrapState();
}

class _MessagingBootstrapState extends ConsumerState<MessagingBootstrap> {
  String? _bootstrappedUid;
  StreamSubscription<RemoteMessage>? _openedAppSub;
  static bool _handledInitialMessage = false;
  bool _scheduledInitialCheck = false;
  bool _fcmListenersAttached = false;

  @override
  void dispose() {
    _openedAppSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
      next.whenData((user) {
        if (user != null) {
          _bootstrapIfNeeded(user.uid);
          _attachFcmNavigationIfNeeded();
        } else {
          _bootstrappedUid = null;
        }
      });
    });

    final user = ref.watch(authStateProvider).value;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _bootstrapIfNeeded(user.uid);
        _attachFcmNavigationIfNeeded();
      });
    }

    return widget.child;
  }

  void _attachFcmNavigationIfNeeded() {
    if (kIsWeb || _fcmListenersAttached) return;
    _fcmListenersAttached = true;

    try {
      _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((m) {
        final id = m.data['conversationId'];
        if (id != null && id.isNotEmpty) {
          ref.read(appRouterProvider).go(AppRoutePaths.chat(id));
        }
      });
    } catch (_) {
      // Headless tests / missing platform implementation.
    }

    if (!_handledInitialMessage && !_scheduledInitialCheck) {
      _scheduledInitialCheck = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || _handledInitialMessage) return;
        try {
          final initial =
              await FirebaseMessaging.instance.getInitialMessage();
          _handledInitialMessage = true;
          final id = initial?.data['conversationId'];
          if (id != null && id.isNotEmpty && mounted) {
            ref.read(appRouterProvider).go(AppRoutePaths.chat(id));
          }
        } catch (_) {
          _handledInitialMessage = true;
        }
      });
    }
  }

  Future<void> _bootstrapIfNeeded(String uid) async {
    if (_bootstrappedUid == uid) return;
    _bootstrappedUid = uid;

    final messaging = ref.read(messagingServiceProvider);
    try {
      await messaging.bootstrap(
        uid: uid,
        onForegroundMessage: (RemoteMessage m) {
          if (!mounted) return;
          final convo = m.data['conversationId'];
          final from =
              m.notification?.title ?? m.data['senderName'] ?? 'New message';
          final body = m.notification?.body ?? m.data['text'] ?? '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$from: $body'),
              action: convo != null && convo.isNotEmpty
                  ? SnackBarAction(
                      label: 'Open',
                      onPressed: () => ref
                          .read(appRouterProvider)
                          .go(AppRoutePaths.chat(convo)),
                    )
                  : null,
            ),
          );
        },
      );
    } catch (_) {
      // FCM unavailable (e.g. some test environments).
    }
  }
}
