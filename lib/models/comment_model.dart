import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String position;
  final String type;
  final String parent;
  final String content;
  final Timestamp date;
  final bool edited;
  final String owner;
  final List<String> videos;
  final List<String> images;
  final List<String> attachments;
  final bool enable;
  final Timestamp createAt; // Thêm createAt
  final Timestamp updateAt; // Thêm updateAt

  // Constructor with default values
  CommentModel({
    this.id = "",
    this.position = "",
    this.type = "",
    this.parent = "",
    this.content = "",
    Timestamp? date,
    this.edited = false,
    this.owner = "",
    this.videos = const [],
    this.images = const [],
    this.attachments = const [],
    this.enable = false,
    Timestamp? createAt,
    Timestamp? updateAt,
  })  : date = date ?? Timestamp.now(),
        createAt = createAt ?? Timestamp.now(),
        updateAt = updateAt ?? Timestamp.now();

  // Factory method to create a CommentModel from JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: json['id'] ?? "",
    position: json['position'] ?? "",
    type: json['type'] ?? "",
    parent: json['parent'] ?? "",
    content: json['content'] ?? "",
    date: json['date'] ?? Timestamp(0, 0),
    edited: json['edited'] ?? false,
    owner: json['owner'] ?? "",
    videos: json['videos'] != null
        ? List<String>.from(json['videos'])
        : [],
    images: json['images'] != null
        ? List<String>.from(json['images'])
        : [],
    attachments: json['attachments'] != null
        ? List<String>.from(json['attachments'])
        : [],
    enable: json['enable'] ?? false,
    createAt: json['createAt'] ?? Timestamp(0, 0),
    updateAt: json['updateAt'] ?? Timestamp(0, 0),
  );

  // Factory method to create a CommentModel from a Firestore snapshot
  factory CommentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return CommentModel(
      id: data['id'] ?? "",
      position: data['position'] ?? "",
      type: data['type'] ?? "",
      parent: data['parent'] ?? "",
      content: data['content'] ?? "",
      date: data['date'] ?? Timestamp(0, 0),
      edited: data['edited'] ?? false,
      owner: data['owner'] ?? "",
      videos: data['videos'] != null
          ? List<String>.from(data['videos'])
          : [],
      images: data['images'] != null
          ? List<String>.from(data['images'])
          : [],
      attachments: data['attachments'] != null
          ? List<String>.from(data['attachments'])
          : [],
      enable: data['enable'] ?? false,
      createAt: data['createAt'] ?? Timestamp(0, 0),
      updateAt: data['updateAt'] ?? Timestamp(0, 0),
    );
  }

  // Convert CommentModel to Firestore snapshot format
  Map<String, dynamic> toSnapshot() => {
    'id': id,
    'position': position,
    'type': type,
    'parent': parent,
    'content': content,
    'date': date,
    'edited': edited,
    'owner': owner,
    'videos': videos,
    'images': images,
    'attachments': attachments,
    'enable': enable,
    'createAt': createAt,
    'updateAt': updateAt,
  };

  // Method to copy the CommentModel with modified values
  CommentModel copyWith({
    String? id,
    String? position,
    String? type,
    String? parent,
    String? content,
    Timestamp? date,
    bool? edited,
    String? owner,
    List<String>? videos,
    List<String>? images,
    List<String>? attachments,
    bool? enable,
    Timestamp? createAt,
    Timestamp? updateAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      position: position ?? this.position,
      type: type ?? this.type,
      parent: parent ?? this.parent,
      content: content ?? this.content,
      date: date ?? this.date,
      edited: edited ?? this.edited,
      owner: owner ?? this.owner,
      videos: videos ?? this.videos,
      images: images ?? this.images,
      attachments: attachments ?? this.attachments,
      enable: enable ?? this.enable,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  // Convert CommentModel to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'position': position,
    'type': type,
    'parent': parent,
    'content': content,
    'date': date,
    'edited': edited,
    'owner': owner,
    'videos': videos,
    'images': images,
    'attachments': attachments,
    'enable': enable,
    'createAt': createAt,
    'updateAt': updateAt,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CommentModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
