import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/repositories/user_repository.dart';

class UserServices {
  UserServices._privateConstructor();

  static UserServices instance = UserServices._privateConstructor();

  final UserRepository _userRepository = UserRepository.instance;

  // ========= ACCOUNT FIREBASE AUTH =========

  Future<ResponseModel<UserModel>> login(String email, String password) {
    return _userRepository.login(email, password);
  }

  Future<ResponseModel<String>> createAccount(
      String email, String password) async {
    return _userRepository.createAccountFBAuth(email, password);
  }

  Future<ResponseModel<String>> resetPassword(String email) async {
    return _userRepository.resetPassword(email);
  }

  Future<ResponseModel<String>> changePassword(String newPassword) async {
    return _userRepository.changePassword(newPassword);
  }

  Future<ResponseModel<bool>> verifyCurrentPassword(
      String currentPassword) async {
    return _userRepository.verifyCurrentPassword(currentPassword);
  }

  Future<void> logout(BuildContext context) async {
    return _userRepository.logout(context);
  }

  // ========= USER =========

  Future<List<UserModel>> getAllUser() async {
    final result = (await UserRepository.instance.getAllUser())
        .docs
        .map((e) => UserModel.fromSnapshot(e))
        .toList();
    return result;
  }

  // Future<List<UserModel>> getAllUserIgnoreEnable() async {
  //   final result = (await UserRepository.instance.getAllUserIgnoreEnable())
  //       .docs
  //       .map((e) => UserModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }

  Future<UserModel?> getUserById(String id) async {
    final result = (await UserRepository.instance.getUserById(id))
        .docs
        .map((e) => UserModel.fromSnapshot(e))
        .firstOrNull;
    return result;
  }

  // Future<List<UserModel>> getUserByScopeId(String idScp) async {
  //   final response = await _userRepository.getUserByScopeId(idScp);
  //   if (response.status == ResponseStatus.ok &&
  //       response.results != null &&
  //       response.results!.isNotEmpty) {
  //     return response.results!;
  //   }
  //   return [];
  // }

  Future<UserModel?> getUserByEmail(String id) async {
    final result = (await UserRepository.instance.getUserByEmail(id))
        .docs
        .map((e) => UserModel.fromSnapshot(e))
        .firstOrNull;
    return result;
  }

  Future<void> addNewUser(UserModel model) async {
    await UserRepository.instance.createUser(model);
    debugPrint("=========> Add new user: ${model.id} ${model.name}");
  }

  Future<void> updateUser(UserModel model) async {
    await UserRepository.instance.updateUser(model);
    debugPrint("=========> Update user: ${model.id} ${model.name}");
  }

  changeAvatar(Uint8List img) {
    return UserRepository.instance.uploadFileAndGetUrl(img);
  }

  // ========= WORK SHIFT =========

  // Future<List<WorkShiftModel>> getAllWorkShift() async {
  //   final result = (await UserRepository.instance.getAllWorkShift())
  //       .docs
  //       .map((e) => WorkShiftModel.fromSnapshot(e))
  //       .toList();
  //   return result;
  // }
}
