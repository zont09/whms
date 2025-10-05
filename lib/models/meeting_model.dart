import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingModel {
  final String id;
  final String title;
  final String description;
  final List<String> members;
  final List<String> sections;
  final List<String> minutes;
  final List<String> documents;
  final List<String> preparation;
  final String owner;
  final List<String> scopes;
  final DateTime time;
  final DateTime reminderTime;
  final String status;
  final bool enable;

  MeetingModel({
    this.id = "",
    this.title = "",
    this.description = "",
    this.members = const [],
    this.sections = const [],
    this.minutes = const [],
    this.documents = const [],
    this.preparation = const [],
    this.owner = "",
    this.scopes = const [],
    DateTime? time,
    DateTime? reminderTime,
    this.status = "",
    this.enable = true,
  })  : time = time ?? DateTime.now(),
        reminderTime = reminderTime ?? DateTime.now();

  factory MeetingModel.fromJson(Map<String, dynamic> json) => MeetingModel(
    id: json['id'] ?? "",
    title: json['title'] ?? "",
    description: json['description'] ?? "",
    members: json['members'] != null ? List<String>.from(json['members']) : [],
    sections: json['sections'] != null ? List<String>.from(json['sections']) : [],
    minutes: json['minutes'] != null ? List<String>.from(json['minutes']) : [],
    documents: json['documents'] != null ? List<String>.from(json['documents']) : [],
    preparation: json['preparation'] != null ? List<String>.from(json['preparation']) : [],
    owner: json['owner'] ?? "",
    scopes: json['scopes'] != null ? List<String>.from(json['scopes']) : [],
    time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
    reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : DateTime.now(),
    status: json['status'] ?? "",
    enable: json['enable'] ?? true,
  );

  factory MeetingModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return MeetingModel(
      id: data['id'] ?? "",
      title: data['title'] ?? "",
      description: data['description'] ?? "",
      members: data['members'] != null ? List<String>.from(data['members']) : [],
      sections: data['sections'] != null ? List<String>.from(data['sections']) : [],
      minutes: data['minutes'] != null ? List<String>.from(data['minutes']) : [],
      documents: data['documents'] != null ? List<String>.from(data['documents']) : [],
      preparation: data['preparation'] != null ? List<String>.from(data['preparation']) : [],
      owner: data['owner'] ?? "",
      scopes: data['scopes'] != null ? List<String>.from(data['scopes']) : [],
      time: data['time'] != null ? (data['time'] as Timestamp).toDate() : DateTime.now(),
      reminderTime: data['reminderTime'] != null ? (data['reminderTime'] as Timestamp).toDate() : DateTime.now(),
      status: data['status'] ?? "",
      enable: data['enable'] ?? true,
    );
  }

  Map<String, dynamic> toSnapshot() => {
    'id': id,
    'title': title,
    'description': description,
    'members': members,
    'sections': sections,
    'minutes': minutes,
    'documents': documents,
    'preparation': preparation,
    'owner': owner,
    'scopes': scopes,
    'time': Timestamp.fromDate(time),
    'reminderTime': Timestamp.fromDate(reminderTime),
    'status': status,
    'enable': enable,
  };

  MeetingModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? members,
    List<String>? sections,
    List<String>? minutes,
    List<String>? documents,
    List<String>? preparation,
    String? owner,
    List<String>? scopes,
    DateTime? time,
    DateTime? reminderTime,
    String? status,
    bool? enable,
  }) {
    return MeetingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      members: members ?? this.members,
      sections: sections ?? this.sections,
      minutes: minutes ?? this.minutes,
      documents: documents ?? this.documents,
      preparation: preparation ?? this.preparation,
      owner: owner ?? this.owner,
      scopes: scopes ?? this.scopes,
      time: time ?? this.time,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
      enable: enable ?? this.enable,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'members': members,
    'sections': sections,
    'minutes': minutes,
    'documents': documents,
    'preparation': preparation,
    'owner': owner,
    'scopes': scopes,
    'time': Timestamp.fromDate(time),
    'reminderTime': Timestamp.fromDate(reminderTime),
    'status': status,
    'enable': enable,
  };

  static Map<String, dynamic> getDifferentFields(MeetingModel obj2, MeetingModel obj1) {
    final differences = <String, dynamic>{};

    if (obj1.title != obj2.title) differences['title'] = obj2.title;
    if (obj1.description != obj2.description) differences['description'] = obj2.description;
    if (!listEquals(obj1.members, obj2.members)) differences['members'] = obj2.members;
    if (!listEquals(obj1.sections, obj2.sections)) differences['sections'] = obj2.sections;
    if (!listEquals(obj1.minutes, obj2.minutes)) differences['minutes'] = obj2.minutes;
    if (!listEquals(obj1.documents, obj2.documents)) differences['documents'] = obj2.documents;
    if (!listEquals(obj1.preparation, obj2.preparation)) differences['preparation'] = obj2.preparation;
    if (obj1.owner != obj2.owner) differences['owner'] = obj2.owner;
    if (!listEquals(obj1.scopes, obj2.scopes)) differences['scopes'] = obj2.scopes;
    if (obj1.time != obj2.time) differences['time'] = obj2.time;
    if (obj1.reminderTime != obj2.reminderTime) differences['reminderTime'] = obj2.reminderTime;
    if (obj1.status != obj2.status) differences['status'] = obj2.status;
    if (obj1.enable != obj2.enable) differences['enable'] = obj2.enable;

    return differences;
  }

  static bool listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MeetingModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
