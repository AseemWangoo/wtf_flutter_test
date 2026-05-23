import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session_log.dart';
import '../models/user.dart';
import 'service_providers.dart';

final sessionLogsProvider = StreamProvider.family<List<SessionLog>, User>(
  (ref, user) {
    final service = ref.watch(logServiceProvider);
    if (user.role == UserRole.member) {
      return service.watchLogs(memberId: user.id);
    }
    return service.watchLogs(trainerId: user.id);
  },
);
