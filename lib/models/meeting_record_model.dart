import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingRecordModel {
  final String id;
  final String title;
  final String content;
  final bool enable;
  final Timestamp createAt;
  final Timestamp updateAt;

  MeetingRecordModel({
    this.id = "",
    this.title = "",
    this.content = "",

    this.enable = true,
    Timestamp? createAt,
    Timestamp? updateAt,
  })  : createAt = createAt ?? Timestamp.now(),
        updateAt = updateAt ?? Timestamp.now();

  factory MeetingRecordModel.fromJson(Map<String, dynamic> json) => MeetingRecordModel(
    id: json['id'] ?? "",
    title: json['title'] ?? "",
    content: json['content'] ?? "",
    enable: json['enable'] ?? true,
    createAt: json['createAt'] ?? Timestamp(0, 0),
    updateAt: json['updateAt'] ?? Timestamp(0, 0),
  );

  factory MeetingRecordModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return MeetingRecordModel(
      id: data['id'] ?? "",
      title: data['title'] ?? "",
      content: data['content'] ?? "",
      enable: data['enable'] ?? true,
      createAt: data['createAt'] ?? Timestamp(0, 0),
      updateAt: data['updateAt'] ?? Timestamp(0, 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'enable': enable,
    'createAt': createAt,
    'updateAt': updateAt,
  };

  MeetingRecordModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? checklist,
    int? durations,
    List<String>? attachments,
    bool? enable,
    Timestamp? createAt,
    Timestamp? updateAt,
  }) {
    return MeetingRecordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      enable: enable ?? this.enable,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MeetingRecordModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
