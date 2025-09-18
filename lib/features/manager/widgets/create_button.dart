import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/role_define.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class CreateButton extends StatelessWidget {
  const CreateButton({
    super.key,
    required this.controllerCode,
    required this.controllerEmailLogin,
    required this.controllerPassword,
    required this.controllerName,
    required this.gender,
    required this.controllerEmail,
    required this.controllerPhone,
    required this.controllerAddress,
    required this.controllerMajor,
    required this.department,
    required this.type,
    required this.status,
    required this.controllerNote,
    required this.controllerPrivateNote,
    required this.controllerDate,
    required this.role,
    required this.title,
    required this.owner,
    required this.leader,
    this.idU = "",
    this.avatar = '',
    this.userZ,
    required this.endEvent,
  });

  final TextEditingController controllerCode;
  final TextEditingController controllerEmailLogin;
  final TextEditingController controllerPassword;
  final TextEditingController controllerName;
  final String gender;
  final TextEditingController controllerEmail;
  final TextEditingController controllerPhone;
  final TextEditingController controllerAddress;
  final TextEditingController controllerMajor;
  final String department;
  final String type;
  final String status;
  final TextEditingController controllerNote;
  final TextEditingController controllerPrivateNote;
  final TextEditingController controllerDate;
  final String role;
  final String title;
  final String idU;
  final String avatar;
  final UserModel owner;
  final UserModel leader;
  final UserModel? userZ;
  final Function() endEvent;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    return ZButton(
      title: title,
      icon: "",
      onPressed: () async {
        if (controllerCode.text.isEmpty || controllerEmailLogin.text.isEmpty) {
          await DialogUtils.showResultDialog(
              context,
              AppText.titleLackOfInformation.text,
              AppText.textLackOfInformation.text,
              mainColor: ColorConfig.error);
          return;
        }
        if (user.roles >= 10 && RoleDefineExtension.roleIdByName(role) <= 10 ||
            (user.roles >= 20 &&
                RoleDefineExtension.roleIdByName(role) <= 20)) {
          await DialogUtils.showResultDialog(
              context,
              AppText.textHasError.text,
              AppText.textCantChooseRole.text,
              mainColor: ColorConfig.error);
          return;
        }
        await DialogUtils.handleDialog(context, () async {
          String idUser =
              FirebaseFirestore.instance.collection('daily_pls_user').doc().id;
          UserModel newUser = UserModel(
            id: idU != "" ? idU : idUser,
            name: controllerName.text.isNotEmpty ? controllerName.text : "",
            gender: gender,
            email: controllerEmailLogin.text.isNotEmpty
                ? controllerEmailLogin.text
                : "",
            phone: controllerPhone.text.isNotEmpty ? controllerPhone.text : "",
            birthday: convertToDateTime(controllerDate.text),
            address:
                controllerAddress.text.isNotEmpty ? controllerAddress.text : "",
            major: controllerMajor.text.isNotEmpty ? controllerMajor.text : "",
            code: controllerCode.text.isNotEmpty ? controllerCode.text : "",
            location: department,
            scopes: userZ != null ? userZ!.scopes : [],
            owner: owner.id,
            leaderId: leader.id,
            type: type,
            avt: avatar,
            status: status,
            note: controllerNote.text.isNotEmpty ? controllerNote.text : "",
            privateNote: controllerPrivateNote.text.isNotEmpty
                ? controllerPrivateNote.text
                : "",
            roles: RoleDefineExtension.roleIdByName(role),
            mustChangePassword: idU == "",
            enable: true,
          );
          if (title == AppText.btnUpdate.text) {
            await UserServices.instance.updateUser(newUser);
            if (context.mounted && user.id == newUser.id) {
              await ConfigsCubit.fromContext(context).changUser(newUser);
            }
            endEvent();

            return ResponseModel<String>(
              status: ResponseStatus.ok,
              results: "",
            );
          }
          ResponseModel<String> resCreateAcc = await UserServices.instance
              .createAccount(
                  controllerEmailLogin.text, controllerPassword.text);
          if (resCreateAcc.status == ResponseStatus.ok) {
            await UserServices.instance.addNewUser(newUser);
          }
          if (resCreateAcc.status == ResponseStatus.ok) {
            endEvent();
          }
          return resCreateAcc;
        }, () {},
            successTitle: idU != ""
                ? AppText.titleUpdateUserSuccess.text
                : AppText.titleAddAccount.text,
            successMessage: idU != ""
                ? AppText.textUpdateUserSuccess.text
                : AppText.textAddAccountSuccessful.text,
            failedTitle: idU != ""
                ? AppText.titleUpdateUserFailed.text
                : AppText.titleAddAccountFailed.text,
            failedMessage: idU != ""
                ? AppText.textUpdateUserFailed.text
                : AppText.textAddAccountFailed.text);
      },
      sizeTitle: 18,
      paddingHor: 20,
    );
  }

  DateTime convertToDateTime(String dateString) {
    return DateFormat("dd/MM/yyyy").parse(dateString);
  }
}
