import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/seed_data.dart';
import '../../models/call_request.dart';
import '../../models/user.dart';
import '../../providers/call_providers.dart';
import '../../utils/app_colors.dart';
import '../../utils/scheduler_utils.dart';
import '../../widgets/call_request_tile.dart';

class TrainerRequestsPage extends ConsumerWidget {
  const TrainerRequestsPage({
    super.key,
    required this.trainer,
    this.primaryColor = AppColors.trainerPrimary,
  });

  final User trainer;
  final Color primaryColor;

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    CallRequest request,
  ) async {
    final error = await ref.read(scheduleControllerProvider).approve(
          request: request,
          trainer: trainer,
          member: SeedData.dkTemplate,
        );
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ScheduleCopy.approved(request.scheduledFor))),
      );
    }
  }

  Future<void> _decline(
    BuildContext context,
    WidgetRef ref,
    CallRequest request,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => const _DeclineReasonDialog(),
    );
    if (reason == null || reason.trim().isEmpty) return;
    await ref.read(scheduleControllerProvider).decline(
          request: request,
          trainer: trainer,
          member: SeedData.dkTemplate,
          reason: reason.trim(),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ScheduleCopy.declined(reason.trim()))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(trainerRequestsProvider(trainer.id));
    final pending = ref.watch(pendingTrainerRequestsProvider(trainer.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        actions: [
          if (pending.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.error,
                  child: Text(
                    '${pending.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Text(
                'No call requests yet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.neutral700,
                    ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final request = requests[index];
              return CallRequestTile(
                request: request,
                memberName: 'DK',
                showActions: request.status == CallRequestStatus.pending,
                onApprove: () => _approve(context, ref, request),
                onDecline: () => _decline(context, ref, request),
              );
            },
          );
        },
      ),
    );
  }
}

class _DeclineReasonDialog extends StatefulWidget {
  const _DeclineReasonDialog();

  @override
  State<_DeclineReasonDialog> createState() => _DeclineReasonDialogState();
}

class _DeclineReasonDialogState extends State<_DeclineReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decline request'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Reason',
          hintText: 'Let DK know why…',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Decline'),
        ),
      ],
    );
  }
}
