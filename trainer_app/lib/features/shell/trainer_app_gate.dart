import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../auth/trainer_login_page.dart';
import '../home/trainer_home_page.dart';

class TrainerAppGate extends ConsumerWidget {
  const TrainerAppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(trainerAuthServiceProvider);
    final user = ref.watch(currentUserProvider(auth));

    return user.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (u) {
        if (u == null) {
          return const TrainerLoginPage();
        }
        return TrainerHomePage(user: u);
      },
    );
  }
}
