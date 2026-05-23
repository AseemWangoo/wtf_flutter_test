import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/constants.dart';
import '../../models/user.dart';
import '../../providers/member_providers.dart';
import '../../utils/app_colors.dart';
import '../../widgets/member_tile.dart';
import '../chat/conversation_page.dart';
import '../schedule/trainer_requests_page.dart';

/// Trainer CRM — assigned members with session stats and quick actions.
class MembersPage extends ConsumerWidget {
  const MembersPage({
    super.key,
    required this.trainer,
    required this.primaryColor,
  });

  final User trainer;
  final Color primaryColor;

  void _openChat(BuildContext context, User member) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(
          currentUser: trainer,
          peer: member,
          chatId: AppConstants.dkAaravChatId,
        ),
      ),
    );
  }

  void _openRequests(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrainerRequestsPage(trainer: trainer),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(memberSummariesProvider(trainer));

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: summaries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No members assigned yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.neutral700,
                      ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: summaries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final summary = summaries[index];
                return MemberTile(
                  summary: summary,
                  primary: primaryColor,
                  onMessage: () => _openChat(context, summary.member),
                  onSchedule: () => _openRequests(context),
                );
              },
            ),
    );
  }
}
