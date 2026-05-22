import '../models/user.dart';

/// Authentication and session persistence (mock OK for assessment).
abstract class AuthService {
  Future<User?> currentUser();
  Future<void> saveUser(User user);
  Future<void> clearSession();
  Future<bool> isOnboardingComplete();
  Future<void> setOnboardingComplete({required bool value});
}
