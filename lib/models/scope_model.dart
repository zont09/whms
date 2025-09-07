import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:whms/models/user_model.dart';

class ScopeModel {
  String id;
  String title;
  String owner;
  String parentScope;
  String description;
  List<String> managers;
  List<String> members;
  List<String> viewers;
  List<String> documents;
  List<String> shares;
  bool enable;
  bool isOkrs;
  String okrsGroup;
  Timestamp createAt;

  List<UserModel> memberList = [];
  List<UserModel> viewerList = [];

  List<UserModel> selectedMembers = [];
  List<UserModel> selectedManagers = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();

  bool isSelected = false;
  bool isOpen = false;

  int okrs = -1;

  ScopeModel({
    this.id = '',
    this.title = '',
    this.owner = '-1',
    this.parentScope = '-1',
    this.description = '',
    this.managers = const [],
    this.members = const [],
    this.viewers = const [],
    this.documents = const [],
    this.shares = const [],
    this.enable = true,
    this.okrsGroup = '',
    this.isOkrs = false,
    Timestamp? createAt,
  }) : createAt = createAt ?? Timestamp.now();
  // ScopeModel(
  //     {required this.id,
  //     required this.title,
  //     required this.owner,
  //     required this.parentScope,
  //     required this.managers,
  //     required this.members,
  //     required this.description,
  //     required this.documents,
  //     required this.viewers,
  //     required this.enable,
  //     required this.shares});

  factory ScopeModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ScopeModel(
      id: data['id'] ?? '',
      title: data['title'] ?? "",
      description: data['description'] ?? '',
      owner: data['owner'] ?? '-1',
      parentScope: data['parent_scope'] ?? '-1',
      managers:
          (data['managers'] == null ? [] : (data['managers'] as List<dynamic>))
              .map((e) => e.toString())
              .toList(),
      enable: data['enable'] ?? true,
      members:
          (data['members'] == null ? [] : (data['members'] as List<dynamic>))
              .map((e) => e.toString())
              .toList(),
      viewers:
          (data['viewers'] == null ? [] : (data['viewers'] as List<dynamic>))
              .map((e) => e.toString())
              .toList(),
      documents: (data['documents'] == null
              ? []
              : (data['documents'] as List<dynamic>))
          .map((e) => e.toString())
          .toList(),
      shares: (data['shares'] == null ? [] : (data['shares'] as List<dynamic>))
          .map((e) => e.toString())
          .toList(),
      okrsGroup: data['okrs_group'] ?? "",
      isOkrs: data['is_okrs'] ?? false,
      createAt: data['createAt'] != null
          ? (data['createAt'] as Timestamp)
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toSnapshot() => {
        'id': id,
        'title': title,
        'owner': owner,
        'description': description,
        'parent_scope': parentScope,
        'members': members,
        'viewers': viewers,
        'documents': documents,
        'managers': managers,
        'shares': shares,
        'enable': enable,
        'is_okrs': isOkrs,
        'okrs_group': okrsGroup,
        'createAt': createAt
      };

  factory ScopeModel.initial({bool isOkrs = false, String okrsGroup = ''}) {
    final db = FirebaseFirestore.instance;

    var newDoc = db.collection('daily_pls_scope').doc();
    return ScopeModel(
        id: newDoc.id,
        title: '',
        owner: '-1',
        parentScope: '-1',
        managers: [],
        members: [],
        description: '',
        documents: [],
        viewers: [],
        enable: true,
        shares: [],
        isOkrs: isOkrs,
        okrsGroup: okrsGroup,
        createAt: Timestamp.now());
  }

  ScopeModel copyWith(
      {String? id,
      String? title,
      String? parentScope,
      String? description,
      String? owner,
      List<String>? documents,
      List<String>? shares,
      List<String>? managers,
      List<String>? members,
      List<String>? viewers,
      bool? enable,
      bool? isOkrs,
      String? okrsGroup,
      Timestamp? createAt}) {
    return ScopeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      parentScope: parentScope ?? this.parentScope,
      description: description ?? this.description,
      owner: owner ?? this.owner,
      documents: documents ?? this.documents,
      shares: shares ?? this.shares,
      managers: managers ?? this.managers,
      members: members ?? this.members,
      viewers: viewers ?? this.viewers,
      enable: enable ?? this.enable,
      isOkrs: isOkrs ?? this.isOkrs,
      okrsGroup: okrsGroup ?? this.okrsGroup,
      createAt: createAt ?? this.createAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ScopeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class FullScopeEntry {
  ScopeModel model;
  List<ScopeModel> list;

  FullScopeEntry({required this.model, required this.list});
}
