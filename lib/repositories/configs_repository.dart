import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/app_configs.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/models/configurations_model.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/date_time_utils.dart';

class ConfigsRepository {
  ConfigsRepository._private();

  static final ConfigsRepository instance = ConfigsRepository._private();

  FirebaseFirestore get fireStore {
    return FirebaseFirestore.instanceFor(
        app: Firebase.app(), databaseId: AppConfigs.databaseId);
  }

  int role = 99999;
  UserModel user = UserModel();
  StatusCheckInDefine isCheckIn = StatusCheckInDefine.notCheckIn;
  init(BuildContext context) async {}

  Future<void> changeRole(int newRole) async {
    role = newRole;
    // role = 30;
  }

  Future<void> changeUser(UserModel newUser) async {
    user = newUser;
    // final fuser = await UserServices.instance.getUserById("fWronNlIFTYdmUjnG1jX");
    // if(fuser != null) {
    //   user = fuser;
    // }
    // else user = newUser;
  }

  void changeCheckIn(StatusCheckInDefine value) {
    isCheckIn = value;
  }

  Future<ResponseModel<ConfigurationsModel>> getConfiguration() async {
    try {
      final snapshot = await fireStore
          .collection("configurations")
          .where("id", isEqualTo: "0")
          .get();
      return ResponseModel(
          status: ResponseStatus.ok,
          results: snapshot.docs
              .map((e) => ConfigurationsModel.fromSnapshot(e))
              .firstOrNull);
    } catch (e) {
      return ResponseModel(
        status: ResponseStatus.error,
        error: ErrorModel(text: '==========> Error getListScope $e'),
      );
    }
  }

  Future<void> updateConfiguration(ConfigurationsModel config) async {
    await fireStore
        .collection('configurations')
        .doc("configurations_${config.id}")
        .set({
      ...config.toJson(),
      "updateAt": DateTimeUtils.getTimestampNow(),
    });
  }
}
