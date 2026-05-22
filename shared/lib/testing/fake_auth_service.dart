import '../models/user.dart';
import '../services/auth_service.dart';

/// In-memory auth for widget tests (avoids SharedPreferences platform channel).
class FakeAuthService implements AuthService {
  FakeAuthService({this.onboardingComplete = false, this.user});

  bool onboardingComplete;
  User? user;

  @override
  Future<void> clearSession() async {
    onboardingComplete = false;
    user = null;
  }

  @override
  Future<User?> currentUser() async => user;

  @override
  Future<bool> isOnboardingComplete() async => onboardingComplete;

  @override
  Future<void> saveUser(User user) async {
    this.user = user;
  }

  @override
  Future<void> setOnboardingComplete({required bool value}) async {
    onboardingComplete = value;
  }
}
