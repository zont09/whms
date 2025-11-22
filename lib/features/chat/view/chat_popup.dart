// pubspec.yaml dependencies:
// dependencies:
//   flutter:
//     sdk: flutter
//   web_socket_channel: ^2.4.0
//   http: ^1.1.0
//   file_picker: ^6.1.1
//   cached_network_image: ^3.3.0

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MyApp());
}

// Theme Colors
class AppColors {
  static const Color primary1 = Color(0xFF0448db);
  static const Color primary2 = Color(0xFF006df5);
  static const Color primary3 = Color(0xFF0086f3);
  static const Color primary4 = Color(0xFF0099d8);
  static const Color primary5 = Color(0xFFabc5ff);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat Widget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary2,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary2,
          primary: AppColors.primary2,
        ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary5.withOpacity(0.2),
              AppColors.primary4.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 650),
            margin: const EdgeInsets.all(32),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary2, AppColors.primary3],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flutter Chat Widget',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Real-time messaging platform',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: apiUrlController,
                      label: 'API Base URL',
                      icon: Icons.link,
                      hint: 'http://localhost:8000',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: userIdController,
                      label: 'User ID',
                      icon: Icons.person,
                      hint: 'user_123',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: conversationIdController,
                      label: 'Conversation ID',
                      icon: Icons.chat,
                      hint: 'conv_001',
                    ),
                    const SizedBox(height: 28),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary2, AppColors.primary3],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary2.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              showChat = !showChat;
                            });
                          },
                          child: Center(
                            child: Text(
                              showChat ? 'Ẩn Chat Widget' : 'Mở Chat Widget',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary5.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary5.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 18, color: AppColors.primary2),
                              const SizedBox(width: 8),
                              const Text(
                                'Tính năng',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFeatureItem('✨ Real-time chat với WebSocket'),
                          _buildFeatureItem('🖼️ Hiển thị & zoom ảnh'),
                          _buildFeatureItem('💬 Reply tin nhắn'),
                          _buildFeatureItem('📎 Upload & download file'),
                          _buildFeatureItem('🎨 UI hiện đại, mượt mà'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary2, width: 2),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
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

class _ChatWidgetState extends State<ChatWidget> with TickerProviderStateMixin {
  final List<ChatMessage> messages = [];
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  WebSocketChannel? channel;
  bool isConnected = false;
  bool isMinimized = false;
  ChatMessage? replyingTo;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
    loadMessages();
    connectWebSocket();
  }

  @override
  void dispose() {
    channel?.sink.close();
    messageController.dispose();
    scrollController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> loadMessages() async {
    try {
      final url =
          '${widget.apiBaseUrl}/chats/${widget.conversationId}/messages?limit=50';
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
      final uri = Uri.parse(
          '$wsUrl/ws/chat/${widget.conversationId}/${widget.userId}');

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
      if (replyingTo != null) 'reply_to': replyingTo!.id,
    };

    channel!.sink.add(json.encode(messageData));
    messageController.clear();
    setState(() {
      replyingTo = null;
    });
  }

  Future<void> uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        final request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '${widget.apiBaseUrl}/chats/${widget.conversationId}/upload'),
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
          final isImage = _isImageFile(data['mime']);
          final messageData = {
            'type': 'message',
            'sender_id': widget.userId,
            'content': isImage ? '' : '📎 ${data['filename']}',
            'attachments': [
              {
                'file_id': data['file_id'],
                'filename': data['filename'],
                'mime': data['mime'],
                'url': data['url'],
              }
            ],
            if (replyingTo != null) 'reply_to': replyingTo!.id,
          };
          channel!.sink.add(json.encode(messageData));
          setState(() {
            replyingTo = null;
          });
        }
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  bool _isImageFile(String? mime) {
    if (mime == null) return false;
    return mime.startsWith('image/');
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: '${widget.apiBaseUrl}$imageUrl',
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isMinimized) {
      return Positioned(
        bottom: 20,
        right: 20,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary2, AppColors.primary3],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary2.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                setState(() {
                  isMinimized = false;
                });
                _slideController.forward();
              },
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Icon(Icons.chat_bubble_rounded,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      );
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Positioned(
        bottom: 20,
        right: 20,
        child: Material(
          elevation: 20,
          borderRadius: BorderRadius.circular(20),
          shadowColor: AppColors.primary2.withOpacity(0.3),
          child: Container(
            width: 420,
            height: 650,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary5.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildMessagesList()),
                if (replyingTo != null) _buildReplyPreview(),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary2, AppColors.primary3],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary2.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chat_bubble_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chat Room',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Real-time messaging',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isConnected ? Colors.greenAccent : Colors.redAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? Colors.greenAccent : Colors.redAccent)
                      .withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 22),
            onPressed: () {
              setState(() {
                isMinimized = true;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 22),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary5.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          final isOwn = msg.senderId == widget.userId;
          final showAvatar = index == 0 ||
              messages[index - 1].senderId != msg.senderId;

          return _buildMessageBubble(msg, isOwn, showAvatar);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isOwn, bool showAvatar) {
    final hasImage = msg.attachments.any(
            (att) => att['mime'] != null && _isImageFile(att['mime']));

    return Align(
      alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isOwn ? 60 : 0,
          right: isOwn ? 0 : 60,
        ),
        child: Row(
          mainAxisAlignment:
          isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isOwn && showAvatar)
              Container(
                margin: const EdgeInsets.only(right: 8, bottom: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary5,
                  child: Text(
                    msg.senderId[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary2,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else if (!isOwn)
              const SizedBox(width: 40),
            Flexible(
              child: GestureDetector(
                onLongPress: () {
                  setState(() {
                    replyingTo = msg;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: isOwn
                        ? const LinearGradient(
                      colors: [AppColors.primary2, AppColors.primary3],
                    )
                        : null,
                    color: isOwn ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isOwn ? 16 : 4),
                      bottomRight: Radius.circular(isOwn ? 4 : 16),
                    ),
                    border: isOwn
                        ? null
                        : Border.all(color: AppColors.primary5.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: isOwn
                            ? AppColors.primary2.withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isOwn)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            msg.senderId,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary2,
                            ),
                          ),
                        ),
                      if (msg.replyTo != null) _buildReplyIndicator(msg),
                      if (msg.content.isNotEmpty)
                        Text(
                          msg.content,
                          style: TextStyle(
                            color: isOwn ? Colors.white : Colors.black87,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      if (msg.attachments.isNotEmpty) ...[
                        if (msg.content.isNotEmpty) const SizedBox(height: 8),
                        ...msg.attachments.map((att) {
                          if (_isImageFile(att['mime'])) {
                            return GestureDetector(
                              onTap: () => _showImageDialog(att['url']),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: '${widget.apiBaseUrl}${att['url']}',
                                  width: 250,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 250,
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isOwn
                                    ? Colors.white.withOpacity(0.2)
                                    : AppColors.primary5.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    size: 16,
                                    color:
                                    isOwn ? Colors.white : AppColors.primary2,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      att['filename'] ?? 'File',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isOwn
                                            ? Colors.white
                                            : AppColors.primary2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }).toList(),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(msg.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isOwn ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyIndicator(ChatMessage msg) {
    final replyMsg = messages.firstWhere(
          (m) => m.id == msg.replyTo,
      orElse: () => ChatMessage(
        id: '',
        conversationId: '',
        senderId: '',
        content: 'Message not found',
        attachments: [],
        createdAt: '',
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.5), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyMsg.senderId,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyMsg.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary5.withOpacity(0.1),
        border: Border(
          top: BorderSide(color: AppColors.primary5.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            color: AppColors.primary2,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reply to ${replyingTo!.senderId}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyingTo!.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                replyingTo = null;
              });
            },
            color: Colors.grey[600],
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary5.withOpacity(0.3),
                      AppColors.primary5.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: uploadFile,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.attach_file_rounded,
                        color: AppColors.primary2,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary5.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary5.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary2, AppColors.primary3],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary2.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: sendMessage,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!isConnected)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Đang kết nối lại...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 0) {
        return '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }
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
  final String? replyTo;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.attachments,
    required this.createdAt,
    this.replyTo,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      attachments: json['attachments'] ?? [],
      createdAt: json['created_at'] ?? '',
      replyTo: json['reply_to'],
    );
  }
}