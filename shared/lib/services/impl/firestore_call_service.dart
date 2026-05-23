import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../config/rtc_config.dart';
import '../../data/constants.dart';
import '../../firebase/app_bootstrap.dart';
import '../../models/call_request.dart';
import '../../models/room_meta.dart';
import '../call_service.dart';

class FirestoreCallService implements CallService {
  FirestoreCallService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection(AppConstants.firestoreCallRequests);

  @override
  Stream<List<CallRequest>> watchRequests({String? trainerId, String? memberId}) {
    if (!AppBootstrap.firebaseReady) {
      return Stream.value(const []);
    }
    Query<Map<String, dynamic>> q = _requests.orderBy('requestedAt', descending: true);
    if (trainerId != null) {
      q = q.where('trainerId', isEqualTo: trainerId);
    }
    if (memberId != null) {
      q = q.where('memberId', isEqualTo: memberId);
    }
    return q.snapshots().map(
          (snap) => snap.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return CallRequest.fromJson(data);
          }).toList(),
        );
  }

  @override
  Future<CallRequest> createRequest(CallRequest request) async {
    if (!AppBootstrap.firebaseReady) {
      debugPrint('[SCHEDULE] Firebase offline — request stored locally only');
      return request;
    }
    await _requests.doc(request.id).set(request.toJson());
    return request;
  }

  @override
  Future<CallRequest> updateRequest(CallRequest request) async {
    if (!AppBootstrap.firebaseReady) return request;
    await _requests.doc(request.id).update(request.toJson());
    return request;
  }

  @override
  Future<RoomMeta?> roomForRequest(String callRequestId) async {
    if (!AppBootstrap.firebaseReady) return null;
    final doc = await _db
        .collection('room_meta')
        .where('callRequestId', isEqualTo: callRequestId)
        .limit(1)
        .get();
    if (doc.docs.isEmpty) return null;
    final data = doc.docs.first.data();
    data['id'] = doc.docs.first.id;
    return RoomMeta.fromJson(data);
  }

  @override
  Future<RoomMeta> createRoomOnApprove(CallRequest request) async {
    final roomId =
        RtcConfig.devRoomId.isNotEmpty ? RtcConfig.devRoomId : request.id;
    final meta = RoomMeta(
      id: _uuid.v4(),
      callRequestId: request.id,
      hmsRoomId: roomId,
      hmsRoleMember: 'guest',
      hmsRoleTrainer: 'host',
    );
    if (AppBootstrap.firebaseReady) {
      await _db.collection('room_meta').doc(meta.id).set(meta.toJson());
    }
    return meta;
  }
}
