import 'package:cloud_firestore/cloud_firestore.dart';

class WorkFieldModel {
  final String id;
  final String taskId;
  final int fromStatus;
  final int toStatus;
  final int duration;
  final DateTime date;
  final String workShift;
  final bool enable;

  // Constructor with default values
  WorkFieldModel({
    this.id = "",
    this.taskId = "",
    this.fromStatus = -1,
    this.toStatus = -1,
    this.duration = 0,
    DateTime? date,
    this.workShift = "",
    this.enable = true,
  }) : date = date ?? DateTime.now();

  // Factory method to create a WorkFieldModel from JSON
  factory WorkFieldModel.fromJson(Map<String, dynamic> json) => WorkFieldModel(
        id: json['id'] != null ? json['id'].toString() : "",
        taskId: json['task_id'] != null ? json['task_id'].toString() : "",
        fromStatus: json['from_status'] != null
            ? int.parse(json['from_status'].toString())
            : -1,
        toStatus: json['to_status'] != null
            ? int.parse(json['to_status'].toString())
            : -1,
        duration: json['duration'] != null
            ? int.parse(json['duration'].toString())
            : 0,
        date: json['date'] != null
            ? DateTime.parse(json['date'])
            : DateTime.now(),
        workShift: json['work_shift'] ?? "",
        enable: json['enable'] != null
            ? bool.parse(json['enable'].toString())
            : true,
      );

  // Factory method to create a WorkFieldModel from Firestore snapshot
  factory WorkFieldModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return WorkFieldModel(
      id: data['id'] != null ? data['id'].toString() : "",
      taskId: data['task_id'] != null ? data['task_id'].toString() : "",
      fromStatus: data['from_status'] != null
          ? int.parse(data['from_status'].toString())
          : -1,
      toStatus: data['to_status'] != null
          ? int.parse(data['to_status'].toString())
          : -1,
      duration:
          data['duration'] != null ? int.parse(data['duration'].toString()) : 0,
      date:
          data['date'] != null ? DateTime.parse(data['date']) : DateTime.now(),
      workShift: data['work_shift'] ?? "",
      enable:
          data['enable'] != null ? bool.parse(data['enable'].toString()) : true,
    );
  }

  // Copy method to create a modified instance
  WorkFieldModel copyWith({
    String? id,
    String? taskId,
    int? fromStatus,
    int? toStatus,
    int? duration,
    DateTime? date,
    String? workShift,
    bool? enable,
  }) {
    return WorkFieldModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fromStatus: fromStatus ?? this.fromStatus,
      toStatus: toStatus ?? this.toStatus,
      duration: duration ?? this.duration,
      date: date ?? this.date,
      workShift: workShift ?? this.workShift,
      enable: enable ?? this.enable,
    );
  }

  // Convert WorkFieldModel to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'task_id': taskId,
        'from_status': fromStatus,
        'to_status': toStatus,
        'duration': duration,
        'date': date.toIso8601String(),
        'work_shift': workShift,
        'enable': enable,
      };

  static Map<String, dynamic> getDifferentFields(WorkFieldModel obj1, WorkFieldModel obj2) {
    final differences = <String, dynamic>{};

    if (obj1.id != obj2.id) differences['id'] = obj2.id;
    if (obj1.taskId != obj2.taskId) differences['task_id'] = obj2.taskId;
    if (obj1.fromStatus != obj2.fromStatus) differences['from_status'] = obj2.fromStatus;
    if (obj1.toStatus != obj2.toStatus) differences['to_status'] = obj2.toStatus;
    if (obj1.duration != obj2.duration) differences['duration'] = obj2.duration;
    if (obj1.date != obj2.date) differences['date'] = obj2.date;
    if (obj1.workShift != obj2.workShift) differences['work_shift'] = obj2.workShift;
    if (obj1.enable != obj2.enable) differences['enable'] = obj2.enable;

    return differences;
  }
}
