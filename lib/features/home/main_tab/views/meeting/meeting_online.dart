// Complete video call implementation with all fixes
// Fix 1: Remove /total in participant counter
// Fix 2: Add "Screen: " prefix for screen shares
// Fix 3: Force remove screen share UI immediately when stopped

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
  Map<String, bool> streamIsScreen = {};
  Map<String, int> peerVideoStreamCount = {};

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
      onError: (error) => debugPrint('[WS_ERROR] $error'),
      onDone: () => debugPrint('[WS_CLOSED] Connection closed'),
    );
  }

  Future<RTCPeerConnection> _createPeer(String peerId, bool polite) async {
    final config = {
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}],
      'sdpSemantics': 'unified-plan',
    };
    final pc = await createPeerConnection(config);

    localStream?.getTracks().forEach((t) => pc.addTrack(t, localStream!));
    if (screenStream != null) {
      screenStream!.getTracks().forEach((t) => pc.addTrack(t, screenStream!));
    }

    pc.onIceCandidate = (candidate) {
      if (candidate != null) {
        _send({'type': 'ice', 'to': peerId, 'from': clientId, 'candidate': candidate.toMap()});
      }
    };

    pc.onTrack = (event) {
      final track = event.track;
      final stream = event.streams.first;
      final streamId = stream.id;

      final isScreen = _isScreenShareStream(peerId, stream, track);

      if (!remoteStreams.containsKey(streamId)) {
        remoteStreams[streamId] = stream;
        streamToPeer[streamId] = peerId;
        streamIsScreen[streamId] = isScreen;
        peerToStreams[peerId] = peerToStreams[peerId] ?? [];
        if (!peerToStreams[peerId]!.contains(streamId)) {
          peerToStreams[peerId]!.add(streamId);
        }

        if (track.kind == 'video') {
          peerVideoStreamCount[peerId] = (peerVideoStreamCount[peerId] ?? 0) + 1;
        }

        final peerUserId = clientToUser[peerId];
        onAddRemoteStream?.call(streamId, stream, peerUserId, isScreen);
        debugPrint('[STREAM_ADDED] streamId=$streamId, userId=$peerUserId, isScreen=$isScreen');
      }
    };

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    final localDesc = await pc.getLocalDescription();
    _send({'type': 'offer', 'to': peerId, 'from': clientId, 'sdp': localDesc?.toMap()});

    pcs[peerId] = pc;
    return pc;
  }

  bool _isScreenShareStream(String peerId, MediaStream stream, MediaStreamTrack track) {
    final currentVideoCount = peerVideoStreamCount[peerId] ?? 0;
    if (currentVideoCount > 0 && track.kind == 'video') {
      return true;
    }

    final label = track.label?.toLowerCase() ?? '';
    if (label.contains('screen') || label.contains('display') || label.contains('monitor')) {
      return true;
    }

    final hasAudio = stream.getAudioTracks().isNotEmpty;
    final hasVideo = stream.getVideoTracks().isNotEmpty;

    if (hasVideo && !hasAudio && currentVideoCount > 0 && track.kind == 'video') {
      return true;
    }

    return false;
  }

  void _handleMessage(Map msg) async {
    final type = msg['type'];
    final from = msg['from'];
    final fromUserId = msg['user_id'];

    if (type == 'client_id') {
      clientId = msg['client_id'];
      debugPrint('[CLIENT_ID] $clientId for userId: $userId');
      return;
    }

    if (type == 'peers_list') {
      final peers = msg['peers'] as List;
      for (var peer in peers) {
        clientToUser[peer['client_id']] = peer['user_id'];
        userToClient[peer['user_id']] = peer['client_id'];
      }
      return;
    }

    if (fromUserId != null && from != null) {
      clientToUser[from] = fromUserId;
      userToClient[fromUserId] = from;
    }

    if (type == 'join') {
      if (from != clientId && !pcs.containsKey(from)) {
        await _createPeer(from, false);
      }
    } else if (type == 'offer' && msg['to'] == clientId) {
      final sdp = RTCSessionDescription(msg['sdp']['sdp'], msg['sdp']['type']);
      var pc = pcs[from] ?? await _createPeerConnectionOnly(from);

      final state = await pc.getSignalingState();
      final isStable = state == RTCSignalingState.RTCSignalingStateStable;

      if (!isStable) {
        try { await pc.close(); } catch (_) {}
        pcs.remove(from);
        pc = await _createPeerConnectionOnly(from);
      }

      await pc.setRemoteDescription(sdp);
      await _flushPendingCandidates(from, pc);

      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      final localDesc = await pc.getLocalDescription();
      _send({'type': 'answer', 'to': from, 'from': clientId, 'sdp': localDesc?.toMap()});
    } else if (type == 'answer' && msg['to'] == clientId) {
      final pc = pcs[from];
      if (pc != null && (await pc.getSignalingState()) != RTCSignalingState.RTCSignalingStateStable) {
        final sdp = RTCSessionDescription(msg['sdp']['sdp'], msg['sdp']['type']);
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

      if (pc == null || (await pc.getRemoteDescription())?.sdp == null) {
        pendingCandidates[from] = pendingCandidates[from] ?? [];
        pendingCandidates[from]!.add(c);
      } else {
        try { await pc.addCandidate(c); } catch (e) {}
      }
    } else if (type == 'leave') {
      await _cleanupPeer(from);
      if (fromUserId != null) userToClient.remove(fromUserId);
      clientToUser.remove(from);
    } else if (type == 'stop_screen_share') {
      // ✅ FIX 3: Force remove screen share UI
      debugPrint('[SCREEN_STOPPED] Peer $from stopped sharing');

      final streamsToRemove = <String>[];
      final screenStreamId = msg['screen_stream_id'];

      peerToStreams[from]?.forEach((streamId) {
        final isScreen = streamIsScreen[streamId] ?? false;
        if (isScreen || (screenStreamId != null && streamId == screenStreamId)) {
          streamsToRemove.add(streamId);
        }
      });

      // Fallback: remove 2nd video stream if no screen flag
      if (streamsToRemove.isEmpty && peerToStreams[from] != null) {
        final videoStreams = peerToStreams[from]!.where((id) {
          final s = remoteStreams[id];
          return s != null && s.getVideoTracks().isNotEmpty;
        }).toList();

        if (videoStreams.length > 1) {
          for (int i = 1; i < videoStreams.length; i++) {
            streamsToRemove.add(videoStreams[i]);
          }
        }
      }

      for (var streamId in streamsToRemove) {
        final stream = remoteStreams[streamId];
        if (stream != null) {
          for (var track in stream.getTracks()) {
            try { track.stop(); } catch (e) {}
          }
          if (stream.getVideoTracks().isNotEmpty) {
            peerVideoStreamCount[from] = max(0, (peerVideoStreamCount[from] ?? 1) - 1);
          }
        }

        remoteStreams.remove(streamId);
        streamToPeer.remove(streamId);
        streamIsScreen.remove(streamId);
        peerToStreams[from]?.remove(streamId);

        onRemoveRemoteStream?.call(streamId);
        debugPrint('[SCREEN_REMOVED] ✅ $streamId');
      }
    }
  }

  Future<void> _cleanupPeer(String peerId) async {
    final pc = pcs[peerId];
    if (pc != null) {
      try { await pc.close(); } catch (e) {}
      pcs.remove(peerId);
    }

    final streamIds = peerToStreams[peerId] ?? [];
    for (var streamId in List<String>.from(streamIds)) {
      final stream = remoteStreams[streamId];
      if (stream != null) {
        for (var track in stream.getTracks()) {
          try { track.stop(); } catch (e) {}
        }
        remoteStreams.remove(streamId);
        streamToPeer.remove(streamId);
        streamIsScreen.remove(streamId);
        onRemoveRemoteStream?.call(streamId);
      }
    }

    peerToStreams.remove(peerId);
    peerVideoStreamCount.remove(peerId);
    pendingCandidates.remove(peerId);
  }

  Future<RTCPeerConnection> _createPeerConnectionOnly(String peerId) async {
    final config = {'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}], 'sdpSemantics': 'unified-plan'};
    final pc = await createPeerConnection(config);

    localStream?.getTracks().forEach((t) => pc.addTrack(t, localStream!));
    if (screenStream != null) {
      screenStream!.getTracks().forEach((t) => pc.addTrack(t, screenStream!));
    }

    pc.onIceCandidate = (candidate) {
      if (candidate != null) {
        _send({'type': 'ice', 'to': peerId, 'from': clientId, 'candidate': candidate.toMap()});
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        final stream = event.streams[0];
        final streamId = stream.id;
        final track = event.track;
        final isScreen = _isScreenShareStream(peerId, stream, track);

        remoteStreams[streamId] = stream;
        streamToPeer[streamId] = peerId;
        streamIsScreen[streamId] = isScreen;
        peerToStreams[peerId] = peerToStreams[peerId] ?? [];
        if (!peerToStreams[peerId]!.contains(streamId)) {
          peerToStreams[peerId]!.add(streamId);
        }

        if (track.kind == 'video') {
          peerVideoStreamCount[peerId] = (peerVideoStreamCount[peerId] ?? 0) + 1;
        }

        final peerUserId = clientToUser[peerId];
        onAddRemoteStream?.call(streamId, stream, peerUserId, isScreen);
      }
    };

    pc.onConnectionState = (state) {
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
      screenStream = await navigator.mediaDevices.getDisplayMedia({'video': true, 'audio': false});
      final screenTrack = screenStream!.getVideoTracks().first;

      for (final entry in pcs.entries) {
        final pc = entry.value;
        await pc.addTrack(screenTrack, screenStream!);
        final offer = await pc.createOffer();
        await pc.setLocalDescription(offer);
        final localDesc = await pc.getLocalDescription();
        _send({'type': 'offer', 'to': entry.key, 'from': clientId, 'sdp': localDesc?.toMap()});
      }

      screenTrack.onEnded = () async {
        await stopScreenShare();
      };
    } catch (e) {
      screenStream = null;
      rethrow;
    }
  }

  Future<void> stopScreenShare() async {
    if (screenStream == null) return;

    final screenStreamId = screenStream!.id;

    for (var track in screenStream!.getTracks()) {
      track.stop();
    }

    for (final entry in pcs.entries) {
      final peerId = entry.key;
      final pc = entry.value;
      final senders = await pc.getSenders();
      bool removed = false;

      for (final sender in senders) {
        if (sender.track != null && screenStream!.getTracks().any((t) => t.id == sender.track!.id)) {
          await pc.removeTrack(sender);
          removed = true;
        }
      }

      if (removed) {
        try {
          final offer = await pc.createOffer();
          await pc.setLocalDescription(offer);
          final localDesc = await pc.getLocalDescription();
          if (localDesc != null) {
            _send({'type': 'offer', 'to': peerId, 'from': clientId, 'sdp': localDesc.toMap()});
          }
        } catch (e) {}
      }
    }

    _send({'type': 'stop_screen_share', 'from': clientId, 'screen_stream_id': screenStreamId});
    screenStream = null;
    onScreenShareEnded?.call();
  }

  Future<void> _flushPendingCandidates(String peerId, RTCPeerConnection pc) async {
    final list = pendingCandidates[peerId];
    if (list == null || list.isEmpty) return;
    for (var c in List<RTCIceCandidate>.from(list)) {
      try { await pc.addCandidate(c); } catch (e) {}
    }
    pendingCandidates.remove(peerId);
  }

  Future<void> dispose() async {
    if (screenStream != null) await stopScreenShare();
    for (var pc in pcs.values) await pc.close();
    pcs.clear();
    for (var stream in remoteStreams.values) {
      for (var track in stream.getTracks()) track.stop();
    }
    remoteStreams.clear();
    streamToPeer.clear();
    peerToStreams.clear();
    streamIsScreen.clear();
    peerVideoStreamCount.clear();
    clientToUser.clear();
    userToClient.clear();
    localStream?.getTracks().forEach((t) => t.stop());
    _channel?.sink.close();
  }

  String? getUserId(String clientId) => clientToUser[clientId];
  bool get isScreenSharing => screenStream != null;
}

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
  final Map<String, bool> _rendererIsScreen = {};

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

    signaling!.onAddRemoteStream = (streamId, stream, userId, isScreen) async {
      if (_remoteRenderers.containsKey(streamId)) return;

      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = stream;

      if (mounted) {
        setState(() {
          _remoteRenderers[streamId] = renderer;
          _rendererToUserId[streamId] = userId;
          _rendererIsScreen[streamId] = isScreen;
        });
      }
    };

    signaling!.onRemoveRemoteStream = (streamId) {
      final renderer = _remoteRenderers[streamId];
      if (renderer != null) {
        renderer.srcObject = null;
        renderer.dispose();
      }

      if (mounted) {
        setState(() {
          _remoteRenderers.remove(streamId);
          _rendererToUserId.remove(streamId);
          _rendererIsScreen.remove(streamId);
        });
      }
    };

    signaling!.onScreenShareEnded = () {
      if (mounted) setState(() => isSharingScreen = false);
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

  // ✅ FIX 2: Add "Screen: " prefix
  Future<String> getNameByStreamId(String streamId) async {
    if (streamId == widget.userId) return 'You';

    final userId = _rendererToUserId[streamId];
    final isScreen = _rendererIsScreen[streamId] ?? false;

    if (userId == null) {
      return isScreen ? 'Screen: User $streamId' : 'User $streamId';
    }

    String name = 'User $userId';
    if (widget.getUserName != null) {
      try {
        name = await widget.getUserName!(userId);
      } catch (e) {}
    }

    return isScreen ? 'Screen: $name' : name;
  }

  Future<String> getAvatarByStreamId(String streamId) async {
    final userId = _rendererToUserId[streamId];
    if (userId == null) {
      return 'https://ui-avatars.com/api/?name=User&background=random';
    }

    if (widget.getUserAvatar != null) {
      try {
        return await widget.getUserAvatar!(userId);
      } catch (e) {}
    }

    final name = await getNameByStreamId(streamId);
    return 'https://ui-avatars.com/api/?name=$name&background=random';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.meetingInfo?.title ?? 'Meeting'),
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
                // ✅ FIX 1: Remove /total, count only camera streams
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '${_remoteRenderers.keys
                          .where((key) => !(_rendererIsScreen[key] ?? false))
                          .length + 1}',
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
              if (value == 'leave') Navigator.of(context).pop();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Rời khỏi', style: TextStyle(color: Colors.red)),
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
            rendererIsScreen: _rendererIsScreen,
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
                      } catch (e) {}
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

class MeetLayout extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final Map<String, RTCVideoRenderer> remoteRenderers;
  final Map<String, bool> rendererIsScreen;
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
    final screenShares = <String, RTCVideoRenderer>{};
    final cameraStreams = <String, RTCVideoRenderer>{};

    remoteRenderers.forEach((key, value) {
      if (rendererIsScreen[key] ?? false) {
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
                  child: Icon(Icons.screen_share, size: 64, color: Colors.white38),
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
                  child: _buildThumbnail(entry.key, entry.value),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(String id, RTCVideoRenderer renderer) {
    final isLocal = id == userId;
    final shouldShow = isLocal ? isLocalCameraOn : true;

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
                if (renderer.srcObject != null && shouldShow)
                  Positioned.fill(
                    child: RTCVideoView(renderer, mirror: isLocal, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                  )
                else
                  Positioned.fill(
                    child: FutureBuilder<String>(
                      future: getAvatarByStreamId(id),
                      builder: (context, avatarSnapshot) {
                        return Container(
                          color: Colors.grey[800],
                          child: Center(
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage: avatarSnapshot.hasData ? NetworkImage(avatarSnapshot.data!) : null,
                              child: !avatarSnapshot.hasData ? Icon(Icons.person) : null,
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
                    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                    child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
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
        int columns = total <= 1 ? 1 : total <= 4 ? 2 : total <= 9 ? 3 : 4;
        int rows = (total / columns).ceil();

        return Center(
          child: Wrap(
            spacing: 0,
            runSpacing: 0,
            children: allCameras.entries.map((e) {
              return SizedBox(
                width: constraints.maxWidth / columns,
                height: constraints.maxHeight / rows,
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
    final shouldShow = isLocal ? isLocalCameraOn : true;

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
                  if (renderer.srcObject != null && shouldShow)
                    Positioned.fill(
                      child: RTCVideoView(renderer, mirror: isLocal, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
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
                                    backgroundImage: avatarSnapshot.hasData ? NetworkImage(avatarSnapshot.data!) : null,
                                    child: !avatarSnapshot.hasData ? Icon(Icons.person, size: 40) : null,
                                  ),
                                  SizedBox(height: 8),
                                  Text(name, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
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
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                      child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
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