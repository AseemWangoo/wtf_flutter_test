import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../../models/call_request.dart';
import '../../models/session_log.dart';
import '../../models/user.dart';
import '../../providers/service_providers.dart';
import '../../services/hms_token_client.dart';
import '../../utils/app_colors.dart';
import '../../utils/join_call_utils.dart';
import '../../utils/scheduler_utils.dart';
import '../../widgets/video_tile.dart';

/// Pre-join → in-call → post-call flow for an approved [CallRequest].
class CallFlowPage extends ConsumerStatefulWidget {
  const CallFlowPage({
    super.key,
    required this.currentUser,
    required this.peer,
    required this.callRequest,
    required this.roomId,
  });

  final User currentUser;
  final User peer;
  final CallRequest callRequest;
  final String roomId;

  @override
  ConsumerState<CallFlowPage> createState() => _CallFlowPageState();
}

enum _CallPhase { loading, preJoin, inCall, reconnecting, postCall, error }

class _CallFlowPageState extends ConsumerState<CallFlowPage>
    implements HMSUpdateListener, HMSPreviewListener {
  final _tokenClient = HmsTokenClient();
  final _uuid = const Uuid();

  HMSSDK? _hmsSdk;
  HMSConfig? _config;
  _CallPhase _phase = _CallPhase.loading;
  String? _error;

  HMSVideoTrack? _localVideo;
  HMSVideoTrack? _remoteVideo;
  String? _remoteName;
  bool _micOn = true;
  bool _camOn = true;

  DateTime? _startedAt;
  DateTime? _endedAt;
  int _rating = 5;
  final _memberNotesController = TextEditingController();
  final _trainerNotesController = TextEditingController();

  bool get _isTrainer => widget.currentUser.role == UserRole.trainer;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await _requestPermissions();
      await _initSdk();
      final token = await _tokenClient.fetchToken(
        userId: widget.currentUser.id,
        role: hmsRoleParamFor(widget.currentUser.role),
        roomId: widget.roomId,
      );
      _config = HMSConfig(
        authToken: token,
        userName: widget.currentUser.name,
      );
      await _hmsSdk!.preview(config: _config!);
    } catch (e) {
      if (mounted) {
        setState(() {
          _phase = _CallPhase.error;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _initSdk() async {
    _hmsSdk = HMSSDK();
    await _hmsSdk!.build();
    _hmsSdk!.addPreviewListener(listener: this);
    _hmsSdk!.addUpdateListener(listener: this);
  }

  HMSVideoTrack? _videoFromTracks(List<HMSTrack> tracks) {
    for (final track in tracks) {
      if (track is HMSVideoTrack && track.source == 'REGULAR') {
        return track;
      }
    }
    return null;
  }

  void _syncRemoteFromRoom(HMSRoom room) {
    for (final peer in room.peers ?? []) {
      if (peer.isLocal) {
        _localVideo = peer.videoTrack;
      } else {
        _remoteVideo = peer.videoTrack;
        _remoteName = peer.name;
      }
    }
  }

  Future<void> _joinRoom() async {
    if (_config == null || _hmsSdk == null) return;
    setState(() => _phase = _CallPhase.loading);
    _startedAt = DateTime.now();
    _hmsSdk!.removePreviewListener(listener: this);
    await _hmsSdk!.join(config: _config!);
  }

  Future<void> _toggleMic() async {
    await _hmsSdk?.toggleMicMuteState();
    setState(() => _micOn = !_micOn);
  }

  Future<void> _toggleCam() async {
    await _hmsSdk?.toggleCameraMuteState();
    setState(() => _camOn = !_camOn);
  }

  Future<void> _flipCamera() async {
    await _hmsSdk?.switchCamera();
  }

  Future<void> _endCall() async {
    _endedAt = DateTime.now();
    await _hmsSdk?.leave();
    if (mounted) setState(() => _phase = _CallPhase.postCall);
  }

  Future<void> _finishPostCall() async {
    final start = _startedAt ?? DateTime.now();
    final end = _endedAt ?? DateTime.now();
    final memberId = widget.currentUser.role == UserRole.member
        ? widget.currentUser.id
        : widget.peer.id;
    final trainerId = widget.currentUser.role == UserRole.trainer
        ? widget.currentUser.id
        : widget.peer.id;

    await ref.read(logServiceProvider).saveLog(
          SessionLog(
            id: _uuid.v4(),
            memberId: memberId,
            trainerId: trainerId,
            startedAt: start,
            endedAt: end,
            durationSec: sessionDurationSec(start, end),
            rating: _isTrainer ? null : _rating,
            memberNotes:
                _isTrainer ? null : _memberNotesController.text.trim().isEmpty
                    ? null
                    : _memberNotesController.text.trim(),
            trainerNotes: _isTrainer
                ? (_trainerNotesController.text.trim().isEmpty
                    ? null
                    : _trainerNotesController.text.trim())
                : null,
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session saved to your logs.')),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _memberNotesController.dispose();
    _trainerNotesController.dispose();
    _hmsSdk?.removePreviewListener(listener: this);
    _hmsSdk?.removeUpdateListener(listener: this);
    _hmsSdk?.leave();
    super.dispose();
  }

  // --- HMSPreviewListener ---
  @override
  void onPreview({required HMSRoom room, required List<HMSTrack> localTracks}) {
    _localVideo = _videoFromTracks(localTracks);
    if (mounted) setState(() => _phase = _CallPhase.preJoin);
  }

  @override
  void onHMSError({required HMSException error}) {
    if (mounted) {
      setState(() {
        _phase = _CallPhase.error;
        _error = error.message ?? 'Call error';
      });
    }
  }

  // --- HMSUpdateListener ---
  @override
  void onJoin({required HMSRoom room}) {
    _syncRemoteFromRoom(room);
    if (mounted) setState(() => _phase = _CallPhase.inCall);
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (peer.isLocal) {
      _localVideo = peer.videoTrack;
    } else {
      _remoteVideo = peer.videoTrack;
      _remoteName = peer.name;
    }
    if (mounted) setState(() {});
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    if (track is! HMSVideoTrack || track.source != 'REGULAR') return;
    if (peer.isLocal) {
      _localVideo = track;
    } else {
      _remoteVideo = track;
      _remoteName = peer.name;
    }
    if (mounted) setState(() {});
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onReconnecting() {
    if (mounted) setState(() => _phase = _CallPhase.reconnecting);
  }

  @override
  void onReconnected() {
    if (mounted) setState(() => _phase = _CallPhase.inCall);
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onChangeTrackStateRequest({
    required HMSTrackChangeRequest hmsTrackChangeRequest,
  }) {}

  @override
  void onRemovedFromRoom({
    required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
  }) {
    _endCall();
  }

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral900,
      appBar: AppBar(
        title: Text(_phase == _CallPhase.preJoin ? 'Pre-join' : 'Video Call'),
        backgroundColor: AppColors.neutral900,
        foregroundColor: Colors.white,
      ),
      body: switch (_phase) {
        _CallPhase.loading => const Center(child: CircularProgressIndicator()),
        _CallPhase.error => _ErrorBody(message: _error ?? 'Unknown error'),
        _CallPhase.preJoin => _PreJoinBody(
            localTrack: _localVideo,
            userName: widget.currentUser.name,
            micOn: _micOn,
            camOn: _camOn,
            onToggleMic: _toggleMic,
            onToggleCam: _toggleCam,
            onFlip: _flipCamera,
            onJoin: _joinRoom,
          ),
        _CallPhase.inCall || _CallPhase.reconnecting => _InCallBody(
            localTrack: _localVideo,
            remoteTrack: _remoteVideo,
            localName: widget.currentUser.name,
            remoteName: _remoteName ?? widget.peer.name,
            micOn: _micOn,
            camOn: _camOn,
            reconnecting: _phase == _CallPhase.reconnecting,
            isTrainer: _isTrainer,
            onToggleMic: _toggleMic,
            onToggleCam: _toggleCam,
            onFlip: _flipCamera,
            onEnd: _endCall,
          ),
        _CallPhase.postCall => _PostCallBody(
            isTrainer: _isTrainer,
            rating: _rating,
            onRatingChanged: (v) => setState(() => _rating = v),
            memberNotesController: _memberNotesController,
            trainerNotesController: _trainerNotesController,
            onDone: _finishPostCall,
          ),
      },
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreJoinBody extends StatelessWidget {
  const _PreJoinBody({
    required this.localTrack,
    required this.userName,
    required this.micOn,
    required this.camOn,
    required this.onToggleMic,
    required this.onToggleCam,
    required this.onFlip,
    required this.onJoin,
  });

  final HMSVideoTrack? localTrack;
  final String userName;
  final bool micOn;
  final bool camOn;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCam;
  final VoidCallback onFlip;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Ready to join? Check mic and camera.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VideoTile(label: userName, track: localTrack, mirror: true),
          ),
        ),
        _ControlBar(
          micOn: micOn,
          camOn: camOn,
          showFlip: true,
          showEnd: false,
          onToggleMic: onToggleMic,
          onToggleCam: onToggleCam,
          onFlip: onFlip,
          onEnd: () {},
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: onJoin,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.success,
            ),
            child: const Text('Join Call'),
          ),
        ),
      ],
    );
  }
}

class _InCallBody extends StatelessWidget {
  const _InCallBody({
    required this.localTrack,
    required this.remoteTrack,
    required this.localName,
    required this.remoteName,
    required this.micOn,
    required this.camOn,
    required this.reconnecting,
    required this.isTrainer,
    required this.onToggleMic,
    required this.onToggleCam,
    required this.onFlip,
    required this.onEnd,
  });

  final HMSVideoTrack? localTrack;
  final HMSVideoTrack? remoteTrack;
  final String localName;
  final String remoteName;
  final bool micOn;
  final bool camOn;
  final bool reconnecting;
  final bool isTrainer;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCam;
  final VoidCallback onFlip;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: VideoTile(label: remoteName, track: remoteTrack),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: VideoTile(
                  label: localName,
                  track: localTrack,
                  mirror: true,
                ),
              ),
            ],
          ),
        ),
        if (reconnecting)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Reconnecting…', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _ControlBar(
            micOn: micOn,
            camOn: camOn,
            showFlip: true,
            showEnd: true,
            endLabel: isTrainer ? 'End Call' : 'Leave',
            onToggleMic: onToggleMic,
            onToggleCam: onToggleCam,
            onFlip: onFlip,
            onEnd: onEnd,
          ),
        ),
      ],
    );
  }
}

class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.micOn,
    required this.camOn,
    required this.showFlip,
    required this.showEnd,
    required this.onToggleMic,
    required this.onToggleCam,
    required this.onFlip,
    required this.onEnd,
    this.endLabel = 'End',
  });

  final bool micOn;
  final bool camOn;
  final bool showFlip;
  final bool showEnd;
  final String endLabel;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCam;
  final VoidCallback onFlip;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RoundBtn(
            icon: micOn ? Icons.mic : Icons.mic_off,
            label: micOn ? 'Mute' : 'Unmute',
            onTap: onToggleMic,
          ),
          _RoundBtn(
            icon: camOn ? Icons.videocam : Icons.videocam_off,
            label: camOn ? 'Video off' : 'Video on',
            onTap: onToggleCam,
          ),
          if (showFlip)
            _RoundBtn(icon: Icons.cameraswitch, label: 'Flip', onTap: onFlip),
          if (showEnd)
            _RoundBtn(
              icon: Icons.call_end,
              label: endLabel,
              color: AppColors.error,
              onTap: onEnd,
            ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  const _RoundBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(
          onPressed: onTap,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: color ?? AppColors.neutral700,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _PostCallBody extends StatelessWidget {
  const _PostCallBody({
    required this.isTrainer,
    required this.rating,
    required this.onRatingChanged,
    required this.memberNotesController,
    required this.trainerNotesController,
    required this.onDone,
  });

  final bool isTrainer;
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final TextEditingController memberNotesController;
  final TextEditingController trainerNotesController;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isTrainer ? 'Add session notes' : 'Rate your session',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          if (!isTrainer) ...[
            Text('Rating', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
            Slider(
              value: rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$rating ★',
              onChanged: (v) => onRatingChanged(v.round()),
            ),
            TextField(
              controller: memberNotesController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.neutral900),
              cursorColor: AppColors.neutral900,
              decoration: _postCallNotesDecoration(labelText: 'Optional note'),
            ),
          ] else
            TextField(
              controller: trainerNotesController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.neutral900),
              cursorColor: AppColors.neutral900,
              decoration: _postCallNotesDecoration(
                labelText: 'Quick notes',
                hintText: 'Session summary…',
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onDone,
            child: Text(isTrainer ? 'Mark as complete' : 'Submit'),
          ),
        ],
      ),
    );
  }
}

InputDecoration _postCallNotesDecoration({
  required String labelText,
  String? hintText,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: AppColors.neutral700),
    hintStyle: TextStyle(color: AppColors.neutral700.withValues(alpha: 0.65)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.neutral100),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.white, width: 2),
    ),
  );
}
