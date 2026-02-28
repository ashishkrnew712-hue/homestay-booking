// File generated manually based on Firebase Console configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByUoygA5LkrfIE1KiT5qn3Bs6hhYJCxMc',
    appId: '1:942257263979:android:1e0985446c67ec705ea82e',
    messagingSenderId: '942257263979',
    projectId: 'homestay-booking-81ab9',
    storageBucket: 'homestay-booking-81ab9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUufae3M8IFmSj0AyIZd9WqXc6k05xLHo',
    appId: '1:942257263979:ios:eaccf40c9ae724435ea82e',
    messagingSenderId: '942257263979',
    projectId: 'homestay-booking-81ab9',
    storageBucket: 'homestay-booking-81ab9.firebasestorage.app',
    iosBundleId: 'com.homestay.booking',
  );
}
