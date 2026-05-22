import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class TrainerHomePage extends StatelessWidget {
  const TrainerHomePage({super.key, required this.user});

  final User user;

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming in Hour 2+')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer • ${user.name}'),
      ),
      body: Column(
        children: [
          const FirebaseBanner(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _Tile(
                  icon: Icons.people_outline,
                  label: 'Members',
                  color: AppColors.trainerPrimary,
                  onTap: () => _comingSoon(context, 'Members'),
                ),
                _Tile(
                  icon: Icons.chat_outlined,
                  label: 'Chats',
                  color: AppColors.trainerPrimary,
                  onTap: () => _comingSoon(context, 'Chats'),
                ),
                _Tile(
                  icon: Icons.event_available_outlined,
                  label: 'Requests',
                  color: AppColors.trainerPrimary,
                  onTap: () => _comingSoon(context, 'Requests'),
                ),
                _Tile(
                  icon: Icons.history,
                  label: 'Sessions',
                  color: AppColors.trainerPrimary,
                  onTap: () => _comingSoon(context, 'Sessions'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
