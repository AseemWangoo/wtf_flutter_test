import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint('[AUTH] Firebase initialized (emulator=$useEmulator)');
    } catch (e, st) {
      firebaseReady = false;
      debugPrint('[AUTH] Firebase init failed: $e\n$st');
    }
  }
}
