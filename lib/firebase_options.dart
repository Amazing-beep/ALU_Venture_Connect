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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // Real credentials loaded from Firebase JSON & PLIST configurations
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCbYYBlUs4_ghiI9DfFDzLiReJEXQOl7lo',
    appId: '1:829322558865:web:0d35867feae237d206ae30',
    messagingSenderId: '829322558865',
    projectId: 'alu-ventureconnect',
    authDomain: 'alu-ventureconnect.firebaseapp.com',
    storageBucket: 'alu-ventureconnect.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCbYYBlUs4_ghiI9DfFDzLiReJEXQOl7lo',
    appId: '1:829322558865:android:ff2ea8554adcefa906ae30',
    messagingSenderId: '829322558865',
    projectId: 'alu-ventureconnect',
    storageBucket: 'alu-ventureconnect.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCNcRPdGH2HKrzDMA8xWAM-t82XgRDzyug',
    appId: '1:829322558865:ios:0d35867feae237d206ae30',
    messagingSenderId: '829322558865',
    projectId: 'alu-ventureconnect',
    storageBucket: 'alu-ventureconnect.firebasestorage.app',
    iosBundleId: 'com.alu.ventureconnect',
  );
}
