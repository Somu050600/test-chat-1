import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'core/constants/env.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS Firebase options not configured yet.');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS Firebase options not configured yet.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows Firebase options not configured yet.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux Firebase options not configured yet.');
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Fuchsia Firebase options not configured yet.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: Env.firebaseAndroidApiKey,
    appId: Env.firebaseAndroidAppId,
    messagingSenderId: Env.firebaseMessagingSenderId,
    projectId: Env.firebaseProjectId,
    storageBucket: Env.firebaseStorageBucket,
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: Env.firebaseWebApiKey,
    authDomain: Env.firebaseWebAuthDomain,
    projectId: Env.firebaseProjectId,
    storageBucket: Env.firebaseStorageBucket,
    messagingSenderId: Env.firebaseMessagingSenderId,
    appId: Env.firebaseWebAppId,
    measurementId: Env.firebaseWebMeasurementId,
  );
}
