import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whms/models/notification_model.dart';

class NotificationRepository {
  NotificationRepository._privateConstructor();
  static NotificationRepository instance = NotificationRepository._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'notifications';

  // Lấy collection reference
  CollectionReference<Map<String, dynamic>> get _notificationsRef =>
      _firestore.collection(_collectionName);

  // Tạo thông báo mới
  Future<void> createNotification(NotificationModel notification) async {
    try {
      // Nếu chưa có ID, tạo ID mới
      if (notification.id.isEmpty) {
        final docRef = _notificationsRef.doc();
        notification = notification.copyWith(id: docRef.id);
      }

      await _notificationsRef.doc(notification.id).set(notification.toJson());
    } catch (e) {
      print('Error creating notification: $e');
      rethrow;
    }
  }

  // Tạo nhiều thông báo cùng lúc (batch)
  Future<void> createMultipleNotifications(
      List<NotificationModel> notifications) async {
    try {
      final batch = _firestore.batch();

      for (var notification in notifications) {
        if (notification.id.isEmpty) {
          final docRef = _notificationsRef.doc();
          notification = notification.copyWith(id: docRef.id);
        }
        batch.set(_notificationsRef.doc(notification.id), notification.toJson());
      }

      await batch.commit();
    } catch (e) {
      print('Error creating multiple notifications: $e');
      rethrow;
    }
  }

  // Lấy tất cả thông báo của user (chưa đọc trước)
  Future<QuerySnapshot<Map<String, dynamic>>> getNotificationsByUserId(
      String userId,
      {int limit = 50}) async {
    try {
      return await _notificationsRef
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .orderBy('is_read', descending: false)
          .limit(limit)
          .get();
    } catch (e) {
      print('Error getting notifications: $e');
      rethrow;
    }
  }

  // Lấy thông báo chưa đọc của user
  Future<QuerySnapshot<Map<String, dynamic>>> getUnreadNotifications(
      String userId) async {
    try {
      return await _notificationsRef
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .orderBy('created_at', descending: true)
          .get();
    } catch (e) {
      print('Error getting unread notifications: $e');
      rethrow;
    }
  }

  // Đếm số thông báo chưa đọc
  Future<int> countUnreadNotifications(String userId) async {
    try {
      final snapshot = await _notificationsRef
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error counting unread notifications: $e');
      return 0;
    }
  }

  // Đánh dấu đã đọc
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).update({'is_read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _notificationsRef
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'is_read': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsRef.doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Xóa tất cả thông báo của user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final snapshot = await _notificationsRef
          .where('user_id', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting all notifications: $e');
      rethrow;
    }
  }

  // Stream để lắng nghe thông báo real-time
  Stream<QuerySnapshot<Map<String, dynamic>>> notificationsStream(
      String userId) {
    return _notificationsRef
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots();
  }

  // Stream để lắng nghe số lượng thông báo chưa đọc
  Stream<int> unreadCountStream(String userId) {
    return _notificationsRef
        .where('user_id', isEqualTo: userId)
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Lấy thông báo theo task ID
  Future<QuerySnapshot<Map<String, dynamic>>> getNotificationsByTaskId(
      String taskId) async {
    try {
      return await _notificationsRef
          .where('task_id', isEqualTo: taskId)
          .orderBy('created_at', descending: true)
          .get();
    } catch (e) {
      print('Error getting notifications by task ID: $e');
      rethrow;
    }
  }

  // Xóa thông báo cũ (ví dụ: > 30 ngày)
  Future<void> deleteOldNotifications(String userId, int daysOld) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final snapshot = await _notificationsRef
          .where('user_id', isEqualTo: userId)
          .where('created_at', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error deleting old notifications: $e');
      rethrow;
    }
  }
}
