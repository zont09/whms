import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/role_define.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';

class UserInfoCubit extends Cubit<int> {
  UserInfoCubit() : super(0);

  String position = AppText.textStaff.text;
  String department = AppText.textTeamIT.text;
  String type = AppText.textPartTime.text;
  String status = AppText.textProbation.text;
  final UserModel nullUser = UserModel();
  UserModel leader = UserModel();
  UserModel owner = UserModel();
  String gender = AppText.textMale.text;
  String role = "";
  String avatar = '';

  // text: user != null ? user!.name :
  final TextEditingController controllerName = TextEditingController(text: "");
  final TextEditingController controllerEmail = TextEditingController(text: "");
  final TextEditingController controllerPhone = TextEditingController(text: "");
  final TextEditingController controllerAddress =
      TextEditingController(text: "");
  final TextEditingController controllerMajor = TextEditingController(text: "");
  final TextEditingController controllerDate = TextEditingController(
      text: DateTimeUtils.formatDateDayMonthYear(DateTime.now()));
  final TextEditingController controllerCode = TextEditingController(text: "");
  final TextEditingController controllerNote = TextEditingController(text: "");
  final TextEditingController controllerPrivateNote =
      TextEditingController(text: "");
  final TextEditingController controllerEmailLogin =
      TextEditingController(text: "");
  final TextEditingController controllerPassword =
      TextEditingController(text: "");

  final UserServices _userServices = UserServices.instance;

  initData(UserModel? user, BuildContext context) {
    UserModel userCurrent = ConfigsCubit.fromContext(context).user;
    final configCubit = ConfigsCubit.fromContext(context);
    role = userCurrent.roles == 0
        ? AppText.textManager.text
        : AppText.textTasker.text;

    owner = nullUser;
    leader = nullUser;

    if (user == null) {
      return;
    }

    avatar = user.avt;
    department = user.location;
    type = user.type;
    status = user.status;
    leader = configCubit.usersMap[user.leaderId] ?? nullUser;
    owner = configCubit.usersMap[user.owner] ?? nullUser;
    gender = user.gender;
    role = RoleDefineExtension.roleName(user.roles);
    controllerName.text = user.name;
    controllerEmail.text = user.email;
    controllerPhone.text = user.phone;
    controllerAddress.text = user.address;
    controllerMajor.text = user.major;
    controllerCode.text = user.code;
    controllerDate.text = DateTimeUtils.formatDateDayMonthYear(user.birthday);
    controllerNote.text = user.note;
    controllerPrivateNote.text = user.privateNote;
    controllerEmailLogin.text = user.email;
    controllerPassword.text = "zont09";
  }

  updateDe(String value) {
    department = value;
    emit(state + 1);
  }

  updateType(String value) {
    type = value;
    emit(state + 1);
  }

  updateStatus(String value) {
    status = value;
    emit(state + 1);
  }

  updateGender(String value) {
    gender = value;
    emit(state + 1);
  }

  updateRole(String value) {
    role = value;
    emit(state + 1);
  }

  updateLeader(UserModel value) {
    leader = value;
    emit(state + 1);
  }

  updateOwner(UserModel value) {
    owner = value;
    emit(state + 1);
  }

  changeAvatar(Uint8List img, UserModel model) async {
    final String avt = await _userServices.changeAvatar(img);
    print('=======> avt $avt');
    await _userServices.updateUser(model.copyWith(avt: avt));
    avatar = avt;
    emit(state + 1);
  }
}
