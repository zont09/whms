import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/assignment_tabbar_view.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/list_assignment_header.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/list_assignment_tabbar.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/features/home/manager_tab/bloc/management_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/create_assignment_popup.dart';
import 'package:whms/features/home/manager_tab/widget/manager_tab/management_assignment_item.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/add_button.dart';
import 'package:whms/widgets/reorder_able_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListAssignmentView extends StatelessWidget {
  const ListAssignmentView({super.key});

  @override
  Widget build(BuildContext context) {
    var managementCubit = BlocProvider.of<ManagementCubit>(context);
    return Padding(
        padding:
        EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(20, context)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: ScaleUtils.scaleSize(10, context)),
          // if (managementCubit.selectedWorking!.type !=
          //     TypeAssignmentDefine.task.title)
          Text(AppText.txtListChildWorkingUnit.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: ScaleUtils.scaleSize(-0.33, context),
                  color: ColorConfig.textColor)),
          managementCubit.selectedWorking!.tabs.isNotEmpty
              ? Column(children: [
            ListAssignmentTabBar(
                tabs: managementCubit.selectedWorking!.tabs,
                managementCubit: managementCubit),
            if ((managementCubit.tab == 0 &&
                managementCubit.tabX.isNotEmpty) ||
                (managementCubit.tab == 1 &&
                    managementCubit.tabY.isNotEmpty) ||
                (managementCubit.tab == 2 &&
                    managementCubit.tabZ.isNotEmpty))
              ListAssignmentHeader(managementCubit.tab),
            AssignmentTabBarView(managementCubit)
          ])
              : Column(children: [
            if (managementCubit.tab == 2 &&
                managementCubit.tabZ.isNotEmpty)
              ListAssignmentHeader(managementCubit.tab),
            if (managementCubit.tabS.isNotEmpty)
              const ListAssignmentHeader(4),
            ReorderAbleWidget(
                changeOrder: (a, b) => managementCubit.changeOrder(a, b),
                children: [
                  ...managementCubit.tabS.map((e) =>
                      ManagementAssignmentItem(e,
                          key: Key(e.id),
                          choose: () async =>
                          await managementCubit.chooseWorkingUnit(e),
                          endEvent: () async {
                            var temp = managementCubit.selectedWorking!;
                            await managementCubit.loadListWorkings();
                            await managementCubit.chooseWorkingUnit(temp);
                          },
                          reload: (v) async {},
                          address: managementCubit.link,
                          typeAssignment: 1000))
                ])
          ]),
          if ((managementCubit.tab == 0 && managementCubit.tabX.isNotEmpty) ||
              (managementCubit.tab == 1 && managementCubit.tabY.isNotEmpty) ||
              (managementCubit.tab == 2 && managementCubit.tabZ.isNotEmpty))
            Align(
                alignment: Alignment.centerRight,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  AddButton(
                      AppText.btnCreateAssignment.text.replaceAll(
                          '@',
                          managementCubit.listTabs[managementCubit.tab]
                              .toLowerCase()),
                      isFirstIcon: true, onTap: () async {
                    if (context.mounted) {
                      DialogUtils.showAlertDialog(context,
                          child: CreateAssignmentPopup(
                              ancestries: managementCubit.ancestries,
                              typeAssignment: managementCubit.tab + 5,
                              reload: (v) async {
                                // Stream listener sẽ tự động cập nhật UI
                                // Không cần gọi buildUI() ở đây để tránh duplicate
                              },
                              isSub: true,
                              scopes: [managementCubit.selectedScope!.id],
                              userId: managementCubit.handlerUser.id,
                              selectedWorking: managementCubit.selectedWorking!,
                              assignees:
                              managementCubit.selectedWorking!.assignees));
                    }
                  })
                ])),
          SizedBox(height: ScaleUtils.scaleSize(10, context))
        ]));
  }
}