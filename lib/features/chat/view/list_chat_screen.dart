import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:whms/configs/config_cubit.dart';
import 'dart:convert';

import 'package:whms/features/chat/view/chat_popup.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';


class AppColors {
  static const Color primary1 = Color(0xFF0448db);
  static const Color primary2 = Color(0xFF006df5);
  static const Color primary3 = Color(0xFF0086f3);
  static const Color primary4 = Color(0xFF0099d8);
  static const Color primary5 = Color(0xFFabc5ff);

  // Colors for distinguishing scopes and projects
  static const Color scopeColor = Color(0xFF00C853); // Green for scopes
  static const Color projectColor = Color(0xFFFF6D00); // Orange for projects
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
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, ConversationInfo> _conversationInfos = {};
  final Map<String, StreamController<Map<String, dynamic>>> _messageControllers = {};

  // Loading state for scopes and projects
  bool _isLoadingWorkUnits = true;
  List<WorkingUnitModel> _projects = [];
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    final scopeMap = ConfigsCubit.fromContext(context).allScopeMap;
    // Initialize WebSocket connections for all conversations
    for (var convId in widget.conversationIds) {
      _connectWebSocket(convId);
      _messageControllers[convId] = StreamController<Map<String, dynamic>>.broadcast();

      // Initialize conversation info
      _conversationInfos[convId] = ConversationInfo(
        id: convId,
        name: scopeMap[convId]?.title ?? convId,
        isConnected: false,
        unreadCount: 0,
        type: 'conversation',
        avatarUrl: null,
      );
    }

    // Load scopes and projects
    _loadScopesAndProjects();
  }

  Future<void> _loadScopesAndProjects() async {
    setState(() {
      _isLoadingWorkUnits = true;
      _loadError = null;
    });

    try {
      final projectService = WorkingService.instance;
      final result = await projectService.getScopesAndProjectsForUser(widget.userId);

      if (result.status == ResponseStatus.ok && result.results != null) {
        setState(() {
          _projects = result.results!['projects'] ?? [];
          _isLoadingWorkUnits = false;
        });

        // Initialize scopes and projects in conversation infos
        _initializeScopesAndProjects();

        // Connect WebSocket for scopes and projects

        for (var project in _projects) {
          _connectWebSocket(project.id);
          _messageControllers[project.id] = StreamController<Map<String, dynamic>>.broadcast();
        }
      } else {
        setState(() {
          _isLoadingWorkUnits = false;
          _loadError = 'Không thể tải scopes và projects';
        });
      }
    } catch (e) {
      print('Error loading scopes and projects: $e');
      setState(() {
        _isLoadingWorkUnits = false;
        _loadError = 'Lỗi: $e';
      });
    }
  }

  void _initializeScopesAndProjects() {
    // Add scopes as conversations
    for (var project in _projects) {
      _conversationInfos[project.id] = ConversationInfo(
        id: project.id,
        name: project.title,
        isConnected: false,
        unreadCount: 0,
        type: 'project',
        avatarUrl: null,
      );
    }
  }

  void _connectWebSocket(String conversationId) {
    try {
      print('🔌 Connecting WebSocket for conversation: $conversationId');

      String wsUrl = widget.apiBaseUrl;
      if (wsUrl.startsWith('https://')) {
        wsUrl = wsUrl.replaceFirst('https://', 'wss://');
      } else if (wsUrl.startsWith('http://')) {
        wsUrl = wsUrl.replaceFirst('http://', 'ws://');
      }
      final channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl/ws/$conversationId/${widget.userId}'),
      );

      _channels[conversationId] = channel;

      // Update connection status
      setState(() {
        final info = _conversationInfos[conversationId];
        if (info != null) {
          _conversationInfos[conversationId] = ConversationInfo(
            id: info.id,
            name: info.name,
            isConnected: true,
            unreadCount: info.unreadCount,
            type: info.type,
            avatarUrl: info.avatarUrl,
          );
        }
      });

      // Listen to messages
      channel.stream.listen(
            (message) {
          print('📨 Received WebSocket message in MultiChat: $message');
          final data = jsonDecode(message);

          if (data['type'] == 'message') {
            // Update unread count if not selected
            if (_selectedConversationId != conversationId) {
              setState(() {
                final info = _conversationInfos[conversationId];
                if (info != null) {
                  _conversationInfos[conversationId] = ConversationInfo(
                    id: info.id,
                    name: info.name,
                    isConnected: info.isConnected,
                    unreadCount: info.unreadCount + 1,
                    type: info.type,
                    avatarUrl: info.avatarUrl,
                  );
                }
              });
            }

            // Forward message to the message controller
            _messageControllers[conversationId]?.add(data);
          }
        },
        onError: (error) {
          print('❌ WebSocket error for $conversationId: $error');
          _updateConnectionStatus(conversationId, false);
        },
        onDone: () {
          print('🔌 WebSocket closed for $conversationId');
          _updateConnectionStatus(conversationId, false);
        },
      );
    } catch (e) {
      print('❌ Error connecting WebSocket for $conversationId: $e');
      _updateConnectionStatus(conversationId, false);
    }
  }

  void _updateConnectionStatus(String conversationId, bool isConnected) {
    setState(() {
      final info = _conversationInfos[conversationId];
      if (info != null) {
        _conversationInfos[conversationId] = ConversationInfo(
          id: info.id,
          name: info.name,
          isConnected: isConnected,
          unreadCount: info.unreadCount,
          type: info.type,
          avatarUrl: info.avatarUrl,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var channel in _channels.values) {
      channel.sink.close();
    }
    for (var controller in _messageControllers.values) {
      controller.close();
    }
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _selectedConversationId = null;
      }
    });
  }

  void _selectConversation(String conversationId) {
    print('🎯 Selecting conversation: $conversationId');
    print('Current selected: $_selectedConversationId');

    setState(() {
      // Reset unread count
      final info = _conversationInfos[conversationId];
      if (info != null) {
        _conversationInfos[conversationId] = ConversationInfo(
          id: info.id,
          name: info.name,
          isConnected: info.isConnected,
          unreadCount: 0,
          type: info.type,
          avatarUrl: info.avatarUrl,
        );
      }

      if (_selectedConversationId == conversationId) {
        print('❌ Closing current conversation');
        _selectedConversationId = null;
      } else {
        print('✅ Opening new conversation: $conversationId');
        _selectedConversationId = conversationId;
      }
    });
  }

  String _getConversationName(String conversationId) {
    final info = _conversationInfos[conversationId];
    if (info != null && info.name.isNotEmpty) {
      return info.name;
    }

    // Fallback for regular conversations
    final Map<String, String> names = {
      'g1': 'Nhóm 1',
      'conv_2': 'Nhóm 2',
      'conv_3': 'Nhóm 3',
      'conv_4': 'Nhóm 4',
      'conv_5': 'Nhóm 5',
    };
    return names[conversationId] ?? conversationId;
  }

  String? _getConversationAvatar(String conversationId) {
    // For scopes and projects, we can return null or use icon
    final info = _conversationInfos[conversationId];
    if (info != null && (info.type == 'scope' || info.type == 'project')) {
      return null; // Will show icon instead
    }

    // Fallback for regular conversations
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Conversation list (expanded)
        if (_isExpanded)
          Positioned(
            bottom: 80,
            right: 16,
            child: _buildConversationList(),
          ),

        // Selected chat popup
        if (_selectedConversationId != null)
          Positioned(
            bottom: 80,
            right: _isExpanded ? 100 : 80,
            child: _buildChatPopup(_selectedConversationId!),
          ),

        // Main FAB
        Positioned(
          bottom: 16,
          right: 16,
          child: _buildMainFAB(),
        ),
      ],
    );
  }

  Widget _buildMainFAB() {
    final totalUnread = _conversationInfos.values
        .fold<int>(0, (sum, info) => sum + info.unreadCount);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          onPressed: _toggleExpand,
          backgroundColor: AppColors.primary2,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: _isExpanded ? 0.125 : 0,
            child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
          ),
        ),
        if (totalUnread > 0)
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
            maxHeight: 500,
            maxWidth: 120,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Section header for conversations
                if (widget.conversationIds.isNotEmpty) ...[
                  _buildSectionHeader(
                    AppText.titleScope.text,
                    Icons.chat,
                    AppColors.primary2,
                  ),
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
                        'conversation',
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                ],

                // Section header for projects with loading state
                _buildSectionHeader(
                  'Projects',
                  Icons.folder_special,
                  AppColors.projectColor,
                ),
                if (_isLoadingWorkUnits)
                  ..._buildShimmerItems(3, 'project')
                else if (_projects.isNotEmpty)
                  ..._projects.map((project) {
                    final isSelected = _selectedConversationId == project.id;
                    final info = _conversationInfos[project.id];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildConversationItem(
                        project.id,
                        isSelected,
                        info?.unreadCount ?? 0,
                        info?.isConnected ?? false,
                        'project',
                      ),
                    );
                  }).toList()
                else
                  _buildEmptyState('Không có project'),

                // Error state
                if (_loadError != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 24),
                        const SizedBox(height: 8),
                        Text(
                          _loadError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loadScopesAndProjects,
                          child: const Text('Thử lại', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildShimmerItems(int count, String type) {
    return List.generate(
      count,
          (index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildConversationItem(
      String conversationId,
      bool isSelected,
      int unreadCount,
      bool isConnected,
      String type,
      ) {
    final avatarUrl = _getConversationAvatar(conversationId);
    final name = _getConversationName(conversationId);

    // Different colors for different types
    Color borderColor = isSelected ? AppColors.primary2 : Colors.transparent;
    Color avatarBgColor = AppColors.primary5;
    IconData? typeIcon;
    Color? typeIconColor;

    if (type == 'scope') {
      if (isSelected) borderColor = AppColors.scopeColor;
      avatarBgColor = AppColors.scopeColor.withOpacity(0.2);
      typeIcon = Icons.work_outline;
      typeIconColor = AppColors.scopeColor;
    } else if (type == 'project') {
      if (isSelected) borderColor = AppColors.projectColor;
      avatarBgColor = AppColors.projectColor.withOpacity(0.2);
      typeIcon = Icons.folder_special;
      typeIconColor = AppColors.projectColor;
    }

    return GestureDetector(
      onTap: () => _selectConversation(conversationId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? borderColor.withOpacity(0.4)
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
                    backgroundColor: avatarBgColor,
                    child: typeIcon != null
                        ? Icon(
                      typeIcon,
                      color: typeIconColor,
                      size: 24,
                    )
                        : Text(
                      _conversationInfos[conversationId]?.name[0] ?? conversationId[0].toUpperCase(),
                      style: TextStyle(
                        color: type == 'scope'
                            ? AppColors.scopeColor
                            : type == 'project'
                            ? AppColors.projectColor
                            : AppColors.primary2,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   right: 0,
                  //   child: Container(
                  //     width: 12,
                  //     height: 12,
                  //     decoration: BoxDecoration(
                  //       color: isConnected ? Colors.greenAccent : Colors.grey,
                  //       shape: BoxShape.circle,
                  //       border: Border.all(
                  //         color: Colors.white,
                  //         width: 2,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
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
    print('🏗️ Building ChatPopup for: $conversationId');

    return UniqueKey() != null
        ? SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..forward(),
        curve: Curves.easeOutCubic,
      )),
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
          child: ChatWidget(
            key: ValueKey('chat_$conversationId'),
            userId: widget.userId,
            conversationId: conversationId,
            apiBaseUrl: widget.apiBaseUrl,
            conversationName: _getConversationName(conversationId),
            onClose: () {
              setState(() {
                _selectedConversationId = null;
              });
            },
            messageStream: _messageControllers[conversationId]?.stream,
          ),
                ),
              ),
        )
        : const SizedBox.shrink();
  }
}

// Helper class to store conversation info
class ConversationInfo {
  final String id;
  final String name;
  final bool isConnected;
  final int unreadCount;
  final String type; // 'conversation', 'scope', or 'project'
  final String? avatarUrl;

  ConversationInfo({
    required this.id,
    required this.name,
    required this.isConnected,
    required this.unreadCount,
    required this.type,
    this.avatarUrl,
  });
}