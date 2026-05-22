import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

class TrainerLoginPage extends ConsumerWidget {
  const TrainerLoginPage({super.key});

  Future<void> _login(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(trainerAuthServiceProvider);
    await auth.saveUser(SeedData.aarav);
    await auth.setOnboardingComplete(value: true);
    ref.invalidate(currentUserProvider(auth));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.sports_martial_arts, size: 80, color: AppColors.trainerPrimary),
              const SizedBox(height: 24),
              Text(
                'Trainer App',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Lead Trainer • Aarav',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.neutral700,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _login(context, ref),
                child: const Text('Continue as Aarav'),
              ),
              const SizedBox(height: 8),
              Text(
                'Mock login for assessment demo',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.neutral700,
                    ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
