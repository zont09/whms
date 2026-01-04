import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  taskStatusUpdate, // Người làm cập nhật trạng thái task
  taskAssigned, // Owner gắn task cho người
  taskUnassigned, // Owner gỡ task khỏi người
}

class NotificationModel {
  String id;
  String userId; // ID người nhận thông báo
  String senderId; // ID người gửi (người thực hiện hành động)
  String taskId; // ID của task liên quan
  String taskTitle; // Tiêu đề task để hiển thị
  NotificationType type; // Loại thông báo
  String message; // Nội dung thông báo
  String pathToTask; // Đường dẫn từ root đến task [projectId, epicId, storyId, taskId]
  bool isRead; // Đã đọc chưa
  Timestamp createdAt; // Thời gian tạo thông báo
  Map<String, dynamic>? metadata; // Thông tin thêm (status cũ/mới, etc.)

  NotificationModel({
    this.id = "",
    required this.userId,
    required this.senderId,
    required this.taskId,
    required this.taskTitle,
    required this.type,
    required this.message,
    this.pathToTask = '',
    this.isRead = false,
    Timestamp? createdAt,
    this.metadata,
  }) : createdAt = createdAt ?? Timestamp.now();

  // Factory từ JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? "",
      userId: json['user_id'] ?? "",
      senderId: json['sender_id'] ?? "",
      taskId: json['task_id'] ?? "",
      taskTitle: json['task_title'] ?? "",
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.taskStatusUpdate,
      ),
      message: json['message'] ?? "",
      pathToTask: json['path_to_task'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp)
          : Timestamp.now(),
      metadata: json['metadata'],
    );
  }

  // Factory từ Firestore snapshot
  factory NotificationModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return NotificationModel.fromJson(data);
  }

  // Convert sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sender_id': senderId,
      'task_id': taskId,
      'task_title': taskTitle,
      'type': type.toString(),
      'message': message,
      'path_to_task': pathToTask,
      'is_read': isRead,
      'created_at': createdAt,
      'metadata': metadata,
    };
  }

  // Copy with
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? senderId,
    String? taskId,
    String? taskTitle,
    NotificationType? type,
    String? message,
    String? pathToTask,
    bool? isRead,
    Timestamp? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      senderId: senderId ?? this.senderId,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      type: type ?? this.type,
      message: message ?? this.message,
      pathToTask: pathToTask ?? this.pathToTask,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper method để lấy icon theo type
  String get iconPath {
    switch (type) {
      case NotificationType.taskStatusUpdate:
        return 'assets/images/icons/ic_status_update.png';
      case NotificationType.taskAssigned:
        return 'assets/images/icons/ic_task_assigned.png';
      case NotificationType.taskUnassigned:
        return 'assets/images/icons/ic_task_unassigned.png';
    }
  }

  // Helper method để lấy màu theo type
  int get colorCode {
    switch (type) {
      case NotificationType.taskStatusUpdate:
        return 0xFF2196F3; // Blue
      case NotificationType.taskAssigned:
        return 0xFF4CAF50; // Green
      case NotificationType.taskUnassigned:
        return 0xFFFF9800; // Orange
    }
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, taskId: $taskId, type: $type, isRead: $isRead)';
  }
}
