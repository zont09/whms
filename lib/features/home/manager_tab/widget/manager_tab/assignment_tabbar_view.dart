import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/views/task/create_assignment_popup.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/management_assignment_item.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/add_button.dart';
import 'package:whms/widgets/reorder_able_widget.dart';
import 'package:flutter/material.dart';

class AssignmentTabBarView extends StatelessWidget {
  final ManagementCubit managementCubit;
  const AssignmentTabBarView(this.managementCubit, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(children: [
        if (managementCubit.tab == 0)
          managementCubit.tabX.isNotEmpty
              ? ReorderAbleWidget(
                  changeOrder: (a, b) => managementCubit.changeOrder(a, b),
                  children: [
                      ...managementCubit.tabX.map((e) =>
                          ManagementAssignmentItem(
                              key: Key('x_${e.id}_${e.level}'),
                              choose: () async {
                                await managementCubit.chooseWorkingUnit(e);
                              },
                              e,
                              endEvent: endEvent,
                              reload: reload,
                              address: managementCubit.link,
                              typeAssignment:
                                  TypeAssignmentDefineExtension.types(e.type)
                                          .index +
                                      4))
                    ])
              : Padding(
                  padding:
                      EdgeInsets.only(top: ScaleUtils.scaleSize(50, context)),
                  child: Text(
                      AppText.titleNotWorkingUnitInTab.text.replaceAll(
                          '@', AppText.txtSprint.text.toLowerCase()),
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(20, context),
                          fontWeight: FontWeight.w500,
                          letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                          color: ColorConfig.textTertiary))),
        if (managementCubit.tab == 1)
          managementCubit.tabY.isNotEmpty
              ? ReorderAbleWidget(
                  changeOrder: (a, b) => managementCubit.changeOrder(a, b),
                  children: [
                      ...managementCubit.tabY.map((e) =>
                          ManagementAssignmentItem(
                              key: Key('y_${e.id}'),
                              choose: () async =>
                                  await managementCubit.chooseWorkingUnit(e),
                              e,
                              endEvent: endEvent,
                              reload: reload,
                              address: managementCubit.link,
                              typeAssignment:
                                  TypeAssignmentDefineExtension.types(e.type)
                                          .index +
                                      4))
                    ])
              : Padding(
                  padding:
                      EdgeInsets.only(top: ScaleUtils.scaleSize(50, context)),
                  child: Text(
                      AppText.titleNotWorkingUnitInTab.text
                          .replaceAll('@', AppText.txtStory.text.toLowerCase()),
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(20, context),
                          fontWeight: FontWeight.w500,
                          letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                          color: ColorConfig.textTertiary))),
        if (managementCubit.tab == 2)
          managementCubit.tabZ.isNotEmpty
              ? ReorderAbleWidget(
                  changeOrder: (a, b) => managementCubit.changeOrder(a, b),
                  children: [
                      ...managementCubit.tabZ.map((e) =>
                          ManagementAssignmentItem(
                              key: Key('z_${e.id}'),
                              choose: () async => await
                                  managementCubit.chooseWorkingUnit(e),
                              e,
                              endEvent: () {},
                              reload: reload,
                              address: managementCubit.link,
                              typeAssignment:
                                  TypeAssignmentDefineExtension.types(e.type)
                                          .index +
                                      4))
                    ])
              : Padding(
                  padding:
                      EdgeInsets.only(top: ScaleUtils.scaleSize(50, context)),
                  child: Text(
                      AppText.titleNotWorkingUnitInTab.text
                          .replaceAll('@', AppText.txtTask.text.toLowerCase()),
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(20, context),
                          fontWeight: FontWeight.w500,
                          letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                          color: ColorConfig.textTertiary))),
      ]),
      if ((managementCubit.tab == 0 && managementCubit.tabX.isEmpty) ||
          (managementCubit.tab == 1 && managementCubit.tabY.isEmpty) ||
          (managementCubit.tab == 2 && managementCubit.tabZ.isEmpty))
        AddButton(
            AppText.btnCreateAssignment.text.replaceAll('@',
                managementCubit.listTabs[managementCubit.tab].toLowerCase()),
            isFirstIcon: true, onTap: () async {
          if (context.mounted) {
            DialogUtils.showAlertDialog(context,
                child: CreateAssignmentPopup(
                    ancestries: managementCubit.ancestries,
                    typeAssignment: managementCubit.tab + 5,
                    reload: (v) async {

                      // await managementCubit.addItemToTree(v);
                      await managementCubit.buildUI();
                    },
                    isSub: true,
                    scopes: [managementCubit.selectedScope!.id],
                    userId: managementCubit.handlerUser.id,
                    selectedWorking: managementCubit.selectedWorking!,
                    assignees: managementCubit.selectedWorking!.assignees));
          }
        }),
      SizedBox(height: ScaleUtils.scaleSize(10, context))
    ]);
  }

  reload(WorkingUnitModel item) async {
    // await managementCubit.addItemToTree(item);
    // var temp = managementCubit.selectedWorking!;
    // await managementCubit.loadListWorkings();
    // await managementCubit.chooseWorkingUnit(temp);
  }

  endEvent() async {
    var temp = managementCubit.selectedWorking!;
    await managementCubit.loadListWorkings();
    await managementCubit.chooseWorkingUnit(temp);
  }
}
