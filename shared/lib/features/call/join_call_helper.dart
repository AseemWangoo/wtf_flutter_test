import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/rtc_config.dart';
import '../../models/call_request.dart';
import '../../models/user.dart';
import '../../providers/call_providers.dart';
import '../../providers/service_providers.dart';
import '../../utils/join_call_utils.dart';
import 'call_flow_page.dart';

/// Opens the 100ms call flow for an approved [request].
Future<void> openCallFlow({
  required BuildContext context,
  required WidgetRef ref,
  required User currentUser,
  required User peer,
  required CallRequest request,
}) async {
  if (!canJoinCall(request)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Join opens 10 minutes before the scheduled time.'),
      ),
    );
    return;
  }

  final callService = ref.read(callServiceProvider);
  final roomMeta = await callService.roomForRequest(request.id);
  final roomId = RtcConfig.devRoomId.isNotEmpty
      ? RtcConfig.devRoomId
      : (roomMeta?.hmsRoomId ?? request.id);

  if (!context.mounted) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => CallFlowPage(
        currentUser: currentUser,
        peer: peer,
        callRequest: request,
        roomId: roomId,
      ),
    ),
  );
}

/// First joinable approved call for [userId], if any.
CallRequest? joinableCallForUser(WidgetRef ref, String userId) {
  final upcoming = ref.watch(upcomingApprovedProvider(userId));
  for (final request in upcoming) {
    if (canJoinCall(request)) return request;
  }
  return null;
}
