import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return android; // Fallback ke android config
      case TargetPlatform.macOS:
        return android;
      case TargetPlatform.windows:
        return android;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for fuchsia.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJ0WPummCRowgmX_i8jIUszAzcbWeOfhQ',
    appId: '1:507554543615:android:8bf1a732ae0ecd0f3b19ca',
    messagingSenderId: '507554543615',
    projectId: 'habitly-app-20bd0',
    storageBucket: 'habitly-app-20bd0.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCJ0WPummCRowgmX_i8jIUszAzcbWeOfhQ',
    appId: '1:507554543615:android:8bf1a732ae0ecd0f3b19ca',
    messagingSenderId: '507554543615',
    projectId: 'habitly-app-20bd0',
    storageBucket: 'habitly-app-20bd0.firebasestorage.app',
  );
}
