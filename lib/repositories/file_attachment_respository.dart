import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/app_configs.dart';
import 'package:whms/models/file_attachment_model.dart';

import '../models/response_model.dart';

class FileAttachmentRepository {
  FileAttachmentRepository._privateConstructor();

  static FileAttachmentRepository instance =
      FileAttachmentRepository._privateConstructor();

  FirebaseFirestore get fireStore {
    return FirebaseFirestore.instanceFor(
        app: Firebase.app(), databaseId: AppConfigs.databaseId);
  }

  FirebaseStorage get fireStorage {
    return FirebaseStorage.instance;
  }

  Future<ResponseModel<FileAttachmentModel>> getFileAttachmentById(
      String id) async {
    try {
      final snapshot = await fireStore
          .collection("whms_pls_file_attachment")
          .where("id", isEqualTo: id)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results: snapshot.docs
              .map((e) => FileAttachmentModel.fromSnapshot(e))
              .firstOrNull);
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get note by id: $id $e'),
      );
    }
  }

  Future<ResponseModel<void>> addNewFileAttachmentById(
      FileAttachmentModel model) async {
    try {
      await fireStore
          .collection('whms_pls_file_attachment')
          .doc("whms_pls_file_attachment_${model.id}")
          .set(model.toSnapshot());
      return ResponseModel(
        status: ResponseStatus.ok,
        results: null,
      );
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: e.toString()),
      );
    }
  }

  Future<ResponseModel<void>> updateFileAttachment(
      FileAttachmentModel model) async {
    try {
      await fireStore
          .collection('whms_pls_file_attachment')
          .doc("whms_pls_file_attachment_${model.id}")
          .update(model.toSnapshot());
      return ResponseModel(
        status: ResponseStatus.ok,
        results: null,
      );
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: e.toString()),
      );
    }
  }

  Future<String?> uploadFile(String id, String title, PlatformFile file) async {
    try {
      final ref =
          fireStorage.ref().child('whms_pls_file_attachment/$id/$title');

      await ref.putData(file.bytes!);

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading file: $e");
      return null;
    }
  }
}
