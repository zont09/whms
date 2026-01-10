import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';

class WorkingUnitModel {
  String id;
  String type;
  String parent;
  String title;
  String description;
  String priority;
  Timestamp start;
  Timestamp deadline;
  List<String> attachments;
  int status;
  List<String> assignees;
  List<String> assigneesPending;
  List<String> followers;
  List<String> handlers;
  List<String> scopes;
  List<String> okrs;
  String owner;
  Timestamp urgent;
  int workingPoint;
  List<String> documents;
  List<String> objectsInOkrs;
  List<String> resultsInOkrs;
  List<String> sharings;
  List<String> announces;
  String periodic;
  int periodicValue;
  int duration;
  String icon;
  String result;
  bool enable;
  bool closed;
  bool isOpen = false;
  Timestamp createAt;
  Timestamp lastWorkedAt;

  // New fields for product handover
  String? handoverDescription;
  List<String> handoverFiles;

  List<WorkingUnitModel> children = [];
  WorkingUnitModel? family;
  int level = 0;
  String position = '000000000';
  double percent = -1;

  List<UserModel> members = [];

  // Constructor with default values
  WorkingUnitModel({
    this.id = "",
    this.type = "",
    this.parent = "",
    this.title = "",
    this.description = "",
    this.priority = "",
    Timestamp? start,
    Timestamp? deadline,
    this.attachments = const [],
    this.status = 0,
    this.assignees = const [],
    this.followers = const [],
    this.handlers = const [],
    this.assigneesPending = const [],
    this.scopes = const [],
    this.okrs = const [],
    this.owner = "",
    Timestamp? urgent,
    this.workingPoint = 0,
    this.documents = const [],
    this.objectsInOkrs = const [],
    this.resultsInOkrs = const [],
    this.sharings = const [],
    this.announces = const [],
    this.periodic = "",
    this.periodicValue = 0,
    this.icon = "",
    this.result = "",
    this.duration = 0,
    this.enable = true,
    this.closed = false,
    Timestamp? createAt,
    Timestamp? lastWorkedAt,
    this.handoverDescription,
    this.handoverFiles = const [],
  })  : start = start ?? Timestamp.now(),
        deadline = deadline ?? Timestamp.now(),
        urgent = urgent ?? Timestamp.now(),
        createAt = createAt ?? Timestamp.now(),
        lastWorkedAt = lastWorkedAt ?? Timestamp(0, 0);

  String get iconType {
    if (type == TypeAssignmentDefine.epic.title) {
      return 'assets/images/icons/ic_epic.png';
    }
    if (type == TypeAssignmentDefine.sprint.title) {
      return 'assets/images/icons/ic_sprint.png';
    }
    if (type == TypeAssignmentDefine.okrs.title) {
      return 'assets/images/icons/ic_okr.png';
    }
    return 'assets/images/icons/ic_story.png';
  }

  String get iconParent {
    if (type == TypeAssignmentDefine.epic.title) {
      return 'assets/images/icons/ic_fill_epic.png';
    }
    if (type == TypeAssignmentDefine.sprint.title) {
      return 'assets/images/icons/ic_fill_sprint.png';
    }
    if (type == TypeAssignmentDefine.okrs.title) {
      return 'assets/images/icons/ic_fill_okrs.png';
    }
    if (type == TypeAssignmentDefine.story.title) {
      return 'assets/images/icons/ic_fill_group.png';
    }
    return 'assets/images/icons/ic_fill_task.png';
  }

  double get sizeIconParent {
    if (type == TypeAssignmentDefine.epic.title ||
        type == TypeAssignmentDefine.okrs.title ||
        type == TypeAssignmentDefine.sprint.title) {
      return 28;
    }
    if (type == TypeAssignmentDefine.story.title) {
      return 24;
    }
    return 20;
  }

  Color get background {
    if (type == AppText.txtEpic.text) {
      return Colors.cyan;
    }
    if (type == AppText.txtSprint.text) {
      return Colors.orange;
    }
    if (type == AppText.txtTask.text) {
      return Colors.purple;
    }
    return Colors.lightGreen;
  }

  int get index => family?.children.indexOf(this) ?? -1;

  bool get isLeaf => children.isEmpty;

  void insertChild(int index, WorkingUnitModel node) {
    if (node.family == this && node.index < index) {
      index--;
    }

    node
      ..family?.children.remove(node)
      ..family = this;

    children.insert(index, node);
  }

  String get typeString {
    String tmp = type;
    if (type == AppText.txtStory.text) {
      tmp = 'Nhóm';
    }
    return tmp;
  }

  String get deadlineString {
    String tmp1 = DateTimeUtils.convertTimestampToDateString(deadline)
        .replaceAll('/', '.');
    String tmp2 = tmp1.split('.').sublist(0, 2).join('.');
    if (DateTimeUtils.convertToDateTime(
        DateTimeUtils.convertTimestampToDateString(deadline))
        .year ==
        DateTime.now().year) {
      return tmp2;
    } else {
      return tmp1;
    }
  }

  List<String> get tabs {
    if (type == TypeAssignmentDefine.epic.title ||
        type == TypeAssignmentDefine.okrs.title) {
      return [
        AppText.txtSprint.text,
        AppText.txtStory.text,
        AppText.txtTask.text
      ];
    }
    if (type == TypeAssignmentDefine.sprint.title) {
      return [AppText.txtStory.text, AppText.txtTask.text];
    }
    if (type == TypeAssignmentDefine.story.title) {
      return [AppText.txtTask.text];
    }
    return [];
  }

  bool get isFinished {
    return (status == StatusWorkingDefine.done.value ||
        status == StatusWorkingDefine.completed.value ||
        status == StatusWorkingDefine.failed.value ||
        status == StatusWorkingDefine.cancelled.value);
  }

  bool get isDoing {
    return StatusWorkingExtension.fromValue(status).isDynamic ||
        status == StatusWorkingDefine.none.value;
  }

  bool get isDone {
    return status == StatusWorkingDefine.done.value;
  }

  bool get isInThisWeek {
    final start = DateTimeUtils.getStartOfThisWeek(DateTime.now());
    final end = start.add(Duration(days: 6));
    return lastWorkedAt.toDate().isAfter(start) && lastWorkedAt.toDate().isBefore(end);
  }

  bool get isInLastWeek {
    final start = DateTimeUtils.getStartOfThisWeek(DateTime.now().subtract(Duration(days: 7)));
    final end = start.add(Duration(days: 6));
    return lastWorkedAt.toDate().isAfter(start) && lastWorkedAt.toDate().isBefore(end);
  }

  // Factory method to create a WorkingUnitModel from JSON
  factory WorkingUnitModel.fromJson(Map<String, dynamic> json) =>
      WorkingUnitModel(
        id: json['id'] != null ? json['id'].toString() : "",
        type: json['type'] ?? "",
        parent: json['parent'] ?? "",
        title: json['title'] ?? "",
        description: json['description'] ?? "",
        priority: json['priority'] ?? "",
        start: json['start'] != null
            ? (json['start'] as Timestamp)
            : Timestamp.now(),
        deadline: json['deadline'] != null
            ? (json['deadline'] as Timestamp)
            : Timestamp.now(),
        attachments: json['attachments'] != null
            ? List<String>.from(json['attachments'])
            : [],
        status: json['status'] != null ? int.parse(json['status'].toString()) : 0,
        assignees: json['assignees'] != null
            ? List<String>.from(json['assignees'])
            : [],
        assigneesPending: json['assignees_pending'] != null
            ? List<String>.from(json['assignees_pending'])
            : [],
        followers: json['followers'] != null
            ? List<String>.from(json['followers'])
            : [],
        handlers:
        json['handlers'] != null ? List<String>.from(json['handlers']) : [],
        scopes: json['scope'] != null ? List<String>.from(json['scope']) : [],
        okrs: json['okr'] != null ? List<String>.from(json['okr']) : [],
        owner: json['owner'] ?? "",
        urgent: json['urgent'] != null
            ? (json['urgent'] as Timestamp)
            : Timestamp.now(),
        workingPoint: json['working_point'] != null
            ? int.parse(json['working_point'].toString())
            : 0,
        documents: json['documents'] != null
            ? List<String>.from(json['documents'])
            : [],
        objectsInOkrs: json['objects_in_okrs'] != null
            ? List<String>.from(json['objects_in_okrs'])
            : [],
        resultsInOkrs: json['results_int_okrs'] != null
            ? List<String>.from(json['results_int_okrs'])
            : [],
        sharings:
        json['sharings'] != null ? List<String>.from(json['sharings']) : [],
        announces: json['announces'] != null
            ? List<String>.from(json['announces'])
            : [],
        periodic: json['periodic'] ?? "",
        periodicValue: json['periodic_value'] != null
            ? int.parse(json['periodic_value'].toString())
            : 0,
        result: json['result'] ?? "",
        icon: json['icon'] ?? "",
        duration: json['duration'] != null
            ? int.parse(json['duration'].toString())
            : 0,
        enable: json['enable'] != null
            ? bool.parse(json['enable'].toString())
            : true,
        closed: json['closed'] != null
            ? bool.parse(json['closed'].toString())
            : false,
        createAt: json['createAt'] != null
            ? (json['createAt'] as Timestamp)
            : Timestamp.now(),
        lastWorkedAt: json['lastWorkedAt'] != null
            ? (json['lastWorkedAt'] as Timestamp)
            : Timestamp.now(),
        handoverDescription: json['handover_description'],
        handoverFiles: json['handover_files'] != null
            ? List<String>.from(json['handover_files'])
            : [],
      );

  // Factory method to create a WorkingUnitModel from Firestore snapshot
  factory WorkingUnitModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return WorkingUnitModel.fromJson(data);
  }

  // Copy method to create a modified instance
  WorkingUnitModel copyWith({
    String? id,
    String? type,
    String? parent,
    String? title,
    String? description,
    String? priority,
    Timestamp? start,
    Timestamp? deadline,
    List<String>? attachments,
    int? status,
    List<String>? assignees,
    List<String>? assigneesPending,
    List<String>? followers,
    List<String>? handlers,
    List<String>? scope,
    List<String>? okr,
    String? owner,
    Timestamp? urgent,
    int? workingPoint,
    List<String>? documents,
    List<String>? objectsInOkrs,
    List<String>? resultsInOkrs,
    List<String>? sharings,
    List<String>? announces,
    String? periodic,
    String? result,
    String? icon,
    int? periodicValue,
    int? duration,
    bool? enable,
    bool? closed,
    Timestamp? createAt,
    Timestamp? lastWorkedAt,
    String? handoverDescription,
    List<String>? handoverFiles,
  }) {
    return WorkingUnitModel(
        id: id ?? this.id,
        type: type ?? this.type,
        parent: parent ?? this.parent,
        title: title ?? this.title,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        start: start ?? this.start,
        deadline: deadline ?? this.deadline,
        attachments: attachments ?? this.attachments,
        status: status ?? this.status,
        assignees: assignees ?? this.assignees,
        followers: followers ?? this.followers,
        handlers: handlers ?? this.handlers,
        assigneesPending: assigneesPending ?? this.assigneesPending,
        scopes: scope ?? scopes,
        okrs: okr ?? okrs,
        owner: owner ?? this.owner,
        urgent: urgent ?? this.urgent,
        workingPoint: workingPoint ?? this.workingPoint,
        documents: documents ?? this.documents,
        objectsInOkrs: objectsInOkrs ?? this.objectsInOkrs,
        resultsInOkrs: resultsInOkrs ?? this.resultsInOkrs,
        sharings: sharings ?? this.sharings,
        announces: announces ?? this.announces,
        periodic: periodic ?? this.periodic,
        icon: icon ?? this.icon,
        result: result ?? this.result,
        periodicValue: periodicValue ?? this.periodicValue,
        duration: duration ?? this.duration,
        enable: enable ?? this.enable,
        closed: closed ?? this.closed,
        createAt: createAt ?? this.createAt,
        lastWorkedAt: lastWorkedAt ?? this.lastWorkedAt,
        handoverDescription: handoverDescription ?? this.handoverDescription,
        handoverFiles: handoverFiles ?? this.handoverFiles);
  }

  // Convert WorkingUnitModel to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'parent': parent,
    'title': title,
    'description': description,
    'priority': priority,
    'start': start,
    'deadline': deadline,
    'attachments': attachments,
    'status': status,
    'assignees': assignees,
    'followers': followers,
    'handlers': handlers,
    'assignees_pending': assigneesPending,
    'scope': scopes,
    'okr': okrs,
    'owner': owner,
    'urgent': urgent,
    'working_point': workingPoint,
    'documents': documents,
    'objects_in_okrs': objectsInOkrs,
    'results_int_okrs': resultsInOkrs,
    'sharings': sharings,
    'announces': announces,
    'periodic': periodic,
    'periodic_value': periodicValue,
    'duration': duration,
    'enable': enable,
    'result': result,
    'icon': icon,
    'closed': closed,
    'createAt': createAt,
    'lastWorkedAt': lastWorkedAt,
    'handover_description': handoverDescription,
    'handover_files': handoverFiles,
  };

  static Map<String, dynamic> getDifferentFields(
      WorkingUnitModel obj1, WorkingUnitModel obj2) {
    final differences = <String, dynamic>{};

    // So sánh từng field
    if (obj1.id != obj2.id) differences['id'] = obj2.id;
    if (obj1.type != obj2.type) differences['type'] = obj2.type;
    if (obj1.parent != obj2.parent) differences['parent'] = obj2.parent;
    if (obj1.title != obj2.title) differences['title'] = obj2.title;
    if (obj1.description != obj2.description)
      differences['description'] = obj2.description;
    if (obj1.priority != obj2.priority) differences['priority'] = obj2.priority;
    if (obj1.start != obj2.start) differences['start'] = obj2.start;
    if (obj1.deadline != obj2.deadline) differences['deadline'] = obj2.deadline;
    if (!listEquals(obj1.attachments, obj2.attachments))
      differences['attachments'] = obj2.attachments;
    if (obj1.status != obj2.status) differences['status'] = obj2.status;
    if (!listEquals(obj1.assignees, obj2.assignees))
      differences['assignees'] = obj2.assignees;
    if (!listEquals(obj1.assigneesPending, obj2.assigneesPending))
      differences['assignees_pending'] = obj2.assigneesPending;
    if (!listEquals(obj1.followers, obj2.followers))
      differences['followers'] = obj2.followers;
    if (!listEquals(obj1.handlers, obj2.handlers))
      differences['handlers'] = obj2.handlers;
    if (!listEquals(obj1.scopes, obj2.scopes))
      differences['scope'] = obj2.scopes;
    if (!listEquals(obj1.okrs, obj2.okrs)) differences['okr'] = obj2.okrs;
    if (obj1.owner != obj2.owner) differences['owner'] = obj2.owner;
    if (obj1.urgent != obj2.urgent) differences['urgent'] = obj2.urgent;
    if (obj1.workingPoint != obj2.workingPoint)
      differences['working_point'] = obj2.workingPoint;
    if (!listEquals(obj1.documents, obj2.documents))
      differences['documents'] = obj2.documents;
    if (!listEquals(obj1.objectsInOkrs, obj2.objectsInOkrs))
      differences['objects_in_okrs'] = obj2.objectsInOkrs;
    if (!listEquals(obj1.resultsInOkrs, obj2.resultsInOkrs))
      differences['results_int_okrs'] = obj2.resultsInOkrs;
    if (!listEquals(obj1.sharings, obj2.sharings))
      differences['sharings'] = obj2.sharings;
    if (!listEquals(obj1.announces, obj2.announces))
      differences['announces'] = obj2.announces;
    if (obj1.periodic != obj2.periodic) differences['periodic'] = obj2.periodic;
    if (obj1.periodicValue != obj2.periodicValue)
      differences['periodic_value'] = obj2.periodicValue;
    if (obj1.duration != obj2.duration) differences['duration'] = obj2.duration;
    if (obj1.icon != obj2.icon) differences['icon'] = obj2.icon;
    if (obj1.result != obj2.result) differences['result'] = obj2.result;
    if (obj1.enable != obj2.enable) differences['enable'] = obj2.enable;
    if (obj1.closed != obj2.closed) differences['closed'] = obj2.closed;
    if (obj1.isOpen != obj2.isOpen) differences['isOpen'] = obj2.isOpen;
    if (obj1.createAt != obj2.createAt) differences['createAt'] = obj2.createAt;
    if (obj1.lastWorkedAt != obj2.lastWorkedAt) differences['lastWorkedAt'] = obj2.lastWorkedAt;
    if (obj1.handoverDescription != obj2.handoverDescription)
      differences['handover_description'] = obj2.handoverDescription;
    if (!listEquals(obj1.handoverFiles, obj2.handoverFiles))
      differences['handover_files'] = obj2.handoverFiles;

    return differences;
  }

// Hàm phụ để so sánh hai List (vì Dart không so sánh List trực tiếp)
  static bool listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return "$id - $title - $deadline - $workingPoint - $status";
  }
}