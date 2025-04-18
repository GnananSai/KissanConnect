// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA86s1s-VEHJJ4luMyWxRYSooHe15H4opI',
    appId: '1:262926712996:web:96aedd7dac9e81c7e22631',
    messagingSenderId: '262926712996',
    projectId: 'kisaanconnect',
    authDomain: 'kisaanconnect-db170.firebaseapp.com',
    storageBucket: 'kisaanconnect.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJL1j4Q5ECIAgnRK27QflcUk8YpcZvSTk',
    appId: '1:262926712996:android:2cd289ad8c89140ce22631',
    messagingSenderId: '262926712996',
    projectId: 'kisaanconnect',
    storageBucket: 'kisaanconnect.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBI-imQdDN1vb5yN13HiOsy9VzCgjzRQ3g',
    appId: '1:262926712996:ios:5a2e3904eba95d02e22631',
    messagingSenderId: '262926712996',
    projectId: 'kisaanconnect',
    storageBucket: 'kisaanconnect.firebasestorage.app',
    iosBundleId: 'com.example.kissanconnect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBI-imQdDN1vb5yN13HiOsy9VzCgjzRQ3g',
    appId: '1:262926712996:ios:5a2e3904eba95d02e22631',
    messagingSenderId: '262926712996',
    projectId: 'kisaanconnect',
    storageBucket: 'kisaanconnect.firebasestorage.app',
    iosBundleId: 'com.example.kissanconnect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA86s1s-VEHJJ4luMyWxRYSooHe15H4opI',
    appId: '1:262926712996:web:05b7491045ae5aace22631',
    messagingSenderId: '262926712996',
    projectId: 'kisaanconnect',
    authDomain: 'kisaanconnect-db170.firebaseapp.com',
    storageBucket: 'kisaanconnect.firebasestorage.app',
  );
}
