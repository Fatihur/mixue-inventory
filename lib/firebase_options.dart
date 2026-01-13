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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBvATPT47XbK3QQae1pqR389UaEQl5kCzQ',
    appId: '1:1085417912868:android:26a775b6b0dd01c0e136b1',
    messagingSenderId: '1085417912868',
    projectId: 'mixue-inventory-fdd04',
    storageBucket: 'mixue-inventory-fdd04.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvATPT47XbK3QQae1pqR389UaEQl5kCzQ',
    appId: '1:1085417912868:ios:26a775b6b0dd01c0e136b1',
    messagingSenderId: '1085417912868',
    projectId: 'mixue-inventory-fdd04',
    storageBucket: 'mixue-inventory-fdd04.firebasestorage.app',
    iosBundleId: 'com.mixue.mixueInventory',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBvATPT47XbK3QQae1pqR389UaEQl5kCzQ',
    appId: '1:1085417912868:web:26a775b6b0dd01c0e136b1',
    messagingSenderId: '1085417912868',
    projectId: 'mixue-inventory-fdd04',
    storageBucket: 'mixue-inventory-fdd04.firebasestorage.app',
    authDomain: 'mixue-inventory-fdd04.firebaseapp.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBvATPT47XbK3QQae1pqR389UaEQl5kCzQ',
    appId: '1:1085417912868:ios:26a775b6b0dd01c0e136b1',
    messagingSenderId: '1085417912868',
    projectId: 'mixue-inventory-fdd04',
    storageBucket: 'mixue-inventory-fdd04.firebasestorage.app',
    iosBundleId: 'com.mixue.mixueInventory',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBvATPT47XbK3QQae1pqR389UaEQl5kCzQ',
    appId: '1:1085417912868:web:26a775b6b0dd01c0e136b1',
    messagingSenderId: '1085417912868',
    projectId: 'mixue-inventory-fdd04',
    storageBucket: 'mixue-inventory-fdd04.firebasestorage.app',
    authDomain: 'mixue-inventory-fdd04.firebaseapp.com',
  );
}
