import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'chat_popup.dart';

// Import your existing chat_popup.dart file

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
        conversationIds: ['g1', 'g2', 'g3', 'conv_4', 'conv_5'],
        apiBaseUrl: 'http://127.0.0.1:8000/api',
      ),
    );
  }
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
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
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
            right: 100, // Position to the left of conversation list
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildConversationItem(convId, isSelected),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationItem(String conversationId, bool isSelected) {
    final avatarUrl = _getConversationAvatar(conversationId);
    final name = _getConversationName(conversationId) ?? conversationId;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
            children: [
              Tooltip(
                message: name,
                child: avatarUrl != null
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
              ),
              // Unread badge (optional - can be enhanced)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
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
      ),
    );
  }

  Widget _buildChatPopup(String conversationId) {
    // This is a placeholder - you should replace this with your actual ChatWidget
    // import from chat_popup.dart and use it here
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
        )
      ),
    );

    // ACTUAL USAGE (uncomment when you import ChatWidget):
    /*
    return ChatWidget(
      userId: widget.userId,
      conversationId: conversationId,
      apiBaseUrl: widget.apiBaseUrl,
      onClose: () {
        setState(() {
          _selectedConversationId = null;
        });
      },
    );
    */
  }

  Widget _buildChatHeader(String conversationId) {
    final name = _getConversationName(conversationId) ?? conversationId;

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
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 22),
            onPressed: () {
              setState(() {
                _selectedConversationId = null;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}