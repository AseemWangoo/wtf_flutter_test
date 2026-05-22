import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../home/guru_home_page.dart';
import '../onboarding/onboarding_page.dart';
import '../onboarding/profile_setup_page.dart';

class GuruAppGate extends ConsumerWidget {
  const GuruAppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(guruAuthServiceProvider);
    final onboarding = ref.watch(onboardingCompleteProvider(auth));
    final user = ref.watch(currentUserProvider(auth));

    return onboarding.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (complete) {
        if (!complete) {
          return OnboardingPage(
            onFinished: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const ProfileSetupPage()),
            ),
          );
        }
        return user.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
          data: (u) {
            if (u == null) {
              return const ProfileSetupPage();
            }
            return GuruHomePage(user: u);
          },
        );
      },
    );
  }
}
