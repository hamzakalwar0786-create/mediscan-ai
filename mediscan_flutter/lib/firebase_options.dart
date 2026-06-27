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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBPV41JEWhqOOJDOMs0hZwHps0x5iOL0uI',
    appId: '1:701928762388:android:c4c7f3076e23729b9f4b01',
    messagingSenderId: '701928762388',
    projectId: 'dr-med-21ecf',
    storageBucket: 'dr-med-21ecf.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBPV41JEWhqOOJDOMs0hZwHps0x5iOL0uI',
    appId: '1:701928762388:android:c4c7f3076e23729b9f4b01',
    messagingSenderId: '701928762388',
    projectId: 'dr-med-21ecf',
    storageBucket: 'dr-med-21ecf.firebasestorage.app',
  );
}
