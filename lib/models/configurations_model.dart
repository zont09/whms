import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigurationsModel {
  final String id;
  final String version;
  final Timestamp updateAt;

  ConfigurationsModel({this.id = "", this.version = "", Timestamp? updateAt})
      : updateAt = updateAt ?? Timestamp.now();

  factory ConfigurationsModel.fromJson(Map<String, dynamic> json) =>
      ConfigurationsModel(
        id: json['id'] == null ? '' : json['id'].toString(),
        version: json['version'] == null ? '' : json['version'].toString(),
        updateAt: json['updateAt'] != null
            ? (json['updateAt'] as Timestamp)
            : Timestamp.now(),
      );

  factory ConfigurationsModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return ConfigurationsModel.fromJson(data);
  }

  // Method to copy the UserModel with modified values
  ConfigurationsModel copyWith({
    String? id,
    String? version,
    Timestamp? updateAt,
  }) {
    return ConfigurationsModel(
      id: id ?? this.id,
      version: version ?? this.version,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() =>
      {'id': id, 'version': version, 'updateAt': updateAt};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationsModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
