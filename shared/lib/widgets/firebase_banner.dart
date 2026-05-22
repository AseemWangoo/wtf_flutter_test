import 'package:flutter/material.dart';

import '../firebase/app_bootstrap.dart';
import '../utils/app_colors.dart';

class FirebaseBanner extends StatelessWidget {
  const FirebaseBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppBootstrap.firebaseReady) return const SizedBox.shrink();
    return MaterialBanner(
      backgroundColor: AppColors.warning.withValues(alpha: 0.15),
      content: const Text(
        'Firestore offline — start Firebase Emulator or run flutterfire configure.',
      ),
      actions: [
        TextButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('See README → Firebase Emulator setup'),
            ),
          ),
          child: const Text('Help'),
        ),
      ],
    );
  }
}
