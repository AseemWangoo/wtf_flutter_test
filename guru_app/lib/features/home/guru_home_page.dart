import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class GuruHomePage extends StatelessWidget {
  const GuruHomePage({super.key, required this.user});

  final User user;

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming in Hour 4+')),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(
          currentUser: user,
          peer: SeedData.aarav,
          chatId: AppConstants.dkAaravChatId,
        ),
      ),
    );
  }

  void _openSchedule(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScheduleCallPage(
          member: user,
          primaryColor: AppColors.guruPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trainer = SeedData.aarav;
    return Scaffold(
      appBar: AppBar(
        title: Text('Guru • ${user.name}'),
      ),
      body: Column(
        children: [
          const FirebaseBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Hi, ${user.name} 👋',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Trainer: ${trainer.name}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral700,
                      ),
                ),
                const SizedBox(height: 24),
                HomeCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'Chat with Trainer',
                  subtitle: 'Message ${trainer.name}',
                  primary: AppColors.guruPrimary,
                  onTap: () => _openChat(context),
                ),
                const SizedBox(height: 12),
                HomeCard(
                  icon: Icons.video_call_outlined,
                  title: 'Schedule Call',
                  subtitle: 'Book a 30-minute session',
                  primary: AppColors.guruPrimary,
                  onTap: () => _openSchedule(context),
                ),
                const SizedBox(height: 12),
                HomeCard(
                  icon: Icons.history,
                  title: 'My Sessions',
                  subtitle: 'View session logs and ratings',
                  primary: AppColors.guruPrimary,
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
