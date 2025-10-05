import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingSectionModel {
  final String id;
  final String title;
  final String description;
  final List<String> checklist;
  final int durations;
  final List<String> attachments;
  final bool enable;
  final Timestamp createAt;
  final Timestamp updateAt;

  MeetingSectionModel({
    this.id = "",
    this.title = "",
    this.description = "",
    this.checklist = const [],
    this.durations = 0,
    this.attachments = const [],
    this.enable = true,
    Timestamp? createAt,
    Timestamp? updateAt,
  })  : createAt = createAt ?? Timestamp.now(),
        updateAt = updateAt ?? Timestamp.now();

  factory MeetingSectionModel.fromJson(Map<String, dynamic> json) => MeetingSectionModel(
    id: json['id'] ?? "",
    title: json['title'] ?? "",
    description: json['description'] ?? "",
    checklist: json['checklist'] != null ? List<String>.from(json['checklist']) : [],
    durations: json['durations'] ?? 0,
    attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : [],
    enable: json['enable'] ?? true,
    createAt: json['createAt'] ?? Timestamp(0, 0),
    updateAt: json['updateAt'] ?? Timestamp(0, 0),
  );

  factory MeetingSectionModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return MeetingSectionModel(
      id: data['id'] ?? "",
      title: data['title'] ?? "",
      description: data['description'] ?? "",
      checklist: data['checklist'] != null ? List<String>.from(data['checklist']) : [],
      durations: data['durations'] ?? 0,
      attachments: data['attachments'] != null ? List<String>.from(data['attachments']) : [],
      enable: data['enable'] ?? true,
      createAt: data['createAt'] ?? Timestamp(0, 0),
      updateAt: data['updateAt'] ?? Timestamp(0, 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'checklist': checklist,
    'durations': durations,
    'attachments': attachments,
    'enable': enable,
    'createAt': createAt,
    'updateAt': updateAt,
  };

  MeetingSectionModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? checklist,
    int? durations,
    List<String>? attachments,
    bool? enable,
    Timestamp? createAt,
    Timestamp? updateAt,
  }) {
    return MeetingSectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      checklist: checklist ?? this.checklist,
      durations: durations ?? this.durations,
      attachments: attachments ?? this.attachments,
      enable: enable ?? this.enable,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MeetingSectionModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
