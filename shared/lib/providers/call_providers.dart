import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/constants.dart';
import '../data/seed_data.dart';
import '../models/call_request.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../utils/scheduler_utils.dart';
import 'service_providers.dart';

final _uuid = const Uuid();

final memberRequestsProvider = StreamProvider.family<List<CallRequest>, String>(
  (ref, memberId) =>
      ref.watch(callServiceProvider).watchRequests(memberId: memberId),
);

final trainerRequestsProvider = StreamProvider.family<List<CallRequest>, String>(
  (ref, trainerId) =>
      ref.watch(callServiceProvider).watchRequests(trainerId: trainerId),
);

final pendingTrainerRequestsProvider = Provider.family<List<CallRequest>, String>(
  (ref, trainerId) {
    final requests = ref.watch(trainerRequestsProvider(trainerId)).valueOrNull ?? [];
    return requests.where((r) => r.status == CallRequestStatus.pending).toList();
  },
);

final upcomingApprovedProvider = Provider.family<List<CallRequest>, String>(
  (ref, userId) {
    final asMember = ref.watch(memberRequestsProvider(userId)).valueOrNull ?? [];
    final asTrainer = ref.watch(trainerRequestsProvider(userId)).valueOrNull ?? [];
    final all = {...asMember, ...asTrainer}.toList();
    final now = DateTime.now();
    return all
        .where(
          (r) =>
              r.status == CallRequestStatus.approved &&
              r.scheduledFor.isAfter(now.subtract(const Duration(minutes: 30))),
        )
        .toList()
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
  },
);

class ScheduleController {
  ScheduleController(this._ref);

  final Ref _ref;

  Future<String?> createRequest({
    required User member,
    required User trainer,
    required DateTime scheduledFor,
    String? note,
  }) async {
    if (!isValidScheduleSlot(scheduledFor)) {
      return 'Cannot schedule a time in the past.';
    }

    final trainerRequests =
        await _ref.read(callServiceProvider).watchRequests(trainerId: trainer.id).first;
    final approved = approvedSlotsFrom(trainerRequests);
    if (hasScheduleConflict(scheduledFor, approved)) {
      return 'This slot is already booked. Pick another time.';
    }

    final pendingSameSlot = trainerRequests.any(
      (r) =>
          r.status == CallRequestStatus.pending &&
          r.scheduledFor.difference(scheduledFor).abs() < const Duration(minutes: 30),
    );
    if (pendingSameSlot) {
      return 'You already have a pending request for this slot.';
    }

    final request = CallRequest(
      id: _uuid.v4(),
      memberId: member.id,
      trainerId: trainer.id,
      requestedAt: DateTime.now(),
      scheduledFor: scheduledFor,
      note: note?.trim().isEmpty ?? true ? null : note!.trim(),
    );

    await _ref.read(callServiceProvider).createRequest(request);
    return null;
  }

  Future<String?> approve({
    required CallRequest request,
    required User trainer,
    required User member,
  }) async {
    final trainerRequests =
        await _ref.read(callServiceProvider).watchRequests(trainerId: trainer.id).first;
    final approved = approvedSlotsFrom(
      trainerRequests.where((r) => r.id != request.id).toList(),
    );
    if (hasScheduleConflict(request.scheduledFor, approved)) {
      return 'Slot conflict — another call is already approved at this time.';
    }

    final updated = request.copyWith(status: CallRequestStatus.approved);
    await _ref.read(callServiceProvider).updateRequest(updated);
    await _ref.read(callServiceProvider).createRoomOnApprove(updated);
    await _postSystemMessage(
      sender: trainer,
      receiver: member,
      text: ScheduleCopy.approved(request.scheduledFor),
    );
    return null;
  }

  Future<void> decline({
    required CallRequest request,
    required User trainer,
    required User member,
    required String reason,
  }) async {
    final updated = request.copyWith(
      status: CallRequestStatus.declined,
      declineReason: reason.trim(),
    );
    await _ref.read(callServiceProvider).updateRequest(updated);
    await _postSystemMessage(
      sender: trainer,
      receiver: member,
      text: ScheduleCopy.declined(reason.trim()),
    );
  }

  Future<void> _postSystemMessage({
    required User sender,
    required User receiver,
    required String text,
  }) async {
    final chat = _ref.read(chatServiceProvider);
    final message = Message(
      id: _uuid.v4(),
      chatId: AppConstants.dkAaravChatId,
      senderId: sender.id,
      receiverId: receiver.id,
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.sent,
      isSystem: true,
    );
    await chat.sendMessage(message);
  }
}

final scheduleControllerProvider = Provider<ScheduleController>(
  (ref) => ScheduleController(ref),
);

/// Resolved trainer for DK (from assignment or seed).
User trainerForMember(User member) {
  if (member.assignedTrainerId == AppConstants.aaravUserId) {
    return SeedData.aarav;
  }
  return SeedData.aarav;
}
