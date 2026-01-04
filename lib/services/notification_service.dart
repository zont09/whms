import 'package:flutter/material.dart';
import 'package:whms/models/notification_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/repositories/notification_repository.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/untils/task_path_builder.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static NotificationService instance = NotificationService._privateConstructor();

  final NotificationRepository _repository = NotificationRepository.instance;
  final TaskPathBuilder _pathBuilder = TaskPathBuilder();

  // ========= CREATE NOTIFICATIONS =========

  /// Tạo thông báo khi người làm cập nhật trạng thái task lúc check-out
  Future<void> notifyTaskStatusUpdate({
    required WorkingUnitModel task,
    required String updaterId, // ID người cập nhật
    required int oldStatus,
    required int newStatus,
    required StatusCheckInDefine checkInStatus,
    required String path,
  }) async {
    try {
      // Chỉ gửi thông báo nếu đang check-out
      if (checkInStatus != StatusCheckInDefine.checkOut) {
        return;
      }

      // Không gửi thông báo nếu người cập nhật là owner
      if (updaterId == task.owner || task.owner.isEmpty) {
        return;
      }

      // Lấy đường dẫn từ root đến task
      final pathToTask = await _buildPathToTask(task);

      final notification = NotificationModel(
        userId: task.owner, // Gửi cho owner
        senderId: updaterId,
        taskId: task.id,
        taskTitle: task.title,
        type: NotificationType.taskStatusUpdate,
        message: _buildStatusUpdateMessage(task.title, oldStatus, newStatus),
        pathToTask: path,
        metadata: {
          'old_status': oldStatus,
          'new_status': newStatus,
          'task_type': task.type,
        },
      );

      await _repository.createNotification(notification);
      debugPrint("=========> Created status update notification for owner: ${task.owner}");
    } catch (e) {
      debugPrint("Error creating status update notification: $e");
    }
  }

  /// Tạo thông báo khi owner gắn task cho người
  Future<void> notifyTaskAssigned({
    required WorkingUnitModel task,
    required String ownerId,
    required List<String> newAssignees,
    required String path,
  }) async {
    try {
      if (newAssignees.isEmpty) {
        return;
      }

      // Lấy đường dẫn từ root đến task
      final pathToTask = path;

      // Tạo thông báo cho từng người được gắn
      final notifications = <NotificationModel>[];
      
      for (final assigneeId in newAssignees) {
        // Không gửi thông báo cho chính owner
        if (assigneeId == ownerId) {
          continue;
        }

        notifications.add(NotificationModel(
          userId: assigneeId,
          senderId: ownerId,
          taskId: task.id,
          taskTitle: task.title,
          type: NotificationType.taskAssigned,
          message: _buildAssignedMessage(task.title, task.type),
          pathToTask: path,
          metadata: {
            'task_type': task.type,
            'deadline': task.deadline.toDate().toString(),
          },
        ));
      }

      if (notifications.isNotEmpty) {
        await _repository.createMultipleNotifications(notifications);
        debugPrint("=========> Created ${notifications.length} task assigned notifications");
      }
    } catch (e) {
      debugPrint("Error creating task assigned notifications: $e");
    }
  }

  /// Tạo thông báo khi owner gỡ task khỏi người
  Future<void> notifyTaskUnassigned({
    required WorkingUnitModel task,
    required String ownerId,
    required List<String> removedAssignees,
    required String path,
  }) async {
    try {
      if (removedAssignees.isEmpty) {
        return;
      }

      // Lấy đường dẫn từ root đến task
      final pathToTask = await _buildPathToTask(task);

      // Tạo thông báo cho từng người bị gỡ
      final notifications = <NotificationModel>[];
      
      for (final assigneeId in removedAssignees) {
        // Không gửi thông báo cho chính owner
        if (assigneeId == ownerId) {
          continue;
        }

        notifications.add(NotificationModel(
          userId: assigneeId,
          senderId: ownerId,
          taskId: task.id,
          taskTitle: task.title,
          type: NotificationType.taskUnassigned,
          message: _buildUnassignedMessage(task.title, task.type),
          pathToTask: path,
          metadata: {
            'task_type': task.type,
          },
        ));
      }

      if (notifications.isNotEmpty) {
        await _repository.createMultipleNotifications(notifications);
        debugPrint("=========> Created ${notifications.length} task unassigned notifications");
      }
    } catch (e) {
      debugPrint("Error creating task unassigned notifications: $e");
    }
  }

  // ========= HELPER METHODS =========

  /// Xây dựng đường dẫn từ root đến task
  Future<List<String>> _buildPathToTask(WorkingUnitModel task) async {
    return await _pathBuilder.buildPathToTask(task);
  }

  /// Tạo message cho status update
  String _buildStatusUpdateMessage(String taskTitle, int oldStatus, int newStatus) {
    return 'Trạng thái của task "$taskTitle" đã được cập nhật';
  }

  /// Tạo message cho task assigned
  String _buildAssignedMessage(String taskTitle, String taskType) {
    return 'Bạn đã được gắn vào $taskType "$taskTitle"';
  }

  /// Tạo message cho task unassigned
  String _buildUnassignedMessage(String taskTitle, String taskType) {
    return 'Bạn đã được gỡ khỏi $taskType "$taskTitle"';
  }

  // ========= READ NOTIFICATIONS =========

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final result = await _repository.getNotificationsByUserId(userId);
      return result.docs.map((e) => NotificationModel.fromSnapshot(e)).toList();
    } catch (e) {
      debugPrint("Error getting notifications: $e");
      return [];
    }
  }

  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    try {
      final result = await _repository.getUnreadNotifications(userId);
      return result.docs.map((e) => NotificationModel.fromSnapshot(e)).toList();
    } catch (e) {
      debugPrint("Error getting unread notifications: $e");
      return [];
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      return await _repository.countUnreadNotifications(userId);
    } catch (e) {
      debugPrint("Error getting unread count: $e");
      return 0;
    }
  }

  // ========= UPDATE NOTIFICATIONS =========

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _repository.markAllAsRead(userId);
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
    }
  }

  // ========= DELETE NOTIFICATIONS =========

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
    } catch (e) {
      debugPrint("Error deleting notification: $e");
    }
  }

  Future<void> deleteAllNotifications(String userId) async {
    try {
      await _repository.deleteAllNotifications(userId);
    } catch (e) {
      debugPrint("Error deleting all notifications: $e");
    }
  }

  // ========= STREAMS =========

  Stream<List<NotificationModel>> notificationsStream(String userId) {
    return _repository.notificationsStream(userId).map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromSnapshot(doc))
              .toList(),
        );
  }

  Stream<int> unreadCountStream(String userId) {
    return _repository.unreadCountStream(userId);
  }
}
