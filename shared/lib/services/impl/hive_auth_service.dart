import 'package:shared_preferences/shared_preferences.dart';

import '../../data/constants.dart';
import '../../models/user.dart';
import '../../storage/hive_store.dart';
import '../auth_service.dart';

class HiveAuthService implements AuthService {
  HiveAuthService(this._prefsKey);

  final String _prefsKey;

  static const _currentUserKey = 'current_user';

  @override
  Future<User?> currentUser() async {
    final raw = HiveStore.auth.get(_currentUserKey);
    if (raw is! Map) return null;
    return User.fromJson(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> saveUser(User user) async {
    await HiveStore.auth.put(_currentUserKey, user.toJson());
  }

  @override
  Future<void> clearSession() async {
    await HiveStore.auth.delete(_currentUserKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  @override
  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  @override
  Future<void> setOnboardingComplete({required bool value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }
}

/// App-specific prefs keys.
abstract final class AuthPrefsKeys {
  static const guru = '${AppConstants.prefsOnboardingPrefix}guru';
  static const trainer = '${AppConstants.prefsOnboardingPrefix}trainer';
}
