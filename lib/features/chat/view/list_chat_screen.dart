import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

import 'package:whms/features/chat/view/chat_popup.dart';

void main() {
  runApp(const MyApp());
}

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
      title: 'Multi Chat Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary2,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary2,
          primary: AppColors.primary2,
        ),
        useMaterial3: true,
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

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
        child: const Center(
          child: Text(
            'Multi Chat Manager Demo',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: MultiChatManager(
        userId: 'think',
        conversationIds: ['g1', 'conv_2', 'conv_3', 'conv_4', 'conv_5'],
        apiBaseUrl: 'http://127.0.0.1:8000/api',
      ),
    );
  }
}

class ConversationInfo {
  final String conversationId;
  int unreadCount;
  String? lastMessageId;
  bool isConnected;

  ConversationInfo({
    required this.conversationId,
    this.unreadCount = 0,
    this.lastMessageId,
    this.isConnected = false,
  });
}

class MultiChatManager extends StatefulWidget {
  final String userId;
  final List<String> conversationIds;
  final String apiBaseUrl;

  const MultiChatManager({
    super.key,
    required this.userId,
    required this.conversationIds,
    required this.apiBaseUrl,
  });

  @override
  State<MultiChatManager> createState() => _MultiChatManagerState();
}

class _MultiChatManagerState extends State<MultiChatManager>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  String? _selectedConversationId;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  // WebSocket management
  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, ConversationInfo> _conversationInfos = {};

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );

    // Initialize conversation infos
    for (var convId in widget.conversationIds) {
      _conversationInfos[convId] = ConversationInfo(conversationId: convId);
    }

    // Connect to all WebSockets
    _connectAllWebSockets();
  }

  @override
  void dispose() {
    _expandController.dispose();
    _disconnectAllWebSockets();
    super.dispose();
  }

  void _connectAllWebSockets() {
    for (var conversationId in widget.conversationIds) {
      _connectWebSocket(conversationId);
    }
  }

  void _connectWebSocket(String conversationId) {
    try {
      final wsUrl = widget.apiBaseUrl.replaceFirst('http', 'ws');
      final uri = Uri.parse('$wsUrl/ws/chat/$conversationId/${widget.userId}');

      print('Connecting WebSocket for $conversationId: $uri');

      final channel = WebSocketChannel.connect(uri);
      _channels[conversationId] = channel;

      if (mounted) {
        setState(() {
          _conversationInfos[conversationId]?.isConnected = true;
        });
      }

      print('WebSocket connected for $conversationId');

      channel.stream.listen(
            (message) {
          print('Received message on $conversationId: $message');
          try {
            final data = json.decode(message);
            print('Parsed data: $data');
            if (data['type'] == 'message' && data['message'] != null) {
              _handleNewMessage(conversationId, data['message']);
            }
          } catch (e) {
            print('Error parsing message for $conversationId: $e');
          }
        },
        onError: (error) {
          print('WebSocket ERROR for $conversationId: $error');
          if (mounted) {
            setState(() {
              _conversationInfos[conversationId]?.isConnected = false;
            });
          }

          // Reconnect after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              print('Attempting to reconnect $conversationId...');
              _connectWebSocket(conversationId);
            }
          });
        },
        onDone: () {
          print('WebSocket CLOSED for $conversationId');
          if (mounted) {
            setState(() {
              _conversationInfos[conversationId]?.isConnected = false;
            });
          }

          // Reconnect after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              print('Attempting to reconnect $conversationId...');
              _connectWebSocket(conversationId);
            }
          });
        },
      );
    } catch (e) {
      print('Error connecting WebSocket for $conversationId: $e');
      if (mounted) {
        setState(() {
          _conversationInfos[conversationId]?.isConnected = false;
        });
      }
    }
  }

  void _handleNewMessage(String conversationId, Map<String, dynamic> message) {
    final info = _conversationInfos[conversationId];
    if (info == null) return;

    final messageId = message['id'] as String?;
    final senderId = message['sender_id'] as String?;

    // Only increment unread count if:
    // 1. Message is not from current user
    // 2. This conversation is not currently selected (being viewed)
    if (senderId != widget.userId && _selectedConversationId != conversationId) {
      // Check if this is a new message (not duplicate)
      if (messageId != null && messageId != info.lastMessageId) {
        if (mounted) {
          setState(() {
            info.unreadCount++;
            info.lastMessageId = messageId;
          });
        }
      }
    } else if (_selectedConversationId == conversationId) {
      // If viewing this conversation, update last message but don't increment unread
      if (mounted) {
        setState(() {
          info.lastMessageId = messageId;
        });
      }
    }
  }

  void _disconnectAllWebSockets() {
    for (var channel in _channels.values) {
      channel.sink.close();
    }
    _channels.clear();
  }

  void _markAsRead(String conversationId) {
    if (mounted) {
      setState(() {
        _conversationInfos[conversationId]?.unreadCount = 0;
      });
    }
  }

  int _getTotalUnreadCount() {
    return _conversationInfos.values
        .fold(0, (sum, info) => sum + info.unreadCount);
  }

  // Placeholder function for conversation avatar
  String? _getConversationAvatar(String conversationId) {
    // TODO: Implement avatar fetching logic
    return null;
  }

  // Placeholder function for conversation name
  String? _getConversationName(String conversationId) {
    // TODO: Implement name fetching logic
    return null;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
        _selectedConversationId = null;
      }
    });
  }

  void _selectConversation(String conversationId) {
    setState(() {
      if (_selectedConversationId == conversationId) {
        _selectedConversationId = null;
      } else {
        _selectedConversationId = conversationId;
        // Mark as read when opening
        _markAsRead(conversationId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Chat popup on the left
        if (_selectedConversationId != null)
          Positioned(
            bottom: 20,
            right: 100,
            child: _buildChatPopup(_selectedConversationId!),
          ),

        // Conversation list
        if (_isExpanded)
          Positioned(
            bottom: 100,
            right: 20,
            child: _buildConversationList(),
          ),

        // Main FAB button
        Positioned(
          bottom: 20,
          right: 20,
          child: _buildMainButton(),
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    final totalUnread = _getTotalUnreadCount();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
              onTap: _toggleExpanded,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: AnimatedRotation(
                  turns: _isExpanded ? 0.125 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Total unread badge
        if (totalUnread > 0 && !_isExpanded)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Center(
                child: Text(
                  totalUnread > 99 ? '99+' : totalUnread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConversationList() {
    return FadeTransition(
      opacity: _expandAnimation,
      child: ScaleTransition(
        scale: _expandAnimation,
        alignment: Alignment.bottomRight,
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 400,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...widget.conversationIds.map((convId) {
                  final isSelected = _selectedConversationId == convId;
                  final info = _conversationInfos[convId];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildConversationItem(
                      convId,
                      isSelected,
                      info?.unreadCount ?? 0,
                      info?.isConnected ?? false,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(
      String conversationId,
      bool isSelected,
      int unreadCount,
      bool isConnected,
      ) {
    final avatarUrl = _getConversationAvatar(conversationId);
    final name = _getConversationName(conversationId) ?? conversationId;

    return GestureDetector(
      onTap: () => _selectConversation(conversationId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary2 : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary2.withOpacity(0.4)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Tooltip(
              message: name,
              child: Stack(
                children: [
                  avatarUrl != null
                      ? CircleAvatar(
                    radius: 26,
                    backgroundImage: CachedNetworkImageProvider(avatarUrl),
                  )
                      : CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary5,
                    child: Text(
                      conversationId[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary2,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Connection status indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.greenAccent : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Unread badge - chấm đỏ thông báo
            if (unreadCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPopup(String conversationId) {
    return Material(
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
        child: ChatWidget(
          userId: widget.userId,
          conversationId: conversationId,
          apiBaseUrl: widget.apiBaseUrl,
          onClose: () {
            setState(() {
              _selectedConversationId = null;
            });
          },
          // Pass the existing WebSocket channel to avoid duplicate connections
          channel: _channels[conversationId],
        ),
      ),
    );
  }
}