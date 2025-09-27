import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whms/untils/cache_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/file_utils.dart';

class FileAttachmentModel {
  final String id;
  final String type; // link, image, video, doc, audio, others
  final String title;
  final String source;
  final DateTime createdAt;
  final bool enable;

  FileAttachmentModel(
      {this.id = "",
      this.type = "",
      this.title = "",
      this.source = "",
      DateTime? createdAt,
      this.enable = true})
      : createdAt = createdAt ?? DateTime.now();

  factory FileAttachmentModel.fromJson(Map<String, dynamic> json) =>
      FileAttachmentModel(
        id: json['id'] ?? "",
        type: json['type'] ?? "",
        title: json['title'] ?? "",
        source: json['source'] ?? "",
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        enable: json['enable'] ?? true,
      );

  factory FileAttachmentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return FileAttachmentModel(
      id: data['id'] ?? "",
      type: data['type'] ?? "",
      title: data['title'] ?? "",
      source: data['source'] ?? "",
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      enable: data['enable'] ?? true,
    );
  }

  Map<String, dynamic> toSnapshot() => {
        'id': id,
        'type': type,
        'title': title,
        'source': source,
        'createdAt': Timestamp.fromDate(createdAt),
        'enable': enable,
      };

  FileAttachmentModel copyWith({
    String? id,
    String? type,
    String? title,
    String? source,
    DateTime? createdAt,
    bool? enable,
  }) {
    return FileAttachmentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      enable: enable ?? this.enable,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'source': source,
        'createdAt': Timestamp.fromDate(createdAt),
        'enable': enable,
      };

  static handleOpenFile(
      BuildContext context, FileAttachmentModel? model) async {
    if (model == null) return;
    if (model.type == "link") {
      final url = Uri.parse(model.source);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Không thể mở URL $url';
      }
    } else {
      final file = await CacheUtils.instance.getFileGB(model.source);
      if (file == null) return;
      if (FileUtils.isDocument(file) && context.mounted) {
        FileUtils.handleFileDocuments(context, file);
      } else if (FileUtils.isImage(file) && context.mounted) {
        DialogUtils.showAlertDialog(
          context,
          child: Image.memory(
            Uint8List.fromList(file.bytes!),
            height: null,
            width: null,
          ),
        );
      } else if (FileUtils.isVideo(file) && context.mounted) {
        DialogUtils.showVideoDialog(context, file);
      } else if (FileUtils.isAudio(file) && context.mounted) {
        DialogUtils.showAudioDialog(context, file);
      } else {
        FileUtils.downloadPlatformFile(file);
      }
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileAttachmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
