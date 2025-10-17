import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/create_assignment_popup.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class NoWuView extends StatelessWidget {
  final ManagementCubit managementCubit;
  const NoWuView(this.managementCubit, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/img_no_task.png',
              height: ScaleUtils.scaleSize(300, context)),
          Container(
              margin: EdgeInsets.only(top: ScaleUtils.scaleSize(20, context)),
              child: ZButton(
                  title: AppText.btnCreateWorkUnit.text,
                  icon: '',
                  paddingHor: 30,
                  paddingVer: 5,
                  sizeTitle: 26,
                  isShadow: true,
                  colorBorder: ColorConfig.primary4,
                  colorBackground: ColorConfig.primary4,
                  onPressed: () async {
                    if (context.mounted) {
                      DialogUtils.showAlertDialog(context,
                          child: CreateAssignmentPopup(
                              ancestries: managementCubit.ancestries,
                              typeAssignment: 1,
                              reload: (item) async {
                                // await managementCubit.addItemToTree(item);
                                // await managementCubit.loadListWorkings();
                                managementCubit.buildUI();
                              },
                              scopes: [managementCubit.selectedScope!.id],
                              userId: managementCubit.handlerUser.id,
                              selectedWorking: WorkingUnitModel().copyWith(),
                              assignees:
                                  managementCubit.selectedScope!.members));
                    }
                  })),
          Text(AppText.titleNotWorkingUnit.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(32, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                  color: ColorConfig.textTertiary)),
          Text(AppText.txtNotWorkingUnit.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(24, context),
                  fontWeight: FontWeight.w400,
                  letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                  color: ColorConfig.textTertiary))
        ]);
  }
}
