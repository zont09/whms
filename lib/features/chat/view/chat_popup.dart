import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;

import 'package:whms/configs/config_cubit.dart';

class AppColors {
  static const Color primary1 = Color(0xFF0448db);
  static const Color primary2 = Color(0xFF006df5);
  static const Color primary3 = Color(0xFF0086f3);
  static const Color primary4 = Color(0xFF0099d8);
  static const Color primary5 = Color(0xFFabc5ff);
}

class ChatWidget extends StatefulWidget {
  final String userId;
  final String conversationId;
  final String apiBaseUrl;
  final String conversationName;
  final VoidCallback onClose;
  final WebSocketChannel? channel;
  final Stream<Map<String, dynamic>>? messageStream;

  const ChatWidget({
    super.key,
    required this.userId,
    required this.conversationId,
    required this.apiBaseUrl,
    required this.conversationName,
    required this.onClose,
    this.channel,
    this.messageStream,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> with TickerProviderStateMixin {
  final List<ChatMessage> messages = [];
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  WebSocketChannel? channel;
  bool isConnected = false;
  bool isMinimized = false;
  ChatMessage? replyingTo;
  String? hoveredMessageId;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final Map<String, GlobalKey> _messageKeys = {};
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;

  // ✅ THÊM: Set để track message IDs đã được thêm, tránh duplicate tuyệt đối
  final Set<String> _processedMessageIds = {};

  @override
  void initState() {
    super.initState();

    print('🚀 ChatWidget initState for conversation: ${widget.conversationId}');

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

    // ✅ QUAN TRỌNG: Clear messages cũ trước khi load mới
    messages.clear();

    loadMessages();
    connectWebSocket();
    _listenToMessageStream();
  }

  @override
  void dispose() {
    channel?.sink.close();
    messageController.dispose();
    scrollController.dispose();
    _slideController.dispose();
    _focusNode.dispose();
    _messageKeys.clear();
    _messageSubscription?.cancel();
    _processedMessageIds.clear();
    super.dispose();
  }

  // Placeholder functions for avatar and username
  String? _getAvatarUrl(String userId) {
    final cfC = ConfigsCubit.fromContext(context);
    return cfC.usersMap[userId]?.avt;
  }

  String? _getUserDisplayName(String userId) {
    final cfC = ConfigsCubit.fromContext(context);
    return cfC.usersMap[userId]?.name;
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
            _processedMessageIds.clear(); // ✅ Clear set khi load lại
            for (var msg in data['messages']) {
              final message = ChatMessage.fromJson(msg);
              messages.add(message);
              _processedMessageIds.add(message.id); // ✅ Track message ID
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
      // Nếu có channel từ parent (MultiChatManager), sử dụng nó
      if (widget.channel != null) {
        print('✅ Using existing WebSocket channel from parent for ${widget.conversationId}');
        channel = widget.channel;

        if (mounted) {
          setState(() {
            isConnected = true;
          });
        }

        // ❌ QUAN TRỌNG: KHÔNG THÊM LISTENER MỚI
        // Parent (MultiChatManager) đã listen rồi
        print('⚠️ Skipping duplicate listener setup - managed by parent');
        return;
      }

      // Chỉ tạo channel mới khi standalone mode (không có parent)
      print('🔗 Creating new WebSocket channel for ${widget.conversationId}');
      final wsUrl = widget.apiBaseUrl.replaceFirst('http', 'ws');
      final uri = Uri.parse(
          '$wsUrl/ws/chat/${widget.conversationId}/${widget.userId}');

      channel = WebSocketChannel.connect(uri);

      if (mounted) {
        setState(() {
          isConnected = true;
        });
      }

      // Chỉ thêm listener trong standalone mode
      channel!.stream.listen(
            (message) {
          print('📩 ChatWidget received message: $message');
          try {
            final data = json.decode(message);
            if (data['type'] == 'message' && data['message'] != null) {
              final newMsg = ChatMessage.fromJson(data['message']);
              if (mounted) {
                setState(() {
                  // ✅ SỬA: Dùng Set để check duplicate nhanh hơn
                  if (!_processedMessageIds.contains(newMsg.id)) {
                    messages.add(newMsg);
                    _processedMessageIds.add(newMsg.id);
                    print('✅ Added new message: ${newMsg.id}');
                  } else {
                    print('⚠️ Duplicate message detected in WebSocket, skipped: ${newMsg.id}');
                  }
                });
                scrollToBottom();
              }
            }
          } catch (e) {
            print('❌ Error parsing message in ChatWidget: $e');
          }
        },
        onError: (error) {
          print('❌ WebSocket error in ChatWidget: $error');
          if (mounted) {
            setState(() {
              isConnected = false;
            });
          }
        },
        onDone: () {
          print('🔌 WebSocket closed in ChatWidget');
          if (mounted) {
            setState(() {
              isConnected = false;
            });
          }
        },
      );
    } catch (e) {
      print('❌ Error connecting WebSocket in ChatWidget: $e');
      if (mounted) {
        setState(() {
          isConnected = false;
        });
      }
    }
  }

  void _listenToMessageStream() {
    if (widget.messageStream != null) {
      print('🎧 ChatWidget subscribing to message stream for ${widget.conversationId}');
      _messageSubscription = widget.messageStream!.listen(
            (messageData) {
          print('📨 ChatWidget received message from stream: $messageData');
          try {
            final newMsg = ChatMessage.fromJson(messageData);
            if (mounted) {
              setState(() {
                // ✅ SỬA: Dùng Set để check duplicate - nhanh và chính xác
                if (!_processedMessageIds.contains(newMsg.id)) {
                  messages.add(newMsg);
                  _processedMessageIds.add(newMsg.id);
                  print('✅ Added message to UI: ${newMsg.id} from ${newMsg.senderId}');
                } else {
                  print('⚠️ Duplicate message detected in stream, skipped: ${newMsg.id}');
                }
              });
              scrollToBottom();
            }
          } catch (e) {
            print('❌ Error processing message from stream: $e');
          }
        },
        onError: (error) {
          print('❌ Error in message stream: $error');
        },
      );
    } else {
      print('⚠️ No message stream provided from parent');
    }
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
            crossAxisAlignment: CrossAxisAlignment.end,
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
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppColors.primary5.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary5.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: messageController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn... (Enter: gửi, Shift+Enter: xuống hàng)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        sendMessage();
                      }
                    },
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: messageController.text.trim().isEmpty
                        ? [Colors.grey[300]!, Colors.grey[400]!]
                        : [AppColors.primary2, AppColors.primary3],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: messageController.text.trim().isEmpty
                      ? []
                      : [
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
                    onTap: messageController.text.trim().isEmpty
                        ? null
                        : sendMessage,
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
          // QUAN TRỌNG: Chỉ hiển thị "Đang kết nối lại" khi thực sự KHÔNG kết nối
          // Và channel != null (đang cố kết nối)
          if (!isConnected && channel != null)
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

    final content = messageController.text.trim();
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    // ✅ SỬA: KHÔNG thêm tin nhắn tạm vào UI nữa
    // Chỉ lưu lại replyTo và clear input
    final currentReplyTo = replyingTo?.id;

    setState(() {
      replyingTo = null;
    });

    messageController.clear();

    // Gửi qua WebSocket - server sẽ broadcast lại và UI sẽ nhận từ messageStream
    final messageData = {
      'type': 'message',
      'sender_id': widget.userId,
      'content': content,
      'attachments': [],
      if (currentReplyTo != null) 'reply_to': currentReplyTo,
    };

    print('Sending message: ${json.encode(messageData)}');
    channel!.sink.add(json.encode(messageData));
  }

  // ✅ SỬA: Sửa hàm uploadFile - không thêm tin nhắn tạm nữa
  Future<void> uploadFile() async {
    try {
      print('=== Starting file upload ===');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        print('File selected: ${file.name}, size: ${file.size} bytes');

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

        print('Sending upload request to: ${widget.apiBaseUrl}/chats/${widget.conversationId}/upload');
        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        print('Upload response: $responseData');

        final data = json.decode(responseData);

        if (data['ok'] == true && channel != null) {
          print('Upload successful! File ID: ${data['file_id']}, URL: ${data['url']}');

          final isMedia = _isImageFile(data['mime']) || _isVideoFile(data['mime']);
          final currentReplyTo = replyingTo?.id;

          // ✅ SỬA: KHÔNG thêm tin nhắn tạm vào UI
          setState(() {
            replyingTo = null;
          });

          // Gửi qua WebSocket - server sẽ broadcast và UI sẽ nhận từ messageStream
          final messageData = {
            'type': 'message',
            'sender_id': widget.userId,
            'content': isMedia ? '' : '📎 ${data['filename']}',
            'attachments': [
              {
                'file_id': data['file_id'],
                'filename': data['filename'],
                'mime': data['mime'],
                'url': data['url'],
              }
            ],
            if (currentReplyTo != null) 'reply_to': currentReplyTo,
          };

          print('Sending message with attachment: ${json.encode(messageData)}');
          channel!.sink.add(json.encode(messageData));
        } else {
          print('Upload failed or WebSocket not connected');
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

  bool _isVideoFile(String? mime) {
    if (mime == null) return false;
    return mime.startsWith('video/');
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
      return Container(
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
      );
    }

    return SlideTransition(
      position: _slideAnimation,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isConnected ? 'Đang hoạt động' : 'Mất kết nối',
                  style: TextStyle(
                    color: isConnected ? Colors.white70 : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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

          final isLastInSequence = index == messages.length - 1 ||
              messages[index + 1].senderId != msg.senderId ||
              _getTimeDifferenceMinutes(msg.createdAt, messages[index + 1].createdAt) > 5;

          final showTimeSeparator = index > 0 &&
              _getTimeDifferenceHours(messages[index - 1].createdAt, msg.createdAt) >= 1;

          if (!_messageKeys.containsKey(msg.id)) {
            _messageKeys[msg.id] = GlobalKey();
          }

          return Column(
            key: _messageKeys[msg.id],
            children: [
              if (showTimeSeparator) _buildTimeSeparator(msg.createdAt),
              _buildMessageBubble(msg, isOwn, isLastInSequence),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeSeparator(String timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _formatDateTimeSeparator(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey[300],
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  int _getTimeDifferenceMinutes(String time1, String time2) {
    try {
      final date1 = DateTime.parse(time1);
      final date2 = DateTime.parse(time2);
      return date2.difference(date1).inMinutes.abs();
    } catch (e) {
      return 0;
    }
  }

  int _getTimeDifferenceHours(String time1, String time2) {
    try {
      final date1 = DateTime.parse(time1);
      final date2 = DateTime.parse(time2);
      return date2.difference(date1).inHours.abs();
    } catch (e) {
      return 0;
    }
  }

  String _formatDateTimeSeparator(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDate = DateTime(date.year, date.month, date.day);

      if (messageDate == today) {
        return 'Hôm nay';
      } else if (messageDate == yesterday) {
        return 'Hôm qua';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  // ✅ SỬA: Tối ưu UI avatar để luôn thẳng hàng với dòng đầu tiên của tin nhắn
  Widget _buildMessageBubble(ChatMessage msg, bool isOwn, bool isLastInSequence) {
    final hasOnlyMedia = msg.content.isEmpty &&
        msg.attachments.isNotEmpty &&
        msg.attachments.every((att) {
          final mime = att['mime'] as String?;
          return mime != null &&
              (mime.startsWith('image/') || mime.startsWith('video/'));
        });

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredMessageId = msg.id),
      onExit: (_) => setState(() => hoveredMessageId = null),
      child: Align(
        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            bottom: 8,
            left: isOwn ? 60 : 0,
            right: isOwn ? 0 : 60,
          ),
          child: Row(
            mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isOwn) _buildReplyButton(msg, isOwn),
              // ✅ SỬA: Avatar luôn chiếm 48px (40 + 8 margin) để tin nhắn không bị lệch
              if (!isOwn)
                SizedBox(
                  width: 48, // 40px avatar + 8px margin
                  child: isLastInSequence
                      ? Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8, bottom: 20),
                    child: _buildAvatar(msg.senderId),
                  )
                      : null,
                ),
              Flexible(
                child: Column(
                  crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (msg.content.isNotEmpty || !hasOnlyMedia)
                      Container(
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
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  _getUserDisplayName(msg.senderId) ?? msg.senderId,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary2,
                                  ),
                                ),
                              ),
                            if (msg.replyTo != null)
                              _buildReplyIndicator(msg, isOwn),
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
                              ...msg.attachments.where((att) {
                                final mime = att['mime'] as String?;
                                return mime != null &&
                                    !mime.startsWith('image/') &&
                                    !mime.startsWith('video/');
                              }).map((att) => _buildFileAttachment(att, isOwn)),
                            ],
                          ],
                        ),
                      ),
                    if (msg.attachments.isNotEmpty)
                      ...msg.attachments.where((att) {
                        final mime = att['mime'] as String?;
                        return mime != null &&
                            (mime.startsWith('image/') || mime.startsWith('video/'));
                      }).map((att) {
                        final mime = att['mime'] as String?;
                        if (mime != null && mime.startsWith('image/')) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: msg.content.isEmpty && !hasOnlyMedia ? 0 : 4,
                            ),
                            child: _buildImagePreview(att, isOwn),
                          );
                        } else if (mime != null && mime.startsWith('video/')) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: msg.content.isEmpty && !hasOnlyMedia ? 0 : 4,
                            ),
                            child: _buildVideoPreview(att, isOwn),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    if (isLastInSequence)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                        child: Text(
                          _formatTime(msg.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isOwn) _buildReplyButton(msg, isOwn),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String userId) {
    final avatarUrl = _getAvatarUrl(userId);
    final displayName = _getUserDisplayName(userId) ?? userId;

    return Tooltip(
      message: displayName,
      child: avatarUrl != null
          ? CircleAvatar(
        radius: 16,
        backgroundImage: CachedNetworkImageProvider(avatarUrl),
      )
          : CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary5,
        child: Text(
          userId[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary2,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildReplyButton(ChatMessage msg, bool isOwn) {
    final isHovered = hoveredMessageId == msg.id;

    return Padding(
      padding: EdgeInsets.only(
        left: isOwn ? 8 : 0,
        right: isOwn ? 0 : 8,
        top: 4, // ✅ THÊM: padding top để thẳng hàng với tin nhắn
      ),
      child: IgnorePointer(
        ignoring: !isHovered,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isHovered ? 1.0 : 0.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  replyingTo = msg;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary5.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.reply_rounded,
                  size: 18,
                  color: AppColors.primary2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(Map<String, dynamic> att, bool isOwn) {
    final imageUrl = '${widget.apiBaseUrl}${att['url']}';

    return GestureDetector(
      onTap: () => _showImageDialog(att['url']),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 280,
          maxHeight: 350,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            httpHeaders: {
              'Accept': 'image/*',
            },
            placeholder: (context, url) => Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary2,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Không tải được ảnh',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreview(Map<String, dynamic> att, bool isOwn) {
    return GestureDetector(
      onTap: () => _showVideoDialog(att['url']),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 280,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 180,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: AppColors.primary2,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        att['filename'] ?? 'video',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
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
  }

  Widget _buildFileAttachment(Map<String, dynamic> att, bool isOwn) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOwn ? Colors.white.withOpacity(0.2) : AppColors.primary5.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file_rounded,
            size: 20,
            color: isOwn ? Colors.white : AppColors.primary2,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              att['filename'] ?? 'file',
              style: TextStyle(
                color: isOwn ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator(ChatMessage msg, bool isOwn) {
    final replyMsg = messages.firstWhere(
          (m) => m.id == msg.replyTo,
      orElse: () => ChatMessage(
        id: '',
        conversationId: '',
        senderId: '',
        content: 'Tin nhắn không tồn tại',
        attachments: [],
        createdAt: '',
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOwn ? Colors.white.withOpacity(0.2) : AppColors.primary5.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isOwn ? Colors.white : AppColors.primary2,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.reply_rounded,
                size: 12,
                color: isOwn ? Colors.white70 : AppColors.primary2,
              ),
              const SizedBox(width: 4),
              Text(
                _getUserDisplayName(replyMsg.senderId) ?? replyMsg.senderId,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isOwn ? Colors.white : AppColors.primary2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            replyMsg.content.isEmpty ? '📎 Attachment' : replyMsg.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isOwn ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoDialog(String videoUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: VideoPlayerWidget(
                videoUrl: '${widget.apiBaseUrl}$videoUrl',
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
                  'Reply to ${_getUserDisplayName(replyingTo!.senderId) ?? replyingTo!.senderId}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  replyingTo!.content.isEmpty
                      ? '📎 Attachment'
                      : replyingTo!.content,
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

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(date.year, date.month, date.day);

      if (messageDate != today) {
        return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
      _controller.play();
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              'Không thể phát video',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: AppColors.primary2,
              bufferedColor: Colors.white54,
              backgroundColor: Colors.white24,
            ),
          ),
          Positioned(
            bottom: 50,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black54,
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}