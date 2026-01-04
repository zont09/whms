import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/notification_model.dart';
import 'package:whms/services/notification_service.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationPanelWidget extends StatefulWidget {
  final String userId;

  const NotificationPanelWidget({super.key, required this.userId});

  @override
  State<NotificationPanelWidget> createState() =>
      _NotificationPanelWidgetState();
}

class _NotificationPanelWidgetState extends State<NotificationPanelWidget> {
  final NotificationService _notificationService = NotificationService.instance;

  @override
  void initState() {
    super.initState();
    // Cấu hình timeago cho tiếng Việt nếu cần
    timeago.setLocaleMessages('vi', timeago.ViMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(400, context),
      height: ScaleUtils.scaleSize(500, context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          const Divider(height: 1),

          // Notification list
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationService.notificationsStream(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  debugPrint("[THINK] ====> error: ${snapshot.error}");
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    vertical: ScaleUtils.scaleSize(8, context),
                  ),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(notifications[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ScaleUtils.scaleSize(16, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Thông báo',
            style: TextStyle(
              fontSize: ScaleUtils.scaleSize(18, context),
              fontWeight: FontWeight.bold,
              color: ColorConfig.primary1,
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () async {
                  await _notificationService.markAllAsRead(widget.userId);
                },
                child: Text(
                  'Đánh dấu đã đọc',
                  style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(13, context),
                    color: ColorConfig.primary1,
                  ),
                ),
              ),
              SizedBox(width: ScaleUtils.scaleSize(16, context)),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.close,
                  size: ScaleUtils.scaleSize(20, context),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: ScaleUtils.scaleSize(64, context),
            color: Colors.grey[400],
          ),
          SizedBox(height: ScaleUtils.scaleSize(16, context)),
          Text(
            'Không có thông báo',
            style: TextStyle(
              fontSize: ScaleUtils.scaleSize(16, context),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return InkWell(
      onTap: () async {
        if (!notification.isRead) {
          await _notificationService.markAsRead(notification.id);
        }
        _navigateToTask(notification);

        // Đóng panel
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Navigate đến task (bạn cần implement logic này)
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(16, context),
          vertical: ScaleUtils.scaleSize(12, context),
        ),
        color: notification.isRead
            ? Colors.white
            : ColorConfig.primary1.withOpacity(0.05),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: ScaleUtils.scaleSize(40, context),
              height: ScaleUtils.scaleSize(40, context),
              decoration: BoxDecoration(
                color: Color(notification.colorCode).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconByType(notification.type),
                color: Color(notification.colorCode),
                size: ScaleUtils.scaleSize(20, context),
              ),
            ),
            SizedBox(width: ScaleUtils.scaleSize(12, context)),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(14, context),
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ScaleUtils.scaleSize(4, context)),
                  Text(
                    timeago.format(
                      notification.createdAt.toDate(),
                      locale: 'vi',
                    ),
                    style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (!notification.isRead)
              Container(
                width: ScaleUtils.scaleSize(8, context),
                height: ScaleUtils.scaleSize(8, context),
                decoration: BoxDecoration(
                  color: ColorConfig.primary1,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconByType(NotificationType type) {
    switch (type) {
      case NotificationType.taskStatusUpdate:
        return Icons.update;
      case NotificationType.taskAssigned:
        return Icons.person_add;
      case NotificationType.taskUnassigned:
        return Icons.person_remove;
    }
  }

  void _navigateToTask(NotificationModel notification) {
    debugPrint('Navigate to task: ${notification.taskId}');
    debugPrint('Path: ${notification.pathToTask}');
    context.go("/${notification.pathToTask}");
  }
}
