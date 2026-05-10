import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class StagingFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        return web;
      default:
        throw UnsupportedError('Staging Firebase options are configured for web.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCyujGB3yc6xs76iPQsDkbpurpRNRnfWkc',
    appId: '1:953622862684:web:26ff95eb717266180d3f99',
    messagingSenderId: '953622862684',
    projectId: 'patimatch-staging',
    authDomain: 'patimatch-staging.firebaseapp.com',
    storageBucket: 'patimatch-staging.firebasestorage.app',
    measurementId: 'G-BYRB25617B',
  );
}

