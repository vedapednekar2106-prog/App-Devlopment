import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyDLqv_zXBN-TothvsZ954OkgrJp3_iIf58",
      appId: "1:704406418314:android:98c8567cf2e16975c00e73",
      messagingSenderId: "704406418314",
      projectId: "firecalculator-31a59",
    );
  }
}
