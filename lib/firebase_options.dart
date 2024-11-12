// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDD2xNyUOhzfsttPLHRl5pd09eGAJ1KzZs',
    appId: '1:900118851677:web:f18ed3e14d6a44f23f9db4',
    messagingSenderId: '900118851677',
    projectId: 'foodservice-5bb53',
    authDomain: 'foodservice-5bb53.firebaseapp.com',
    storageBucket: 'foodservice-5bb53.appspot.com',
    measurementId: 'G-3H5S6M120W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSebpWZjLgaaFJ5RKg4iVOOSivthjiHXs',
    appId: '1:900118851677:android:f9cd91cdb4e210473f9db4',
    messagingSenderId: '900118851677',
    projectId: 'foodservice-5bb53',
    storageBucket: 'foodservice-5bb53.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDLNjnGgwae7w4FDt5J_SNUzimaMyBzCdQ',
    appId: '1:900118851677:ios:58d49775cfd2d7ce3f9db4',
    messagingSenderId: '900118851677',
    projectId: 'foodservice-5bb53',
    storageBucket: 'foodservice-5bb53.appspot.com',
    iosBundleId: 'com.example.foodservice',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDLNjnGgwae7w4FDt5J_SNUzimaMyBzCdQ',
    appId: '1:900118851677:ios:ba66898e861d52fe3f9db4',
    messagingSenderId: '900118851677',
    projectId: 'foodservice-5bb53',
    storageBucket: 'foodservice-5bb53.appspot.com',
    iosBundleId: 'com.example.foodservice.RunnerTests',
  );
}