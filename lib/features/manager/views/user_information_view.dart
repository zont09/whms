import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/manager/blocs/user_info_cubit.dart';
import 'package:whms/features/manager/screens/profile_screens.dart';
import 'package:whms/features/manager/views/account_information_view.dart';
import 'package:whms/features/manager/views/header_user_info_view.dart';
import 'package:whms/features/manager/views/personal_information_view.dart';
import 'package:whms/features/manager/views/user_tab.dart';
import 'package:whms/features/manager/views/work_information_view.dart';
import 'package:whms/features/manager/widgets/create_button.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class UserInformationView extends StatelessWidget {
  const UserInformationView(
      {super.key,
      required this.cubit,
      this.user,
      required this.isEdit,
      this.profileCubit});

  final UserModel? user;
  final UserTabCubit? cubit;
  final bool isEdit;
  final ProfileCubit? profileCubit;

  @override
  Widget build(BuildContext context) {
    UserModel userCurrent = ConfigsCubit.fromContext(context).user;
    return SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(150, context)),
            child: BlocProvider(
                create: (context) => UserInfoCubit()..initData(user, context),
                child: BlocBuilder<UserInfoCubit, int>(builder: (cc, ss) {
                  var cubitData = BlocProvider.of<UserInfoCubit>(cc);
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderUserInfoView(
                            user: user, isEdit: isEdit, cubit: cubit),
                        PersonalInformationView(
                            isEdit: isEdit,
                            controllerName: cubitData.controllerName,
                            controllerEmail: cubitData.controllerEmail,
                            controllerPhone: cubitData.controllerPhone,
                            controllerAddress: cubitData.controllerAddress,
                            controllerMajor: cubitData.controllerMajor,
                            controllerDate: cubitData.controllerDate,
                            gender: cubitData.gender,
                            onGenderChanged: (g) => cubitData.updateGender(g)),
                        SizedBox(height: ScaleUtils.scaleSize(18, context)),
                        WorkInformationView(
                            isEdit: isEdit && userCurrent.roles <= 20,
                            nullUser: cubitData.nullUser,
                            controllerCode: cubitData.controllerCode,
                            position: cubitData.position,
                            onPositionChanged: (p) => cubitData.position = p,
                            department: cubitData.department,
                            onDepartmentChanged: (p) => cubitData.updateDe(p),
                            type: cubitData.type,
                            onTypeChanged: (t) => cubitData.updateType(t),
                            status: cubitData.status,
                            onStatusChanged: (s) => cubitData.updateStatus(s),
                            leader: cubitData.leader,
                            onLeaderChanged: (l) => cubitData.updateLeader(l),
                            owner: cubitData.owner,
                            onOwnerChanged: (o) => cubitData.updateOwner(o)),
                        SizedBox(height: ScaleUtils.scaleSize(18, context)),
                        AccountInformationView(
                            isCreate: user == null,
                            isEdit: isEdit && userCurrent.roles <= 20,
                            isShowPassword: user == null,
                            controllerEmail: cubitData.controllerEmailLogin,
                            controllerPassword: cubitData.controllerPassword,
                            role: cubitData.role,
                            onRoleChanged: (r) => cubitData.updateRole(r)),
                        if (isEdit)
                          SizedBox(height: ScaleUtils.scaleSize(18, context)),
                        if (isEdit)
                          Center(
                            child: CreateButton(
                                userZ: user,
                                endEvent: () {
                                  if (cubit != null) {
                                    cubit!.changeMode(0);
                                  }
                                  if (profileCubit != null) {
                                    profileCubit!.changeEdit(false);
                                  }
                                },
                                avatar: cubitData.avatar,
                                title: user != null
                                    ? AppText.btnUpdate.text
                                    : AppText.btnCreateAccount.text,
                                idU: user == null ? "" : user!.id,
                                controllerCode: cubitData.controllerCode,
                                controllerEmailLogin:
                                    cubitData.controllerEmailLogin,
                                controllerPassword:
                                    cubitData.controllerPassword,
                                controllerName: cubitData.controllerName,
                                gender: cubitData.gender,
                                controllerEmail: cubitData.controllerEmail,
                                controllerPhone: cubitData.controllerPhone,
                                controllerAddress: cubitData.controllerAddress,
                                controllerMajor: cubitData.controllerMajor,
                                department: cubitData.department,
                                type: cubitData.type,
                                status: cubitData.status,
                                owner: cubitData.owner,
                                leader: cubitData.leader,
                                controllerNote: cubitData.controllerNote,
                                controllerPrivateNote:
                                    cubitData.controllerPrivateNote,
                                controllerDate: cubitData.controllerDate,
                                role: cubitData.role),
                          ),
                        if (isEdit)
                          SizedBox(height: ScaleUtils.scaleSize(30, context))
                      ]);
                }))));
  }
}
