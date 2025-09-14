import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final int roles; // 0: admin, 1: manager, 2: submanager, 3: handler, 4: tasker
  final String location;
  final String name;
  final String gender;
  final String phone;
  final DateTime birthday;
  final String address;
  final String major; // major or skill or degree
  final String code;
  final String type; // 'intern, partime, fulltime'
  final String
      status; // 'probation, permanent, dismissed, resign, fail_probation'
  final String avt;
  final String owner;
  final String leaderId;
  final String
      privateNote; // personal information only owner or manager can see
  final String note; // for leader, owner and manager
  final String userDocument;
  final List<String> process;

  // final List<int> scopes;
  final List<String> scopes;
  final bool mustChangePassword;
  final bool enable;

  bool isSelected = false;

  // Phương thức khởi tạo với giá trị mặc định
  UserModel({
    this.id = "",
    this.email = "",
    this.roles = -1,
    this.location = "",
    this.name = "",
    this.gender = "",
    this.phone = "",
    DateTime? birthday, // Sử dụng `DateTime.now()` nếu không truyền
    this.address = "",
    this.major = "",
    this.code = "",
    this.type = "",
    this.status = "",
    this.avt = "",
    this.owner = "",
    this.leaderId = "",
    this.privateNote = "",
    this.note = "",
    this.userDocument = "",
    this.process = const [],
    this.scopes = const [], // Danh sách mặc định là danh sách rỗng
    this.mustChangePassword = false,
    this.enable = true,
  }) : birthday =
            birthday ?? DateTime.now(); // Giá trị mặc định là ngày hiện tại

  // Factory method to create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] == null ? '' : json['id'].toString(),
        email: json['email'] ?? "",
        roles: json['roles'] != null ? int.parse(json['roles'].toString()) : -1,
        location: json['location'] ?? "",
        name: json['name'] ?? "",
        gender: json['gender'] ?? "Nam",
        phone: json['phone'] ?? "",
        birthday:
            json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
        address: json['address'] ?? "",
        major: json['major'] ?? "",
        code: json['code'] ?? "",
        type: json['type'] ?? "",
        status: json['status'] ?? "",
        avt: json['avt'] ?? "",
        owner: json['owner'] is int ? "" : json['owner'].toString(),
        leaderId: json['leader_id'] is int ? "" : json['leader_id'].toString(),
        privateNote: json['private_note'] ?? "",
        note: json['note'] ?? "",
        userDocument: json['user_document'] ?? "",
        scopes: json['scopes'] != null ? List<String>.from(json['scopes']) : [],
        process:
            json['process'] != null ? List<String>.from(json['process']) : [],
        mustChangePassword: json['must_change_password'] ?? false,
        enable: json['enable'] ?? true,
      );

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return UserModel(
      id: data['id'] == null ? '' : data['id'].toString(),
      email: data['email'] ?? "",
      roles: data['roles'] != null ? int.parse(data['roles'].toString()) : -1,
      location: data['location'] ?? "",
      name: data['name'] ?? "",
      gender: data['gender'] ?? "",
      phone: data['phone'] ?? "",
      birthday: data['birthday'] != null
          ? DateTime.parse(data['birthday'])
          : DateTime.now(),
      address: data['address'] ?? "",
      major: data['major'] ?? "",
      code: data['code'] ?? "",
      type: data['type'] ?? "",
      status: data['status'] ?? "",
      avt: data['avt'] ?? "",
      owner: data['owner'] is int ? "" : data['owner'].toString(),
      leaderId: data['leader_id'] is int ? "" : data['leader_id'].toString(),
      privateNote: data['private_note'] ?? "",
      note: data['note'] ?? "",
      userDocument: data['user_document'] ?? "",
      scopes: data['scopes'] != null ? List<String>.from(data['scopes']) : [],
      process:
          data['process'] != null ? List<String>.from(data['process']) : [],
      mustChangePassword: data['must_change_password'] ?? false,
      enable: data['enable'] ?? true,
    );
  }

  // Method to copy the UserModel with modified values
  UserModel copyWith({
    String? id,
    String? email,
    int? roles,
    String? location,
    String? name,
    String? gender,
    String? phone,
    DateTime? birthday,
    String? address,
    String? major,
    String? code,
    String? type,
    String? status,
    String? avt,
    String? owner,
    String? leaderId,
    String? privateNote,
    String? note,
    String? userDocument,
    List<String>? scopes,
    List<String>? process,
    bool? mustChangePassword,
    bool? enable,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      location: location ?? this.location,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      address: address ?? this.address,
      major: major ?? this.major,
      code: code ?? this.code,
      type: type ?? this.type,
      status: status ?? this.status,
      avt: avt ?? this.avt,
      owner: owner ?? this.owner,
      leaderId: leaderId ?? this.leaderId,
      privateNote: privateNote ?? this.privateNote,
      note: note ?? this.note,
      userDocument: userDocument ?? this.userDocument,
      scopes: scopes ?? this.scopes,
      process: process ?? this.process,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      enable: enable ?? this.enable,
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'roles': roles,
        'location': location,
        'name': name,
        'gender': gender,
        'phone': phone,
        'birthday': birthday.toIso8601String(),
        'address': address,
        'major': major,
        'code': code,
        'type': type,
        'status': status,
        'avt': avt,
        'owner': owner,
        'leader_id': leaderId,
        'private_note': privateNote,
        'note': note,
        'user_document': userDocument,
        'scopes': scopes,
        'process': process,
        'must_change_password': mustChangePassword,
        'enable': enable,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}