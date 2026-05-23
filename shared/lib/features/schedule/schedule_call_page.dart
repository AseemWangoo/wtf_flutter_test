import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';
import '../../providers/call_providers.dart';
import '../../utils/app_colors.dart';
import '../../utils/scheduler_utils.dart';
import '../../widgets/call_request_tile.dart';
import '../../widgets/day_selector.dart';
import '../../widgets/time_slot_chips.dart';

class ScheduleCallPage extends ConsumerStatefulWidget {
  const ScheduleCallPage({
    super.key,
    required this.member,
    required this.primaryColor,
  });

  final User member;
  final Color primaryColor;

  @override
  ConsumerState<ScheduleCallPage> createState() => _ScheduleCallPageState();
}

class _ScheduleCallPageState extends ConsumerState<ScheduleCallPage> {
  late DateTime _selectedDay;
  DateTime? _selectedSlot;
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = nextThreeDays().first;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a time slot first.')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final trainer = trainerForMember(widget.member);
      final error = await ref.read(scheduleControllerProvider).createRequest(
            member: widget.member,
            trainer: trainer,
            scheduledFor: _selectedSlot!,
            note: _noteController.text,
          );
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ScheduleCopy.requestSent)),
        );
        _noteController.clear();
        setState(() => _selectedSlot = null);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = nextThreeDays();
    final slots = timeSlotsForDay(_selectedDay);
    final requestsAsync = ref.watch(memberRequestsProvider(widget.member.id));
    final trainer = trainerForMember(widget.member);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Call')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pick a day', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          DaySelector(
            days: days,
            selected: _selectedDay,
            primary: widget.primaryColor,
            onSelected: (d) => setState(() {
              _selectedDay = d;
              _selectedSlot = null;
            }),
          ),
          const SizedBox(height: 24),
          Text('Time slots (30 min)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TimeSlotChips(
            slots: slots,
            selected: _selectedSlot,
            primary: widget.primaryColor,
            onSelected: (s) => setState(() => _selectedSlot = s),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _noteController,
            maxLength: 140,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Note for trainer',
              hintText: 'e.g. Macros review',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Request Call'),
          ),
          const SizedBox(height: 32),
          Text('My Requests', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          requestsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
            data: (requests) {
              if (requests.isEmpty) {
                return Text(
                  'No requests yet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral700,
                      ),
                );
              }
              return Column(
                children: requests
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: CallRequestTile(
                          request: r,
                          trainerName: trainer.name,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Upcoming Calls', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...ref.watch(upcomingApprovedProvider(widget.member.id)).map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CallRequestTile(
                    request: r,
                    trainerName: trainer.name,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
