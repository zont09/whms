import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/app_configs.dart';
import 'package:whms/models/comment_model.dart';
import 'package:whms/models/response_model.dart';

class CommentRepository {
  CommentRepository._privateConstructor();

  static CommentRepository instance = CommentRepository._privateConstructor();

  FirebaseFirestore get fireStore {
    return FirebaseFirestore.instanceFor(
        app: Firebase.app(), databaseId: AppConfigs.databaseId);
  }

  FirebaseStorage get fireStorage {
    return FirebaseStorage.instance;
  }

  Future<ResponseModel<List<CommentModel>>> getAllComments() async {
    try {
      final snapshot = await fireStore
          .collection("whms_pls_comment")
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => CommentModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get all comments $e'),
      );
    }
  }

  Future<ResponseModel<CommentModel>> getCommentById(String id) async {
    try {
      final snapshot = await fireStore
          .collection("whms_pls_comment")
          .where("id", isEqualTo: id)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
              snapshot.docs.map((e) => CommentModel.fromSnapshot(e)).firstOrNull);
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get comment by id: $id $e'),
      );
    }
  }

  Future<ResponseModel<List<CommentModel>>> getCommentByType(String type) async {
    try {
      final snapshot = await fireStore
          .collection("whms_pls_comment")
          .where("type", isEqualTo: type)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
          snapshot.docs.map((e) => CommentModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get comment by type: $type $e'),
      );
    }
  }

  Future<ResponseModel<List<CommentModel>>> getCommentByPosition(String position) async {
    try {
      final snapshot = await fireStore
          .collection("whms_pls_comment")
          .where("position", isEqualTo: position)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
          snapshot.docs.map((e) => CommentModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get comment by position: $position $e'),
      );
    }
  }

  Future<ResponseModel<List<CommentModel>>> getCommentByParent(String parent) async {
    try {
      final snapshot = await fireStore
          .collection("whms_pls_comment")
          .where("parent", isEqualTo: parent)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
          snapshot.docs.map((e) => CommentModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get comment by parent: $parent $e'),
      );
    }
  }

  Future<ResponseModel<void>> addNewComment(CommentModel model) async {
    try {
      await fireStore
          .collection('whms_pls_comment')
          .doc("whms_pls_comment_${model.id}")
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

  Future<ResponseModel<void>> updateComment(CommentModel model) async {
    try {
      await fireStore
          .collection('whms_pls_comment')
          .doc("whms_pls_comment_${model.id}")
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

  Future<String?> uploadFile(PlatformFile file, String type, String idComment) async {
    try {
      final ref =
          fireStorage.ref().child('comment_attachments/$idComment/$type/${file.name}');

      await ref.putData(file.bytes!);

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading file: $e");
      return null;
    }
  }
}
