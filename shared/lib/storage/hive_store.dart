import 'package:hive_flutter/hive_flutter.dart';

import '../data/constants.dart';

/// Opens Hive boxes used across both apps.
abstract final class HiveStore {
  static Box<dynamic>? _authBox;
  static Box<dynamic>? _cacheBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _authBox = await Hive.openBox<dynamic>(AppConstants.hiveBoxAuth);
    _cacheBox = await Hive.openBox<dynamic>(AppConstants.hiveBoxCache);
  }

  static Box<dynamic> get auth => _authBox!;
  static Box<dynamic> get cache => _cacheBox!;
}
