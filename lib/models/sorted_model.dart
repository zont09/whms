import 'package:cloud_firestore/cloud_firestore.dart';

class SortedModel {
  final String id;
  final String user;
  final String listName;
  final String ref; // Trường mới
  final List<String> sorted;
  final bool enable; // Trường mới

  // Constructor with default values
  SortedModel({
    this.id = "",
    this.user = "",
    this.listName = "",
    this.ref = "",
    this.sorted = const [],
    this.enable = true,
  });

  // Factory method to create a SortedModel from JSON
  factory SortedModel.fromJson(Map<String, dynamic> json) => SortedModel(
    id: json['id'] ?? "",
    user: json['user'] ?? "",
    listName: json['list_name'] ?? "",
    ref: json['ref'] ?? "", // Trường mới
    sorted: json['sorted'] != null
        ? List<String>.from(json['sorted'])
        : [],
    enable: json['enable'] ?? true, // Trường mới
  );

  // Factory method to create a SortedModel from a Firestore snapshot
  factory SortedModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return SortedModel(
      id: data['id'] ?? "",
      user: data['user'] ?? "",
      listName: data['list_name'] ?? "",
      ref: data['ref'] ?? "", // Trường mới
      sorted: data['sorted'] != null
          ? List<String>.from(data['sorted'])
          : [],
      enable: data['enable'] ?? true, // Trường mới
    );
  }

  // Convert SortedModel to Firestore snapshot format
  Map<String, dynamic> toSnapshot() => {
    'id': id,
    'user': user,
    'list_name': listName,
    'ref': ref, // Trường mới
    'sorted': sorted,
    'enable': enable, // Trường mới
  };

  // Method to copy the SortedModel with modified values
  SortedModel copyWith({
    String? id,
    String? user,
    String? listName,
    String? ref, // Trường mới
    List<String>? sorted,
    bool? enable, // Trường mới
  }) {
    return SortedModel(
      id: id ?? this.id,
      user: user ?? this.user,
      listName: listName ?? this.listName,
      ref: ref ?? this.ref, // Trường mới
      sorted: sorted ?? this.sorted,
      enable: enable ?? this.enable, // Trường mới
    );
  }

  // Convert SortedModel to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'list_name': listName,
    'ref': ref, // Trường mới
    'sorted': sorted,
    'enable': enable, // Trường mới
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SortedModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
