import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Hour 0 placeholder home — replaced by onboarding + real home in Hour 1+.
class SetupHomePage extends StatelessWidget {
  const SetupHomePage({
    super.key,
    required this.appLabel,
    required this.roleBadge,
    required this.personaName,
    required this.primary,
  });

  final String appLabel;
  final String roleBadge;
  final String personaName;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$appLabel • $roleBadge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Setup complete', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Persona: $personaName',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const _StatusRow(icon: Icons.check_circle, label: 'Riverpod', color: AppColors.success),
            const _StatusRow(icon: Icons.check_circle, label: 'shared package', color: AppColors.success),
            _StatusRow(
              icon: Icons.check_circle,
              label: 'Brand theme applied',
              color: AppColors.success,
            ),
            const SizedBox(height: 8),
            const _StatusRow(
              icon: Icons.schedule,
              label: 'Auth / Chat / RTC — Hour 1+',
              color: AppColors.warning,
            ),
            const Spacer(),
            Text(
              'Next: onboarding, home tiles, services.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
