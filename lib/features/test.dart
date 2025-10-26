import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';


class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key, required this.name, required this.roomId});

  final String name;
  final String roomId;
  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> remoteRenderers = {};
  html.WebSocket? socket;
  final roomIdCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  String? myId;
  final Map<String, RTCPeerConnection> peers = {};

  @override
  void initState() {
    super.initState();
    roomIdCtrl.text = widget.roomId;
    nameCtrl.text = widget.name;
    localRenderer.initialize();
  }

  @override
  void dispose() {
    localRenderer.dispose();
    for (var r in remoteRenderers.values) {
      r.dispose();
    }
    socket?.close();
    super.dispose();
  }

  Future<void> startCall() async {
    final roomId = roomIdCtrl.text.trim();
    socket = html.WebSocket('ws://127.0.0.1:8000/ws/$roomId');

    socket!.onOpen.listen((_) {
      socket!.send(jsonEncode({"type": "join", "name": nameCtrl.text}));
    });

    socket!.onMessage.listen((event) async {
      final msg = jsonDecode(event.data);
      final type = msg['type'];
      switch (type) {
        case 'joined':
          myId = msg['clientId'];
          print("Joined with ID: $myId, peers: ${msg['peers']}");
          final stream = await navigator.mediaDevices
              .getUserMedia({'audio': true, 'video': true});
          localRenderer.srcObject = stream;
          for (var p in msg['peers']) {
            createOffer(p['clientId'], stream);
          }
          break;
        case 'peer-joined':
          print("Peer joined: ${msg['clientId']}");
          final stream = localRenderer.srcObject;
          if (stream != null) createOffer(msg['clientId'], stream);
          break;
        case 'offer':
          await handleOffer(msg);
          break;
        case 'answer':
          await handleAnswer(msg);
          break;
        case 'candidate':
          await handleCandidate(msg);
          break;
        case 'peer-left':
          removePeer(msg['clientId']);
          break;
      }
    });
  }

  Future<void> createOffer(String peerId, MediaStream stream) async {
    final pc = await createPeer(peerId, stream);
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    send({
      'type': 'offer',
      'to': peerId,
      'sdp': offer.sdp,
    });
  }

  Future<void> handleOffer(Map msg) async {
    final peerId = msg['from'];
    final stream = localRenderer.srcObject!;
    final pc = await createPeer(peerId, stream);
    await pc.setRemoteDescription(RTCSessionDescription(msg['sdp'], 'offer'));
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    send({'type': 'answer', 'to': peerId, 'sdp': answer.sdp});
  }

  Future<void> handleAnswer(Map msg) async {
    final peerId = msg['from'];
    final pc = peers[peerId];
    if (pc != null) {
      await pc.setRemoteDescription(RTCSessionDescription(msg['sdp'], 'answer'));
    }
  }

  Future<void> handleCandidate(Map msg) async {
    final peerId = msg['from'];
    final pc = peers[peerId];
    if (pc != null && msg['candidate'] != null) {
      await pc.addCandidate(RTCIceCandidate(
        msg['candidate']['candidate'],
        msg['candidate']['sdpMid'],
        msg['candidate']['sdpMLineIndex'],
      ));
    }
  }

  Future<RTCPeerConnection> createPeer(String peerId, MediaStream stream) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };
    final pc = await createPeerConnection(config);
    peers[peerId] = pc;
    stream.getTracks().forEach((t) => pc.addTrack(t, stream));

    pc.onIceCandidate = (cand) {
      if (cand.candidate != null) {
        send({
          'type': 'candidate',
          'to': peerId,
          'candidate': {
            'candidate': cand.candidate,
            'sdpMid': cand.sdpMid,
            'sdpMLineIndex': cand.sdpMLineIndex
          }
        });
      }
    };

    final remoteRenderer = RTCVideoRenderer();
    await remoteRenderer.initialize();
    pc.onTrack = (track) {
      if (track.streams.isNotEmpty) {
        remoteRenderer.srcObject = track.streams[0];
        setState(() {
          remoteRenderers[peerId] = remoteRenderer;
        });
      }
    };

    return pc;
  }

  void removePeer(String id) {
    peers[id]?.close();
    peers.remove(id);
    remoteRenderers[id]?.dispose();
    remoteRenderers.remove(id);
    setState(() {});
  }

  void send(Map data) {
    socket?.send(jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Meeting')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child: TextField(controller: roomIdCtrl, decoration: const InputDecoration(labelText: 'Room ID'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'))),
              ElevatedButton(onPressed: startCall, child: const Text("Join")),
            ],
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                RTCVideoView(localRenderer, mirror: true),
                ...remoteRenderers.values.map((r) => RTCVideoView(r))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
