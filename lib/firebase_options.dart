import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError('Android Firebase options not configured yet.');
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAnYqf18SvrvKTdQV-5XUTG2T-bDYQp1E4',
    authDomain: 'test-chat-1-ef221.firebaseapp.com',
    projectId: 'test-chat-1-ef221',
    storageBucket: 'test-chat-1-ef221.firebasestorage.app',
    messagingSenderId: '579497868233',
    appId: '1:579497868233:web:1531e99e9e170893844618',
    measurementId: 'G-1EJVRWF64F',
  );
}
