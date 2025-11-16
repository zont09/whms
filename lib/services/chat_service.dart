import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whms/models/message_model.dart';
import 'package:http/http.dart' as http;

class ChatWebSocketService {
  WebSocketChannel? _channel;

  Stream<dynamic>? get stream => _channel?.stream;

  void connect(String conversationId, String clientId) {
    _channel = WebSocketChannel.connect(
      Uri.parse("ws://localhost:8000/api/ws/chat/$conversationId/$clientId"),
    );
  }

  void sendMessage(String conversationId, String senderId, String content) {
    final msg = {
      "type": "message",
      "conversation_id": conversationId,
      "sender_id": senderId,
      "content": content,
    };
    _channel?.sink.add(jsonEncode(msg));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}

class ChatApiService {
  final String base = "http://localhost:8000/api/chats";

  Future<List<ChatMessage>> loadMessages(String conversationId) async {
    final res = await http.get(Uri.parse("$base/$conversationId/messages"));
    final data = jsonDecode(res.body);

    return (data["messages"] as List)
        .map((e) => ChatMessage.fromJson(e))
        .toList();
  }

  Future<void> sendHttpMessage(
      String conversationId, String senderId, String content) async {
    await http.post(
      Uri.parse("$base/$conversationId/messages"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sender_id": senderId,
        "content": content,
      }),
    );
  }
}
