import 'dart:io';

import 'package:shared/shared.dart';

import '../firebase_options.dart';

Future<void> bootstrapGuruApp() async {
  await HiveStore.init();
  final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  const useEmulator = bool.fromEnvironment('USE_FIRESTORE_EMULATOR', defaultValue: true);
  await AppBootstrap.init(
    options: DefaultFirebaseOptions.currentPlatform,
    useEmulator: useEmulator,
    emulatorHost: host,
  );
}
