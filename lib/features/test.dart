// signaling.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/widgets/z_space.dart';

class Signaling {
  final String wsUrl; // e.g. ws://yourserver:8000/ws/roomId/clientId
  WebSocketChannel? _channel;
  MediaStream? localStream;
  Map<String, RTCPeerConnection> pcs = {};
  Map<String, MediaStream> remoteStreams = {};
  String clientId;
  final Map<String, List<RTCIceCandidate>> pendingCandidates = {};

  Signaling({required this.wsUrl, required this.clientId});

  void Function(String peerId, MediaStream stream)? onAddRemoteStream;
  void Function(String peerId)? onRemoveRemoteStream;

  Future<void> initLocalStream({bool audio = true, bool video = true}) async {
    final mediaConstraints = {
      'audio': audio,
      'video': video ? {'facingMode': 'user'} : false,
    };
    localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
  }

  Future<void> start(String roomId) async {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _channel!.stream.listen((message) {
      final Map msg = jsonDecode(message);
      _handleMessage(msg);
    });
  }

  Future<RTCPeerConnection> _createPeer(String peerId, bool polite) async {
    final Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        // Ví dụ TURN (thay bằng TURN server của bạn nếu có)
        // { 'urls': 'turn:your.turn.server:3478', 'username': 'user', 'credential': 'pass' },
      ],
      'sdpSemantics': 'unified-plan',
      // nên để unified-plan cho flutter_webrtc hiện tại
    };
    final pc = await createPeerConnection(config);

    // thêm track local
    localStream?.getTracks().forEach((t) => pc.addTrack(t, localStream!));

    // ICE
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

    // nhận remote track
    pc.onTrack = (event) {
      final track = event.track;
      debugPrint('[THINK] ====> onTrack kind=${track.kind}, streamId=${event.streams.first.id}');

      // Tách camera & screen theo streamId khác nhau
      final streamId = event.streams.first.id;
      if (!remoteStreams.containsKey(streamId)) {
        remoteStreams[streamId] = event.streams.first;
        onAddRemoteStream?.call(streamId, event.streams.first);
      }
    };

    // tạo offer ngay sau khi thêm track
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

  void _handleMessage(Map msg) async {
    final type = msg['type'];
    final from = msg['from'];

    if (type == 'join') {
      // chỉ peer đã có trong phòng mới tạo offer cho peer mới
      if (from != clientId && !pcs.containsKey(from)) {
        await _createPeer(from, false);
      }
    } else if (type == 'offer' && msg['to'] == clientId) {
      final sdp = RTCSessionDescription(msg['sdp']['sdp'], msg['sdp']['type']);
      // đảm bảo có pc (không auto-offer)
      var pc = pcs[from] ?? await _createPeerConnectionOnly(from);

      // phân biệt polite/impolite (tùy thiết kế)
      final polite =
          true; // set local là polite hoặc quyết định từ logic của bạn

      // kiểm tra state
      final state = await pc.getSignalingState();
      final isStable = state == RTCSignalingState.RTCSignalingStateStable;

      if (!isStable && !polite) {
        // impolite: bỏ qua offer tới trễ
        return;
      }

      if (!isStable && polite) {
        // polite: đóng pc hiện tại và tạo lại mới (thay vì rollback)
        try {
          await pc.close();
        } catch (_) {}
        pcs.remove(from);
        pc = await _createPeerConnectionOnly(from);
      }

      // set remote và flush ICE queued
      await pc.setRemoteDescription(sdp);
      await _flushPendingCandidates(from, pc);

      // tạo answer và gửi
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
      final from = msg['from'];
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
        } catch (e) {
          // ignore lỗi candidate trùng
        }
      }
    } else if (type == 'leave') {
      final leaving = msg['from'];
      await pcs[leaving]?.close();
      pcs.remove(leaving);
      remoteStreams.remove(leaving);
      onRemoveRemoteStream?.call(leaving);
    } else if (type == 'stop_screen_share') {
      final from = msg['from'];
      final screenId = 'screen_$from';

      if (remoteStreams.containsKey(screenId)) {
        onRemoveRemoteStream?.call(screenId);
        remoteStreams.remove(screenId);
        debugPrint('[THINK] ====> peer stopped screen share: $screenId');
      }
    }
  }

  Future<RTCPeerConnection> _createPeerConnectionOnly(String peerId) async {
    final Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan',
    };
    final pc = await createPeerConnection(config);

    // thêm track local
    localStream?.getTracks().forEach((t) => pc.addTrack(t, localStream!));

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
        remoteStreams[peerId] = event.streams[0];
        onAddRemoteStream?.call(peerId, event.streams[0]);
        debugPrint("[THINK] ====> check add on Track create: $peerId");
      }
    };

    pcs[peerId] = pc;
    return pc;
  }

  void _send(Map data) {
    _channel?.sink.add(jsonEncode(data));
  }

  Future<void> toggleMicrophone(bool enabled) async {
    localStream?.getAudioTracks().forEach((t) => t.enabled = enabled);
  }

  Future<void> startScreenShare() async {
    // Lấy stream màn hình
    final screenStream = await navigator.mediaDevices.getDisplayMedia({
      'video': true,
      'audio': false,
    });

    final screenTrack = screenStream
        .getVideoTracks()
        .first;

    // Thêm track vào tất cả peer connections
    for (final entry in pcs.entries) {
      final peerId = entry.key;
      final pc = entry.value;

      await pc.addTrack(screenTrack, screenStream);

      // 🔥 Tạo offer mới để cập nhật stream tới peer đó
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      _send({
        'type': 'offer',
        'to': peerId,
        'from': clientId,
        'sdp': offer.toMap(),
      });
    }

    // Hiển thị local screen share trong UI (tạo video tile riêng)
    onAddRemoteStream?.call('screen_$clientId', screenStream);

    // Khi người dùng dừng chia sẻ
    screenTrack.onEnded = () async {
      debugPrint('[THINK] ====> screen share stopped');

      for (final entry in pcs.entries) {
        final peerId = entry.key;
        final pc = entry.value;

        // Gỡ track màn hình ra khỏi connection
        final senders = await pc.getSenders();
        for (final s in senders) {
          if (s.track?.id == screenTrack.id) {
            await pc.removeTrack(s);
          }
        }

        // Gửi offer mới để peer kia cập nhật lại SDP
        final offer = await pc.createOffer();
        await pc.setLocalDescription(offer);
        _send({
          'type': 'offer',
          'to': peerId,
          'from': clientId,
          'sdp': offer.toMap(),
        });
      }

      // Gửi thông báo cho mọi peer biết là stop share
      _send({'type': 'stop_screen_share', 'from': clientId});

      onRemoveRemoteStream?.call('screen_$clientId');
    };
  }

  Future<void> _flushPendingCandidates(
    String peerId,
    RTCPeerConnection pc,
  ) async {
    final list = pendingCandidates[peerId];
    if (list == null) return;
    for (var c in List<RTCIceCandidate>.from(list)) {
      try {
        await pc.addCandidate(c);
      } catch (e) {
        // ignore nếu vẫn lỗi (ví dụ candidate trùng)
      }
    }
    pendingCandidates.remove(peerId);
  }

  Future<void> dispose() async {
    for (var pc in pcs.values) {
      await pc.close();
    }
    pcs.clear();
    localStream?.getTracks().forEach((t) => t.stop());

    _channel?.sink.close();
  }
}

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  Signaling? signaling;
  final roomId = "room1";
  late String clientId;
  bool isOnMic = false;
  bool isOnCam = true;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    clientId = Random().nextInt(99999).toString();
    _initSignaling();
  }

  Future<void> _initSignaling() async {
    signaling = Signaling(
      wsUrl: "ws://127.0.0.1:8000/ws/$roomId/$clientId", // đổi theo server
      clientId: clientId,
    );

    await signaling!.initLocalStream();
    _localRenderer.srcObject = signaling!.localStream;
    await signaling!.start(roomId);

    // cập nhật khi có remote stream
    signaling!.onAddRemoteStream = (peerId, stream) async {
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      renderer.srcObject = stream;
      setState(() => _remoteRenderers[peerId] = renderer);
    };

    signaling!.onRemoveRemoteStream = (peerId) {
      _remoteRenderers[peerId]?.dispose();
      setState(() => _remoteRenderers.remove(peerId));
    };
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    for (var r in _remoteRenderers.values) {
      r.dispose();
    }
    signaling?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRenderers = [
      RTCVideoView(_localRenderer, mirror: true),
      ..._remoteRenderers.values.map((r) => RTCVideoView(r)),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Meeting'),
      ),
      body: Stack(
        children: [
          MeetLayout(
            localRenderer: _localRenderer,
            remoteRenderers: _remoteRenderers,
          ),
          Positioned(

            // left: 0,
            //   right: 0,
            //   bottom: ,
            bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      signaling?.toggleMicrophone(!isOnMic);
                      setState(() {
                        isOnMic = !isOnMic;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFEBEBEB),
                        boxShadow: const [ColorConfig.boxShadow2]
                      ),
                      padding: EdgeInsets.all(9),
                      child: Icon(isOnMic ? Icons.mic : Icons.mic_off),
                    ),
                  ),
                  const ZSpace(w: 9),
                  InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      // signaling?.toggleMicrophone(!isOnMic);
                      // setState(() {
                      //   isOnMic = !isOnMic;
                      // });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEBEBEB),
                          boxShadow: const [ColorConfig.boxShadow2]
                      ),
                      padding: EdgeInsets.all(9),
                      child: Icon(isOnCam ? Icons.videocam : Icons.videocam_off),
                    ),
                  ),
                  const ZSpace(w: 9),
                  InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: (){
                      signaling?.startScreenShare();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEBEBEB),
                          boxShadow: const [ColorConfig.boxShadow2]
                      ),
                      padding: EdgeInsets.all(9),
                      child: Icon(Icons.screen_share),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}

class MeetLayout extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final Map<String, RTCVideoRenderer> remoteRenderers;

  const MeetLayout({
    super.key,
    required this.localRenderer,
    required this.remoteRenderers,
  });

  @override
  Widget build(BuildContext context) {
    final allRenderers = {'You': localRenderer, ...remoteRenderers};

    final total = allRenderers.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        // xác định số cột và hàng hợp lý (kiểu Google Meet)
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
            children: allRenderers.entries.map((e) {
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

  Widget _buildVideoTile(String name, RTCVideoRenderer renderer) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: RTCVideoView(renderer, mirror: name == 'You'),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  name.startsWith('screen_') ? 'Screen Share from: $name' : name,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
