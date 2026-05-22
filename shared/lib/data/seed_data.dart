import '../models/user.dart';
import 'constants.dart';

/// Pre-seeded personas for assessment manual test (DK + Aarav).
abstract final class SeedData {
  static const User aarav = User(
    id: AppConstants.aaravUserId,
    role: UserRole.trainer,
    name: 'Aarav (Lead Trainer)',
    email: 'aarav@wtf.guru',
    avatarUrl: null,
  );

  static const User dkTemplate = User(
    id: AppConstants.dkUserId,
    role: UserRole.member,
    name: 'DK',
    email: 'dk@wtf.guru',
    avatarUrl: null,
    assignedTrainerId: AppConstants.aaravUserId,
  );

  static const List<User> trainers = [aarav];

  static User dkWithTrainer() => dkTemplate;
}
