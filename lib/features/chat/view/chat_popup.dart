// pubspec.yaml dependencies cần thêm:
// dependencies:
//   flutter:
//     sdk: flutter
//   web_socket_channel: ^2.4.0
//   http: ^1.1.0
//   file_picker: ^6.1.1

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat Widget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatDemo(),
    );
  }
}

class ChatDemo extends StatefulWidget {
  const ChatDemo({super.key});

  @override
  State<ChatDemo> createState() => _ChatDemoState();
}

class _ChatDemoState extends State<ChatDemo> {
  final userIdController = TextEditingController(text: 'user_123');
  final conversationIdController = TextEditingController(text: 'conv_001');
  final apiUrlController = TextEditingController(text: 'http://localhost:8000');
  bool showChat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF6FF), Color(0xFFE0E7FF)],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.all(32),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Flutter Chat Widget Demo',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: apiUrlController,
                      decoration: const InputDecoration(
                        labelText: 'API Base URL',
                        border: OutlineInputBorder(),
                        hintText: 'http://localhost:8000',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: userIdController,
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        border: OutlineInputBorder(),
                        hintText: 'user_123',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: conversationIdController,
                      decoration: const InputDecoration(
                        labelText: 'Conversation ID',
                        border: OutlineInputBorder(),
                        hintText: 'conv_001',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showChat = !showChat;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        showChat ? 'Ẩn Chat Widget' : 'Hiện Chat Widget',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hướng dẫn:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Nhập API URL của backend\n'
                                '• Nhập User ID và Conversation ID\n'
                                '• Click "Hiện Chat Widget"\n'
                                '• Widget xuất hiện góc dưới phải\n'
                                '• Hỗ trợ real-time chat & upload file',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: showChat
          ? ChatWidget(
        userId: userIdController.text,
        conversationId: conversationIdController.text,
        apiBaseUrl: apiUrlController.text,
        onClose: () {
          setState(() {
            showChat = false;
          });
        },
      )
          : null,
    );
  }
}

class ChatWidget extends StatefulWidget {
  final String userId;
  final String conversationId;
  final String apiBaseUrl;
  final VoidCallback onClose;

  const ChatWidget({
    super.key,
    required this.userId,
    required this.conversationId,
    required this.apiBaseUrl,
    required this.onClose,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final List<ChatMessage> messages = [];
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  WebSocketChannel? channel;
  bool isConnected = false;
  bool isMinimized = false;

  @override
  void initState() {
    super.initState();
    loadMessages();
    connectWebSocket();
  }

  @override
  void dispose() {
    channel?.sink.close();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadMessages() async {
    try {
      final url = '${widget.apiBaseUrl}/chats/${widget.conversationId}/messages?limit=50';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true && data['messages'] != null) {
          setState(() {
            messages.clear();
            for (var msg in data['messages']) {
              messages.add(ChatMessage.fromJson(msg));
            }
          });
          scrollToBottom();
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  void connectWebSocket() {
    try {
      final wsUrl = widget.apiBaseUrl.replaceFirst('http', 'ws');
      final uri = Uri.parse('$wsUrl/ws/chat/${widget.conversationId}/${widget.userId}');

      channel = WebSocketChannel.connect(uri);

      setState(() {
        isConnected = true;
      });

      channel!.stream.listen(
            (message) {
          try {
            final data = json.decode(message);
            if (data['type'] == 'message' && data['message'] != null) {
              final newMsg = ChatMessage.fromJson(data['message']);
              setState(() {
                if (!messages.any((m) => m.id == newMsg.id)) {
                  messages.add(newMsg);
                }
              });
              scrollToBottom();
            }
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          setState(() {
            isConnected = false;
          });
          print('WebSocket error: $error');
        },
        onDone: () {
          setState(() {
            isConnected = false;
          });
          print('WebSocket closed');
        },
      );
    } catch (e) {
      print('Error connecting WebSocket: $e');
      setState(() {
        isConnected = false;
      });
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty || channel == null) return;

    final messageData = {
      'type': 'message',
      'sender_id': widget.userId,
      'content': messageController.text.trim(),
      'attachments': [],
    };

    channel!.sink.add(json.encode(messageData));
    messageController.clear();
  }

  Future<void> uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${widget.apiBaseUrl}/chats/${widget.conversationId}/upload'),
        );

        request.fields['sender_id'] = widget.userId;
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));

        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);

        if (data['ok'] == true && channel != null) {
          final messageData = {
            'type': 'message',
            'sender_id': widget.userId,
            'content': '📎 ${data['filename']}',
            'attachments': [
              {
                'file_id': data['file_id'],
                'filename': data['filename'],
                'mime': data['mime'],
                'url': data['url'],
              }
            ],
          };
          channel!.sink.add(json.encode(messageData));
        }
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isMinimized) {
      return Positioned(
        bottom: 16,
        right: 16,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              isMinimized = false;
            });
          },
          child: const Icon(Icons.chat),
        ),
      );
    }

    return Positioned(
      bottom: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 380,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Chat',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.minimize, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          isMinimized = true;
                        });
                      },
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: widget.onClose,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isOwn = msg.senderId == widget.userId;

                      return Align(
                        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: const BoxConstraints(maxWidth: 280),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isOwn ? Colors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isOwn ? null : Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isOwn)
                                Text(
                                  msg.senderId,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              if (!isOwn) const SizedBox(height: 4),
                              Text(
                                msg.content,
                                style: TextStyle(
                                  color: isOwn ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (msg.attachments.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ...msg.attachments.map((att) => Text(
                                  att['filename'] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    color: isOwn ? Colors.white : Colors.blue,
                                  ),
                                )),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(msg.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isOwn ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: uploadFile,
                          color: Colors.grey[600],
                        ),
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: const InputDecoration(
                              hintText: 'Nhập tin nhắn...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: sendMessage,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    if (!isConnected)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Đang kết nối lại...',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final List<dynamic> attachments;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.attachments,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      attachments: json['attachments'] ?? [],
      createdAt: json['created_at'] ?? '',
    );
  }
}