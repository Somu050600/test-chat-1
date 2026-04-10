import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'bootstrap/messaging_bootstrap.dart';
import 'firebase_background.dart';
import 'bootstrap/user_profile_listener.dart';
import 'core/constants/app_strings.dart';
import 'firebase_options.dart';
import 'providers/app_router_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // google_sign_in 7.x requires a single initialize() before any other calls.
  await GoogleSignIn.instance.initialize(
    clientId: kIsWeb ? DefaultFirebaseOptions.webClientId : null,
  );

  runApp(
    const ProviderScope(
      child: UserProfileListener(
        child: ChatApp(),
      ),
    ),
  );
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: AppStrings.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
      builder: (context, child) {
        return MessagingBootstrap(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
