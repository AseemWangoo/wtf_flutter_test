import '../models/call_request.dart';
import '../models/room_meta.dart';

/// Call scheduling and 100ms room lifecycle.
abstract class CallService {
  Stream<List<CallRequest>> watchRequests({String? trainerId, String? memberId});
  Future<CallRequest> createRequest(CallRequest request);
  Future<CallRequest> updateRequest(CallRequest request);
  Future<RoomMeta?> roomForRequest(String callRequestId);
  Future<RoomMeta> createRoomOnApprove(CallRequest request);
}
