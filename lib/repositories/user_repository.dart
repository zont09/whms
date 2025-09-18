import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whms/configs/app_configs.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/work_shift_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_text.dart';

class UserRepository {
  UserRepository._privateConstructor();

  static UserRepository instance = UserRepository._privateConstructor();

  FirebaseFirestore get db {
    return FirebaseFirestore.instanceFor(
        app: Firebase.app(), databaseId: AppConfigs.databaseId);
  }

  // FirebaseFirestore get fireStore => FirebaseFirestore.instance;

  // FirebaseFirestore get db {
  //   return FirebaseFirestore.instance;
  // }

  FirebaseStorage get storage => FirebaseStorage.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getAllUser() async {
    final snapshot = await db
        .collection("daily_pls_user")
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllUserIgnoreEnable() async {
    final snapshot = await db.collection("daily_pls_user").get();
    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserById(String id) async {
    final snapshot = await db
        .collection("daily_pls_user")
        .where("id", isEqualTo: id)
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<ResponseModel<List<UserModel>>> getUserByScopeId(String idScp) async {
    try {
      final snapshot = await db
          .collection("daily_pls_user")
          .where("scopes", arrayContains: idScp)
          .where('enable', isEqualTo: true)
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results:
          snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error get user by scope $e'),
      );
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getUserByEmail(String id) async {
    final snapshot = await db
        .collection("daily_pls_user")
        .where("email", isEqualTo: id)
        .where("enable", isEqualTo: true)
        .get();
    return snapshot;
  }

  Future<void> createUser(UserModel user) async {
    await db
        .collection('daily_pls_user')
        .doc("daily_pls_user_${user.id}")
        .set(user.toJson());
  }

  Future<void> updateUser(UserModel user) async {
    await db
        .collection('daily_pls_user')
        .doc("daily_pls_user_${user.id}")
        .update(user.toJson());
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<ResponseModel<UserModel>> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await UserServices.instance.getUserByEmail(email);
      if (user == null || !user.enable) {
        await FirebaseAuth.instance.signOut();
        return ResponseModel(
          status: ResponseStatus.error,
          error: ErrorModel(
            text: AppText.textWrongPassword.text,
          ),
        );
      }
      return ResponseModel(
        status: ResponseStatus.ok,
        results: user,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return ResponseModel(
            status: ResponseStatus.error,
            error: ErrorModel(text: AppText.textEmailAddressInvalid.text),
          );
        case 'user-not-found':
          return ResponseModel(
            status: ResponseStatus.error,
            error: ErrorModel(text: AppText.textNotFoundAccount.text),
          );
        case 'wrong-password':
          return ResponseModel(
            status: ResponseStatus.error,
            error: ErrorModel(text: AppText.textWrongPassword.text),
          );
        default:
          return ResponseModel(
            status: ResponseStatus.error,
            error: ErrorModel(text: 'Lỗi không xác định: ${e.message}.'),
          );
      }
    } catch (e) {
      // Xử lý các lỗi khác
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: 'Đã xảy ra lỗi: $e'),
      );
    }
  }

  Future<ResponseModel<List<UserModel>>> getUsersForAddingScope(
      int roleId) async {
    try {
      final snapshot = await db
          .collection("daily_pls_user")
      // .where('roles', isGreaterThan: roleId)
          .where("enable", isEqualTo: true)
          .get();

      return ResponseModel(
          status: ResponseStatus.ok,
          results:
          snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList());
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error getUsersForAddingScope $e'),
      );
    }
  }

  Future<ResponseModel<String>> createAccountFBAuth(
      String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        return ResponseModel(
          status: ResponseStatus.ok,
          results: AppText.textCreateAccountSuccessful.text,
        );
      } else {
        return ResponseModel(
            status: ResponseStatus.error,
            error: ErrorModel(
              text: AppText.textCreateAccountFailed.text,
            ));
      }
    } on FirebaseAuthException catch (e) {
      // Bắt các lỗi phổ biến
      if (e.code == 'weak-password') {
        return ResponseModel(
            status: ResponseStatus.error,
            error: ErrorModel(
              text: AppText.textWeakPassword.text,
            ));
      } else if (e.code == 'email-already-in-use') {
        return ResponseModel(
            status: ResponseStatus.error,
            error: ErrorModel(
              text: AppText.textEmailAlreadyUse.text,
            ));
      } else if (e.code == 'invalid-email') {
        return ResponseModel(
            status: ResponseStatus.error,
            error: ErrorModel(text: AppText.textEmailAddressInvalid.text));
      } else {
        return ResponseModel(
            status: ResponseStatus.error,
            error: ErrorModel(
              text: e.message,
            ));
      }
    } catch (e) {
      // Bắt lỗi không xác định
      return ResponseModel(
          status: ResponseStatus.error,
          results: AppText.textCreateAccountFailed.text);
    }
  }

  Future<ResponseModel<String>> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return ResponseModel(
        status: ResponseStatus.ok,
        results: AppText.textSendNewPassword.text + email,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ResponseModel(
          status: ResponseStatus.error,
          results: AppText.textUserNotFound.text,
        );
      } else if (e.code == 'invalid-email') {
        return ResponseModel(
          status: ResponseStatus.error,
          results: AppText.textEmailAddressInvalid.text,
        );
      } else {
        return ResponseModel(status: ResponseStatus.error, results: e.message);
      }
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        results: e.toString(),
      );
    }
  }

  Future<ResponseModel<String>> changePassword(String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return ResponseModel(
            status: ResponseStatus.ok,
            results: AppText.textChangePasswordSuccessful.text);
      } else {
        return ResponseModel(
            status: ResponseStatus.error,
            results: AppText.textChangePasswordFailed.text);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return ResponseModel(
            status: ResponseStatus.error,
            results: AppText.textWeakPassword.text);
      } else if (e.code == 'requires-recent-login') {
        return ResponseModel(
            status: ResponseStatus.error,
            results: AppText.textChangePasswordFailed.text);
      } else {
        return ResponseModel(status: ResponseStatus.error, results: e.message);
      }
    } catch (e) {
      return ResponseModel(status: ResponseStatus.error, results: e.toString());
    }
  }

  Future<ResponseModel<bool>> verifyCurrentPassword(
      String currentPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("No user is currently signed in.");
      }
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      return ResponseModel(
        status: ResponseStatus.ok,
        results: true,
      );
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        results: false,
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // if(context.mounted) {
      //   context.go(AppRoutes.login);
      // }
    } catch (e) {
      throw Exception("Logout failed");
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllWorkShift() async {
    final snapshot = await db.collection("daily_pls_work_shift").get();
    return snapshot;
  }

  // Future<QuerySnapshot<Map<String, dynamic>>> getAllUserIgnoreEnable() async {
  //   final snapshot =
  //   await db.collection("daily_pls_user").get();
  //   return snapshot;
  // }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkShiftByIdUserAndDate(
      String id, DateTime date) async {
    final snapshot = await db
        .collection("daily_pls_work_shift")
        .where("user", isEqualTo: id)
        .where("date", isEqualTo: date.toIso8601String())
        .get();

    return snapshot;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getWorkShiftById(
      String id) async {
    final snapshot = await db
        .collection("daily_pls_work_shift")
        .where("id", isEqualTo: id)
        .get();
    return snapshot;
  }

  Future<void> createWorkShift(WorkShiftModel work) async {
    await db
        .collection('daily_pls_work_shift')
        .doc("daily_pls_work_shift_${work.id}")
        .set(work.toJson());
  }

  Future<void> updateWorkShiftField(
      WorkShiftModel model, WorkShiftModel preModel,
      {bool isGetUpdateTime = true}) async {
    final updateFields = WorkShiftModel.getDifferentFields(preModel, model);
    var newestWork = await getWorkShiftById(model.id);
    Map<String, dynamic> updatedMap = {
      for (var doc in newestWork.docs) ...doc.data()
    };
    updateFields.forEach((k, v) {
      updatedMap[k] = v;
    });
    await db
        .collection('daily_pls_work_shift')
        .doc("daily_pls_work_shift_${model.id}")
        .update({
      ...updatedMap,
    });
  }

  Future<String> uploadFileAndGetUrl(Uint8List data) async {
    final now = DateTime.now().microsecondsSinceEpoch;
    final ref =
    FirebaseStorage.instance.ref().child('avatar/${"user_avatar-$now"}');
    final metadata = SettableMetadata(contentType: 'image/png');
    await ref.putData(data, metadata);
    return await ref.getDownloadURL();
  }
}