import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/seed_data.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/call_service.dart';
import '../services/chat_service.dart';
import '../services/impl/firestore_call_service.dart';
import '../services/impl/firestore_chat_service.dart';
import '../services/impl/hive_auth_service.dart';
import '../services/impl/hive_log_service.dart';
import '../services/log_service.dart';

/// Guru app auth (member DK).
final guruAuthServiceProvider = Provider<AuthService>(
  (ref) => HiveAuthService(AuthPrefsKeys.guru),
);

/// Trainer app auth (Aarav).
final trainerAuthServiceProvider = Provider<AuthService>(
  (ref) => HiveAuthService(AuthPrefsKeys.trainer),
);

final chatServiceProvider = Provider<ChatService>((ref) => FirestoreChatService());

final callServiceProvider = Provider<CallService>((ref) => FirestoreCallService());

final logServiceProvider = Provider<LogService>((ref) => HiveLogService());

final currentUserProvider = FutureProvider.family<User?, AuthService>(
  (ref, auth) => auth.currentUser(),
);

final onboardingCompleteProvider = FutureProvider.family<bool, AuthService>(
  (ref, auth) => auth.isOnboardingComplete(),
);

final seedTrainersProvider = Provider<List<User>>((ref) => SeedData.trainers);
