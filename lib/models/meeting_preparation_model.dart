import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingPreparationModel {
  final String id;
  final String owner;
  final Timestamp date;
  final String content;
  final List<String> checklist;
  final List<String> attachments;
  final List<String> documents;
  final bool enable;

  MeetingPreparationModel({
    this.id = "",
    this.owner = "",
    Timestamp? date,
    this.content = "",
    this.checklist = const [],
    this.attachments = const [],
    this.documents = const [],
    this.enable = true,
  }) : date = date ?? Timestamp.now();

  factory MeetingPreparationModel.fromJson(Map<String, dynamic> json) => MeetingPreparationModel(
    id: json['id'] ?? "",
    owner: json['owner'] ?? "",
    date: json['date'] ?? Timestamp.now(),
    content: json['content'] ?? "",
    checklist: json['checklist'] != null ? List<String>.from(json['checklist']) : [],
    attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : [],
    documents: json['documents'] != null ? List<String>.from(json['documents']) : [],
    enable: json['enable'] ?? true,
  );

  factory MeetingPreparationModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return MeetingPreparationModel(
      id: data['id'] ?? "",
      owner: data['owner'] ?? "",
      date: data['date'] ?? Timestamp.now(),
      content: data['content'] ?? "",
      checklist: data['checklist'] != null ? List<String>.from(data['checklist']) : [],
      attachments: data['attachments'] != null ? List<String>.from(data['attachments']) : [],
      documents: data['documents'] != null ? List<String>.from(data['documents']) : [],
      enable: data['enable'] ?? true,
    );
  }

  Map<String, dynamic> toSnapshot() => {
    'id': id,
    'owner': owner,
    'date': date,
    'content': content,
    'checklist': checklist,
    'attachments': attachments,
    'documents': documents,
    'enable': enable,
  };

  MeetingPreparationModel copyWith({
    String? id,
    String? owner,
    Timestamp? date,
    String? content,
    List<String>? checklist,
    List<String>? attachments,
    List<String>? documents,
    bool? enable,
  }) {
    return MeetingPreparationModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      date: date ?? this.date,
      content: content ?? this.content,
      checklist: checklist ?? this.checklist,
      attachments: attachments ?? this.attachments,
      documents: documents ?? this.documents,
      enable: enable ?? this.enable,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner': owner,
    'date': date,
    'content': content,
    'checklist': checklist,
    'attachments': attachments,
    'documents': documents,
    'enable': enable,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MeetingPreparationModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
