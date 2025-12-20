// signaling.dart - FINAL FIX: Phân biệt camera và screen streams
// signaling.dart - FINAL FIX với MediaStreamTrack
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/widgets/z_space.dart';

class Signaling {
  final String wsUrl;
  WebSocketChannel? _channel;
  MediaStream? localStream;
  MediaStream? screenStream;
  Map<String, RTCPeerConnection> pcs = {};
  Map<String, MediaStream> remoteStreams = {};

  Map<String, String> streamToPeer = {};
  Map<String, List<String>> peerToStreams = {};

  // ✅ Track loại stream và số lượng video tracks của mỗi peer
  Map<String, bool> streamIsScreen = {}; // streamId -> isScreenShare
  Map<String, int> peerVideoStreamCount = {}; // peerId -> số lượng video streams

  Map<String, String> clientToUser = {};
  Map<String, String> userToClient = {};

  String clientId;
  String userId;

  final Map<String, List<RTCIceCandidate>> pendingCandidates = {};

  Signaling({required this.wsUrl, required this.userId}) : clientId = "";

  void Function(String streamId, MediaStream stream, String? userId, bool isScreen)? onAddRemoteStream;
  void Function(String streamId)? onRemoveRemoteStream;
  void Function()? onScreenShareEnded;

  Future<void> initLocalStream({bool audio = true, bool video = true}) async {
    final mediaConstraints = {
      'audio': audio,
      'video': video ? {'facingMode': 'user'} : false,
    };
    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  Future<void> start(String roomId) async {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel!.stream.listen(
          (message) {
        final Map msg = jsonDecode(message);
        _handleMessage(msg);
      },
      onError: (error) {
        debugPrint('[WS_ERROR] $error');
      },
      onDone: () {
        debugPrint('[WS_CLOSED] Connection closed');
      },
    );
  }

  Future<RTCPeerConnection> _createPeer(String peerId, bool polite) async {
    final Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    };
    final pc = await createPeerConnection(config);

    localStream?.getTracks().forEach((t) => pc.addTrack(t, localStream!));

    if (screenStream != null) {
      screenStream!.getTracks().forEach((t) => pc.addTrack(t, screenStream!));
    }

    pc.onIceCandidate = (candidate) {
      if (candidate != null) {
        _send({
          'type': 'ice',
          'to': peerId,
          'from': clientId,
          'candidate': candidate.toMap(),
        });
      }
    };

    pc.onTrack = (event) {
      final track = event.track;
      final stream = event.streams.first;
      final streamId = stream.id;

      debugPrint('[TRACK] Received ${track.kind} track from peer $peerId');
      debugPrint('[TRACK] streamId=$streamId, label="${track.label}", enabled=${track.enabled}');

      // ✅ Detect screen share
      final isScreen = _isScreenShareStream(peerId, stream, track);

      debugPrint('[TRACK] isScreen=$isScreen (detected via heuristics)');

      if (!remoteStreams.containsKey(streamId)) {
        remoteStreams[streamId] = stream;

        streamToPeer[streamId] = peerId;
        streamIsScreen[streamId] = isScreen;
        peerToStreams[peerId] = peerToStreams[peerId] ?? [];
        if (!peerToStreams[peerId]!.contains(streamId)) {
          peerToStreams[peerId]!.add(streamId);
        }

        // Update video stream count
        if (track.kind == 'video') {
          peerVideoStreamCount[peerId] = (peerVideoStreamCount[peerId] ?? 0) + 1;
          debugPrint('[TRACK] Peer $peerId now has ${peerVideoStreamCount[peerId]} video streams');
        }

        final peerUserId = clientToUser[peerId];
        onAddRemoteStream?.call(streamId, stream, peerUserId, isScreen);
        debugPrint('[STREAM_ADDED] streamId=$streamId, userId=$peerUserId, isScreen=$isScreen');
      }
    };

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    final localDesc = await pc.getLocalDescription();
    _send({
      'type': 'offer',
      'to': peerId,
      'from': clientId,
      'sdp': localDesc?.toMap(),
    });

    pcs[peerId] = pc;
    return pc;
  }

  // ✅ Improved screen share detection
  bool _isScreenShareStream(String peerId, MediaStream stream, MediaStreamTrack track) {
    // Method 1: Check if peer already has a video stream
    // Second video stream is likely screen share
    final currentVideoCount = peerVideoStreamCount[peerId] ?? 0;
    if (currentVideoCount > 0 && track.kind == 'video') {
      debugPrint('[DETECT] Peer $peerId already has $currentVideoCount video stream(s) → this is likely screen share');
      return true;
    }

    // Method 2: Check track label (screen capture usually has "screen" in label)
    final label = track.label?.toLowerCase() ?? '';
    if (label.contains('screen') || label.contains('display') || label.contains('monitor')) {
      debugPrint('[DETECT] Track label contains screen keywords: "$label"');
      return true;
    }

    // Method 3: Screen share streams typically have only video, no audio
    final hasAudio = stream.getAudioTracks().isNotEmpty;
    final hasVideo = stream.getVideoTracks().isNotEmpty;
    final videoCount = stream.getVideoTracks().length;

    if (hasVideo && !hasAudio && videoCount == 1 && track.kind == 'video') {
      debugPrint('[DETECT] Stream has video but no audio → might be screen share');
      // This is a weaker signal, so only use if we have multiple video streams
      if (currentVideoCount > 0) {
        return true;
      }
    }

    return false;
  }

  void _handleMessage(Map msg) async {
    final type = msg['type'];
    final from = msg['from'];
    final fromUserId = msg['user_id'];

    debugPrint('[MESSAGE] type=$type from=$from userId=$fromUserId');

    if (type == 'client_id') {
      clientId = msg['client_id'];
      debugPrint('[CLIENT_ID] Assigned clientId: $clientId for userId: $userId');
      return;
    }

    if (type == 'peers_list') {
      final peers = msg['peers'] as List;
      for (var peer in peers) {
        final peerClientId = peer['client_id'];
        final peerUserId = peer['user_id'];
        clientToUser[peerClientId] = peerUserId;
        userToClient[peerUserId] = peerClientId;
        debugPrint('[PEER_LIST] clientId=$peerClientId -> userId=$peerUserId');
      }
      return;
    }

    if (fromUserId != null && from != null) {
      clientToUser[from] = fromUserId;
      userToClient[fromUserId] = from;
    }

    if (type == 'join') {
      if (from != clientId && !pcs.containsKey(from)) {
        debugPrint('[JOIN] New peer: clientId=$from userId=$fromUserId');
        await _createPeer(from, false);
      }
    } else if (type == 'offer' && msg['to'] == clientId) {
      final sdp = RTCSessionDescription(msg['sdp']['sdp'], msg['sdp']['type']);
      var pc = pcs[from] ?? await _createPeerConnectionOnly(from);

      final polite = true;
      final state = await pc.getSignalingState();
      final isStable = state == RTCSignalingState.RTCSignalingStateStable;

      if (!isStable && !polite) return;

      if (!isStable && polite) {
        try {
          await pc.close();
        } catch (_) {}
        pcs.remove(from);
        pc = await _createPeerConnectionOnly(from);
      }

      await pc.setRemoteDescription(sdp);
      await _flushPendingCandidates(from, pc);

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      final localDesc = await pc.getLocalDescription();
      _send({
        'type': 'answer',
        'to': from,
        'from': clientId,
        'sdp': localDesc?.toMap(),
      });
    } else if (type == 'answer' && msg['to'] == clientId) {
      final pc = pcs[from];
      if (pc != null &&
          (await pc.getSignalingState()) !=
              RTCSignalingState.RTCSignalingStateStable) {
        final sdp = RTCSessionDescription(
          msg['sdp']['sdp'],
          msg['sdp']['type'],
        );
        await pc.setRemoteDescription(sdp);
        if ((await pc.getRemoteDescription()) == null) {
          await pc.setRemoteDescription(sdp);
          await _flushPendingCandidates(from, pc);
        }
      }
    } else if (type == 'ice' && msg['to'] == clientId) {
      final pc = pcs[from];
      final c = RTCIceCandidate(
        msg['candidate']['candidate'],
        msg['candidate']['sdpMid'],
        msg['candidate']['sdpMLineIndex'],
      );

      if (pc == null) {
        pendingCandidates[from] = pendingCandidates[from] ?? [];
        pendingCandidates[from]!.add(c);
        return;
      }

      final desc = await pc.getRemoteDescription();
      if (desc == null || desc.sdp == null) {
        pendingCandidates[from] = pendingCandidates[from] ?? [];
        pendingCandidates[from]!.add(c);
      } else {
        try {
          await pc.addCandidate(c);
        } catch (e) {}
      }
    } else if (type == 'leave') {
      debugPrint('[LEAVE] Peer leaving: clientId=$from userId=$fromUserId');
      await _cleanupPeer(from);

      if (fromUserId != null) {
        userToClient.remove(fromUserId);
      }
      clientToUser.remove(from);
    } else if (type == 'stop_screen_share') {
      // ✅ CHỈ xóa screen streams
      debugPrint('[SCREEN_SHARE_STOPPED] Peer $from ($fromUserId) stopped screen sharing');

      final streamsToRemove = <String>[];

      debugPrint('[SCREEN_CHECK] Checking streams for peer $from:');
      peerToStreams[from]?.forEach((streamId) {
        final isScreen = streamIsScreen[streamId] ?? false;
        debugPrint('  - StreamId=$streamId, isScreen=$isScreen');
        if (isScreen) {
          streamsToRemove.add(streamId);
        }
      });

      debugPrint('[SCREEN_CHECK] Will remove ${streamsToRemove.length} screen stream(s), keep ${(peerToStreams[from]?.length ?? 0) - streamsToRemove.length} camera stream(s)');

      for (var streamId in streamsToRemove) {
        if (remoteStreams.containsKey(streamId)) {
          final stream = remoteStreams[streamId];

          if (stream != null) {
            // Count video tracks being removed
            final videoTracks = stream.getVideoTracks();
            if (videoTracks.isNotEmpty) {
              peerVideoStreamCount[from] = max(0, (peerVideoStreamCount[from] ?? 1) - 1);
              debugPrint('[SCREEN_CHECK] Updated peer $from video count to ${peerVideoStreamCount[from]}');
            }

            for (var track in stream.getTracks()) {
              try {
                track.stop();
              } catch (e) {}
            }
          }

          onRemoveRemoteStream?.call(streamId);
          remoteStreams.remove(streamId);
          streamToPeer.remove(streamId);
          streamIsScreen.remove(streamId);
          peerToStreams[from]?.remove(streamId);

          debugPrint('[SCREEN_REMOVED] ✅ Removed screen stream: $streamId');
        }
      }

      if (streamsToRemove.isEmpty) {
        debugPrint('[WARNING] No screen streams found for peer $from - might be detection issue');
      }
    }
  }

  Future<void> _cleanupPeer(String peerId) async {
    debugPrint('[CLEANUP] Starting cleanup for peer: $peerId');

    final pc = pcs[peerId];
    if (pc != null) {
      try {
        await pc.close();
      } catch (e) {
        debugPrint('[ERROR] Error closing peer connection: $e');
      }
      pcs.remove(peerId);
    }

    final streamIds = peerToStreams[peerId] ?? [];
    debugPrint('[CLEANUP] Found ${streamIds.length} streams for peer $peerId');

    for (var streamId in List<String>.from(streamIds)) {
      final stream = remoteStreams[streamId];
      if (stream != null) {
        for (var track in stream.getTracks()) {
          try {
            track.stop();
          } catch (e) {}
        }

        remoteStreams.remove(streamId);
        streamToPeer.remove(streamId);
        streamIsScreen.remove(streamId);
        onRemoveRemoteStream?.call(streamId);

        debugPrint('[CLEANUP] ✅ Removed stream: $streamId');
      }
    }

    peerToStreams.remove(peerId);
    peerVideoStreamCount.remove(peerId); // ✅ Clean video count
    pendingCandidates.remove(peerId);

    debugPrint('[CLEANUP] ✅ Completed cleanup for peer: $peerId');
  }

  Future<RTCPeerConnection> _createPeerConnectionOnly(String peerId) async {
    final Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    };
    final pc = await createPeerConnection(config);

    localStream?.getTracks().forEach((t) => pc.addTrack(t, localStream!));

    if (screenStream != null) {
      screenStream!.getTracks().forEach((t) => pc.addTrack(t, screenStream!));
    }

    pc.onIceCandidate = (candidate) {
      if (candidate != null) {
        _send({
          'type': 'ice',
          'to': peerId,
          'from': clientId,
          'candidate': candidate.toMap(),
        });
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        final stream = event.streams[0];
        final streamId = stream.id;
        final track = event.track;

        debugPrint('[TRACK] Received ${track.kind} track from peer $peerId');

        final isScreen = _isScreenShareStream(peerId, stream, track);

        remoteStreams[streamId] = stream;

        streamToPeer[streamId] = peerId;
        streamIsScreen[streamId] = isScreen;
        peerToStreams[peerId] = peerToStreams[peerId] ?? [];
        if (!peerToStreams[peerId]!.contains(streamId)) {
          peerToStreams[peerId]!.add(streamId);
        }

        // Update video stream count
        if (track.kind == 'video') {
          peerVideoStreamCount[peerId] = (peerVideoStreamCount[peerId] ?? 0) + 1;
        }

        final peerUserId = clientToUser[peerId];
        onAddRemoteStream?.call(streamId, stream, peerUserId, isScreen);
        debugPrint("[TRACK_ADDED] streamId=$streamId userId=$peerUserId isScreen=$isScreen");
      }
    };

    pc.onConnectionState = (state) {
      debugPrint('[CONNECTION_STATE] Peer $peerId state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        _cleanupPeer(peerId);
      }
    };

    pcs[peerId] = pc;
    return pc;
  }

  void _send(Map data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (e) {
      debugPrint('[SEND_ERROR] $e');
    }
  }

  Future<void> toggleMicrophone(bool enabled) async {
    localStream?.getAudioTracks().forEach((t) => t.enabled = enabled);
  }

  Future<void> toggleCamera(bool enabled) async {
    localStream?.getVideoTracks().forEach((t) => t.enabled = enabled);
  }

  Future<void> startScreenShare() async {
    try {
      screenStream = await navigator.mediaDevices.getDisplayMedia({
        'video': true,
        'audio': false,
      });

      final screenTrack = screenStream!.getVideoTracks().first;
      debugPrint('[SCREEN_SHARE] Started, streamId=${screenStream!.id}');

      for (final entry in pcs.entries) {
        final pc = entry.value;
        await pc.addTrack(screenTrack, screenStream!);

        final offer = await pc.createOffer();
        await pc.setLocalDescription(offer);
        final localDesc = await pc.getLocalDescription();
        _send({
          'type': 'offer',
          'to': entry.key,
          'from': clientId,
          'sdp': localDesc?.toMap(),
        });
      }

      screenTrack.onEnded = () async {
        debugPrint('[SCREEN_SHARE] User stopped via browser');
        await stopScreenShare();
      };
    } catch (e) {
      debugPrint('[SCREEN_SHARE_ERROR] $e');
      screenStream = null;
      rethrow;
    }
  }

  Future<void> stopScreenShare() async {
    if (screenStream == null) return;

    debugPrint('[SCREEN_SHARE] Stopping screen share');

    // Stop all screen tracks
    for (var track in screenStream!.getTracks()) {
      track.stop();
    }

    // Remove screen tracks from all peer connections
    for (final pc in pcs.values) {
      final senders = await pc.getSenders();
      for (final sender in senders) {
        if (sender.track != null &&
            screenStream!.getTracks().any((t) => t.id == sender.track!.id)) {
          await pc.removeTrack(sender);
          debugPrint('[SCREEN_SHARE] Removed screen track from peer');
        }
      }

      // Renegotiate
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      final localDesc = await pc.getLocalDescription();

      for (final entry in pcs.entries) {
        if (entry.value == pc) {
          _send({
            'type': 'offer',
            'to': entry.key,
            'from': clientId,
            'sdp': localDesc?.toMap(),
          });
        }
      }
    }

    // Notify others
    _send({
      'type': 'stop_screen_share',
      'from': clientId,
    });

    screenStream = null;
    onScreenShareEnded?.call();

    debugPrint('[SCREEN_SHARE] ✅ Screen share stopped');
  }

  Future<void> _flushPendingCandidates(String peerId, RTCPeerConnection pc) async {
    final list = pendingCandidates[peerId];
    if (list == null || list.isEmpty) return;

    for (var c in List<RTCIceCandidate>.from(list)) {
      try {
        await pc.addCandidate(c);
      } catch (e) {}
    }
    pendingCandidates.remove(peerId);
  }

  Future<void> dispose() async {
    debugPrint('[DISPOSE] Cleaning up signaling');

    if (screenStream != null) {
      await stopScreenShare();
    }

    for (var pc in pcs.values) {
      await pc.close();
    }
    pcs.clear();

    for (var stream in remoteStreams.values) {
      for (var track in stream.getTracks()) {
        track.stop();
      }
    }
    remoteStreams.clear();
    streamToPeer.clear();
    peerToStreams.clear();
    streamIsScreen.clear();
    peerVideoStreamCount.clear(); // ✅ Clean video counts
    clientToUser.clear();
    userToClient.clear();

    localStream?.getTracks().forEach((t) => t.stop());
    _channel?.sink.close();
  }

  String? getUserId(String clientId) {
    return clientToUser[clientId];
  }

  bool get isScreenSharing => screenStream != null;
}

// VideoCallPage và MeetLayout giữ nguyên như version trước
// Chỉ import dart:math để dùng max() function

// VideoCallPage remains mostly the same, just update onAddRemoteStream signature
class VideoCallPage extends StatefulWidget {
  final String roomId;
  final String userId;
  final dynamic meetingInfo;
  final Future<String> Function(String userId)? getUserName;
  final Future<String> Function(String userId)? getUserAvatar;

  const VideoCallPage({
    super.key,
    required this.roomId,
    required this.userId,
    this.meetingInfo,
    this.getUserName,
    this.getUserAvatar,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final Map<String, String?> _rendererToUserId = {};
  final Map<String, bool> _rendererIsScreen = {}; // ✅ Track screen renderers

  Signaling? signaling;
  bool isOnMic = true;
  bool isOnCam = true;
  bool isSharingScreen = false;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _initSignaling();
  }

  Future<void> _initSignaling() async {
    signaling = Signaling(
      wsUrl: "ws://127.0.0.1:8000/call/ws/${widget.roomId}/${widget.userId}",
      userId: widget.userId,
    );

    await signaling!.initLocalStream();
    _localRenderer.srcObject = signaling!.localStream;
    await signaling!.start(widget.roomId);

    // ✅ Updated signature with isScreen parameter
    signaling!.onAddRemoteStream = (streamId, stream, userId, isScreen) async {
      debugPrint('[UI] onAddRemoteStream: streamId=$streamId, userId=$userId, isScreen=$isScreen');

      if (_remoteRenderers.containsKey(streamId)) {
        debugPrint('[UI_WARNING] Renderer already exists for $streamId');
        return;
      }

      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = stream;

      if (mounted) {
        setState(() {
          _remoteRenderers[streamId] = renderer;
          _rendererToUserId[streamId] = userId;
          _rendererIsScreen[streamId] = isScreen; // ✅ Track if screen
          debugPrint('[UI] ✅ Added renderer (isScreen=$isScreen), total: ${_remoteRenderers.length}');
        });
      }
    };

    signaling!.onRemoveRemoteStream = (streamId) {
      debugPrint('[UI] onRemoveRemoteStream: $streamId');

      final renderer = _remoteRenderers[streamId];
      if (renderer != null) {
        renderer.srcObject = null;
        renderer.dispose();
      }

      if (mounted) {
        setState(() {
          _remoteRenderers.remove(streamId);
          _rendererToUserId.remove(streamId);
          _rendererIsScreen.remove(streamId); // ✅ Clean screen flag
          debugPrint('[UI] ✅ Removed renderer, remaining: ${_remoteRenderers.length}');
        });
      }
    };

    signaling!.onScreenShareEnded = () {
      if (mounted) {
        setState(() {
          isSharingScreen = false;
        });
      }
    };
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    for (var r in _remoteRenderers.values) {
      r.srcObject = null;
      r.dispose();
    }
    _remoteRenderers.clear();
    _rendererToUserId.clear();
    _rendererIsScreen.clear();
    signaling?.dispose();
    super.dispose();
  }

  Future<String> getNameByStreamId(String streamId) async {
    if (streamId == widget.userId) return 'You';

    final userId = _rendererToUserId[streamId];
    if (userId == null) return 'User $streamId';

    if (widget.getUserName != null) {
      try {
        return await widget.getUserName!(userId);
      } catch (e) {
        debugPrint('[ERROR] Failed to get username: $e');
      }
    }

    return 'User $userId';
  }

  Future<String> getAvatarByStreamId(String streamId) async {
    final userId = _rendererToUserId[streamId];
    if (userId == null) {
      return 'https://ui-avatars.com/api/?name=User&background=random';
    }

    if (widget.getUserAvatar != null) {
      try {
        return await widget.getUserAvatar!(userId);
      } catch (e) {
        debugPrint('[ERROR] Failed to get avatar: $e');
      }
    }

    final name = await getNameByStreamId(streamId);
    return 'https://ui-avatars.com/api/?name=$name&background=random';
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  void _showMeetingInfo() {
    if (widget.meetingInfo == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Thông tin cuộc họp'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem('Tiêu đề', widget.meetingInfo.title ?? 'N/A'),
              if (widget.meetingInfo.description?.isNotEmpty ?? false)
                _buildInfoItem('Mô tả', widget.meetingInfo.description),
              _buildInfoItem('Room ID', widget.roomId),
              _buildInfoItem('Thời gian', _formatDateTime(widget.meetingInfo.time ?? DateTime.now())),
              _buildInfoItem('Số thành viên', '${widget.meetingInfo.members?.length ?? 0} người'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.meetingInfo?.title ?? 'Meeting - Room: ${widget.roomId}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${_remoteRenderers.length + 1}/${widget.meetingInfo?.members?.length ?? '?'}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'info') {
                _showMeetingInfo();
              } else if (value == 'leave') {
                Navigator.of(context).pop();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Thông tin cuộc họp'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Rời khỏi cuộc họp', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          MeetLayout(
            localRenderer: _localRenderer,
            remoteRenderers: _remoteRenderers,
            rendererIsScreen: _rendererIsScreen, // ✅ Pass screen flags
            userId: widget.userId,
            getNameByStreamId: getNameByStreamId,
            getAvatarByStreamId: getAvatarByStreamId,
            isLocalCameraOn: isOnCam,
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: isOnMic ? Icons.mic : Icons.mic_off,
                  onTap: () {
                    signaling?.toggleMicrophone(!isOnMic);
                    setState(() => isOnMic = !isOnMic);
                  },
                  isActive: isOnMic,
                ),
                const ZSpace(w: 9),
                _buildControlButton(
                  icon: isOnCam ? Icons.videocam : Icons.videocam_off,
                  onTap: () {
                    signaling?.toggleCamera(!isOnCam);
                    setState(() => isOnCam = !isOnCam);
                  },
                  isActive: isOnCam,
                ),
                const ZSpace(w: 9),
                _buildControlButton(
                  icon: isSharingScreen ? Icons.stop_screen_share : Icons.screen_share,
                  onTap: () async {
                    if (isSharingScreen) {
                      await signaling?.stopScreenShare();
                      setState(() => isSharingScreen = false);
                    } else {
                      try {
                        await signaling?.startScreenShare();
                        setState(() => isSharingScreen = true);
                      } catch (e) {
                        debugPrint('[ERROR] Failed to start screen share: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Không thể chia sẻ màn hình')),
                        );
                      }
                    }
                  },
                  isActive: isSharingScreen,
                  color: isSharingScreen ? Colors.green : null,
                ),
                const ZSpace(w: 9),
                _buildControlButton(
                  icon: Icons.call_end,
                  onTap: () => Navigator.of(context).pop(),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    Color? color,
  }) {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? (isActive ? Colors.white : Color(0xFFEBEBEB)),
          boxShadow: const [ColorConfig.boxShadow2],
        ),
        padding: EdgeInsets.all(12),
        child: Icon(
          icon,
          color: color != null ? Colors.white : (isActive ? Colors.blue : Colors.black87),
          size: 24,
        ),
      ),
    );
  }
}

// MeetLayout with screen detection
class MeetLayout extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final Map<String, RTCVideoRenderer> remoteRenderers;
  final Map<String, bool> rendererIsScreen; // ✅ Screen flags
  final String userId;
  final Future<String> Function(String) getNameByStreamId;
  final Future<String> Function(String) getAvatarByStreamId;
  final bool isLocalCameraOn;

  const MeetLayout({
    super.key,
    required this.localRenderer,
    required this.remoteRenderers,
    required this.rendererIsScreen,
    required this.userId,
    required this.getNameByStreamId,
    required this.getAvatarByStreamId,
    this.isLocalCameraOn = true,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Separate screen shares and camera streams
    final screenShares = <String, RTCVideoRenderer>{};
    final cameraStreams = <String, RTCVideoRenderer>{};

    remoteRenderers.forEach((key, value) {
      final isScreen = rendererIsScreen[key] ?? false;
      if (isScreen) {
        screenShares[key] = value;
      } else {
        cameraStreams[key] = value;
      }
    });

    if (screenShares.isNotEmpty) {
      return _buildScreenShareLayout(context, screenShares, cameraStreams);
    }

    final allCameras = {userId: localRenderer, ...cameraStreams};
    return _buildGridLayout(context, allCameras);
  }

  Widget _buildScreenShareLayout(
      BuildContext context,
      Map<String, RTCVideoRenderer> screenShares,
      Map<String, RTCVideoRenderer> cameraStreams,
      ) {
    final allCameras = {userId: localRenderer, ...cameraStreams};

    return Column(
      children: [
        Expanded(
          flex: 7,
          child: Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: screenShares.entries.first.value.srcObject != null
                    ? RTCVideoView(
                  screenShares.entries.first.value,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                )
                    : Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: Icon(
                      Icons.screen_share,
                      size: 64,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.black87,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: allCameras.length,
              itemBuilder: (context, index) {
                final entry = allCameras.entries.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildCameraThumbnail(entry.key, entry.value),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraThumbnail(String id, RTCVideoRenderer renderer) {
    final isLocal = id == userId;
    final shouldShowVideo = isLocal ? isLocalCameraOn : true;

    return FutureBuilder<String>(
      future: getNameByStreamId(id),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'Loading...';

        return Container(
          width: 160,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[900],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                if (renderer.srcObject != null && shouldShowVideo)
                  Positioned.fill(
                    child: RTCVideoView(
                      renderer,
                      mirror: isLocal,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  )
                else
                  Positioned.fill(
                    child: FutureBuilder<String>(
                      future: getAvatarByStreamId(id),
                      builder: (context, avatarSnapshot) {
                        return Container(
                          color: Colors.grey[800],
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: avatarSnapshot.hasData
                                      ? NetworkImage(avatarSnapshot.data!)
                                      : null,
                                  child: !avatarSnapshot.hasData
                                      ? Icon(Icons.person)
                                      : null,
                                ),
                                if (!shouldShowVideo && isLocal) ...[
                                  SizedBox(height: 8),
                                  Icon(
                                    Icons.videocam_off,
                                    color: Colors.white60,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridLayout(BuildContext context, Map<String, RTCVideoRenderer> allCameras) {
    final total = allCameras.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        int columns = (total <= 1)
            ? 1
            : (total <= 4)
            ? 2
            : (total <= 9)
            ? 3
            : 4;
        int rows = (total / columns).ceil();

        double tileWidth = width / columns;
        double tileHeight = height / rows;

        return Center(
          child: Wrap(
            spacing: 0,
            runSpacing: 0,
            children: allCameras.entries.map((e) {
              return SizedBox(
                width: tileWidth,
                height: tileHeight,
                child: _buildVideoTile(e.key, e.value),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildVideoTile(String id, RTCVideoRenderer renderer) {
    final isLocal = id == userId;
    final shouldShowVideo = isLocal ? isLocalCameraOn : true;

    return FutureBuilder<String>(
      future: getNameByStreamId(id),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'Loading...';

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[900],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  if (renderer.srcObject != null && shouldShowVideo)
                    Positioned.fill(
                      child: RTCVideoView(
                        renderer,
                        mirror: isLocal,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      ),
                    )
                  else
                    Positioned.fill(
                      child: FutureBuilder<String>(
                        future: getAvatarByStreamId(id),
                        builder: (context, avatarSnapshot) {
                          return Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: avatarSnapshot.hasData
                                        ? NetworkImage(avatarSnapshot.data!)
                                        : null,
                                    child: !avatarSnapshot.hasData
                                        ? Icon(Icons.person, size: 40)
                                        : null,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (!shouldShowVideo && isLocal) ...[
                                    SizedBox(height: 4),
                                    Icon(
                                      Icons.videocam_off,
                                      color: Colors.white60,
                                      size: 24,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 14,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 4),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}