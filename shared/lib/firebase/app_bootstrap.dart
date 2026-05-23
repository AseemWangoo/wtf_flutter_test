import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../utils/dev_log.dart';

/// Initializes Firebase and optionally points Firestore at the local emulator.
abstract final class AppBootstrap {
  static bool firebaseReady = false;

  static Future<void> init({
    required FirebaseOptions options,
    bool useEmulator = true,
    String emulatorHost = '10.0.2.2',
    int emulatorPort = 8080,
  }) async {
    try {
      await Firebase.initializeApp(options: options);
      if (useEmulator) {
        FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, emulatorPort);
      }
      firebaseReady = true;
      DevLog.log('AUTH', 'Firebase initialized (emulator=$useEmulator)');
    } catch (e, st) {
      firebaseReady = false;
      DevLog.log('AUTH', 'Firebase init failed: $e\n$st');
    }
  }
}
