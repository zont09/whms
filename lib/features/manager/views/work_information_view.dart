import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/manager/widgets/dropdown_custom.dart';
import 'package:whms/features/manager/widgets/dropdown_select_user_manager.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/text_field_custom.dart';

class WorkInformationView extends StatelessWidget {
  final TextEditingController controllerCode;
  final String position;
  final ValueChanged<String> onPositionChanged;
  final String department;
  final ValueChanged<String> onDepartmentChanged;
  final String type;
  final ValueChanged<String> onTypeChanged;
  final String status;
  final ValueChanged<String> onStatusChanged;
  final UserModel leader;
  final ValueChanged<UserModel> onLeaderChanged;
  final UserModel owner;
  final ValueChanged<UserModel> onOwnerChanged;
  final UserModel nullUser;

  final bool isEdit;

  const WorkInformationView({
    Key? key,
    required this.controllerCode,
    required this.position,
    required this.onPositionChanged,
    required this.department,
    required this.onDepartmentChanged,
    required this.type,
    required this.onTypeChanged,
    required this.status,
    required this.onStatusChanged,
    required this.leader,
    required this.onLeaderChanged,
    required this.owner,
    required this.onOwnerChanged,
    required this.isEdit,
    required this.nullUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: ColorConfig.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(ScaleUtils.scaleSize(30, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppText.titleEmployeeInformation.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(19, context),
                  fontWeight: FontWeight.w500,
                  color: ColorConfig.textSecondary),
            ),
            SizedBox(
              height: ScaleUtils.scaleSize(18, context),
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: TextFieldCustom(
                        isEdit: isEdit,
                        controllerText: controllerCode,
                        title: AppText.titleIdStaff.text)),
                SizedBox(
                  width: ScaleUtils.scaleSize(90, context),
                ),
                Expanded(
                    flex: 1,
                    child: DropdownCustom(
                      isEdit: isEdit,
                      options: [
                        AppText.textTeamIT.text,
                        AppText.textTeamDesigns.text,
                        AppText.textTeamData.text,
                        AppText.textTeamSales.text,
                        AppText.textTeamSupports.text,
                        AppText.textTeamMarketing.text,
                        AppText.textTeamHR.text,
                        AppText.textTeamOther.text
                      ],
                      title: AppText.titleDepartments.text,
                      onChanged: (value) {
                        onDepartmentChanged(value!);
                      },
                      defaultValue: department,
                    )),
              ],
            ),
            SizedBox(
              height: ScaleUtils.scaleSize(18, context),
            ),
            Row(
              children: [
                // Expanded(
                //     flex: 1,
                //     child: DropdownCustom(
                //       options: [
                //         AppText.textStaff.text,
                //         AppText.textDepartmentHead.text,
                //         AppText.textManager.text,
                //         AppText.textBoss.text,
                //       ],
                //       title: AppText.titlePosition.text,
                //       onChanged: (value) {
                //         onPositionChanged(value!);
                //       },
                //       defaultValue: position,
                //     )),
                // Expanded(
                //   flex: 1,
                //   child: DropdownCustom(
                //     isEdit: isEdit,
                //     options: [""],
                //     title: AppText.titleOwner.text,
                //     onChanged: (value) {
                //       onOwnerChanged(value!);
                //     },
                //     defaultValue: leader,
                //   ),
                // ),
                Expanded(
                  flex: 1,
                  child: DropdownSelectUserManager(
                    isEdit: isEdit,
                    options: [
                      ...ConfigsCubit.fromContext(context).allUsers,
                      nullUser
                    ],
                    title: AppText.titleOwner.text,
                    onChanged: (value) {
                      onOwnerChanged(value!);
                    },
                    defaultValue: owner,
                  ),
                ),
                SizedBox(
                  width: ScaleUtils.scaleSize(90, context),
                ),
                Expanded(
                    flex: 1,
                    child: DropdownCustom(
                      isEdit: isEdit,
                      options: [
                        AppText.textPartTime.text,
                        AppText.textFullTime.text,
                        AppText.textIntern.text,
                      ],
                      title: AppText.titleWorkType.text,
                      onChanged: (value) {
                        onTypeChanged(value!);
                      },
                      defaultValue: type,
                    )),
              ],
            ),
            SizedBox(
              height: ScaleUtils.scaleSize(18, context),
            ),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: DropdownCustom(
                      isEdit: isEdit,
                      options: [
                        AppText.textProbation.text,
                        AppText.textPermanent.text,
                        AppText.textDismissed.text,
                        AppText.textResign.text,
                        AppText.textFailProbation.text,
                      ],
                      title: AppText.titleStatus.text,
                      onChanged: (value) {
                        onStatusChanged(value!);
                      },
                      defaultValue: status,
                    )),
                SizedBox(
                  width: ScaleUtils.scaleSize(90, context),
                ),
                Expanded(
                    flex: 1,
                    child: DropdownSelectUserManager(
                      isEdit: isEdit,
                      options: [
                        ...ConfigsCubit.fromContext(context).allUsers,
                        nullUser
                      ],
                      title: AppText.titleLeader.text,
                      onChanged: (value) {
                        onLeaderChanged(value!);
                      },
                      defaultValue: leader,
                    ),),
              ],
            ),
            SizedBox(
              height: ScaleUtils.scaleSize(18, context),
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       flex: 1,
            //       child: DropdownCustom(
            //         options: [""],
            //         title: AppText.titleOwner.text,
            //         onChanged: (value) {
            //           onLeaderChanged(value!);
            //         },
            //         defaultValue: leader,
            //       ),
            //     ),
            //     SizedBox(
            //       width: ScaleUtils.scaleSize(90, context),
            //     ),
            //     Expanded(flex: 1, child: Container()),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
