import 'package:whms/features/home/hr/views/task_popup_view.dart';
import 'package:whms/features/home/overview/views/header_task_data.dart';
import 'package:whms/features/home/overview/widgets/card_task_data_widget.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/overview/blocs/overview_tab_cubit.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/multitab_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class OverviewDataTaskView extends StatelessWidget {
  const OverviewDataTaskView({super.key, required this.cubit});

  final OverviewTabCubit cubit;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [4, 6, 2, 2];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppText.titleListProject.text,
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(16, context),
              fontWeight: FontWeight.w500,
              color: ColorConfig.textColor6,
              shadows: const [ColorConfig.textShadow]),
        ),
        const ZSpace(h: 9),
        MultitabWidget(
            key: ValueKey(cubit.sprintSelected +
                cubit.scopeSelected +
                cubit.epicSelected),
            tabs: [
              if (cubit.sprintSelected.isEmpty) AppText.txtSprint.text,
              AppText.txtStory.text,
              AppText.txtTask.text
            ],
            tabSelected: cubit.tabTaskSelected,
            selectTab: (v) {
              cubit.changeTabTaskSelected(v);
            }),
        const ZSpace(h: 9),
        HeaderTaskData(weight: weight),
        const ZSpace(h: 9),
        if (cubit.sprintSelected.isNotEmpty &&
            cubit.mapWorkChild.containsKey(cubit.sprintSelected))
          ...cubit.mapWorkChild[cubit.sprintSelected]!
              .where((e) => e.type == cubit.tabTaskSelected)
              .map((item) => Column(
            children: [
              CardTaskDataWidget(
                  data: item,
                  children:
                  cubit.mapWorkChild[item.id]?.length ?? 0,
                  onShowDetails: () async {
                    DialogUtils.showLoadingDialog(context);
                    // await cubitHr.getDataUser(data.task.assignees);
                    await cubit.getDataTaskChildAndUser(item.id, item.assignees);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    DialogUtils.showAlertDialog(context,
                        child: TaskPopupView(
                            task: item,
                            subtasks: cubit.mapWorkChild[item.id] != null
                                ? cubit.mapWorkChild[item.id]!
                                : [],
                            assignees: item.assignees
                                .map((e) => cubit.mapUserModel[e])
                                .where((e) => e != null)
                                .cast<UserModel>()
                                .toList(),
                            listScopes: cubit.listScopeUser));
                  },
                  weight: weight),
              const ZSpace(h: 9)
            ],
          )),
        if (cubit.epicSelected.isNotEmpty &&
            cubit.sprintSelected.isEmpty &&
            cubit.mapWorkChild.containsKey(cubit.epicSelected))
          ...cubit.mapWorkChild[cubit.epicSelected]!
              .where((e) => e.type == cubit.tabTaskSelected)
              .map((item) => Column(
            children: [
              CardTaskDataWidget(
                  data: item,
                  children:
                  cubit.mapWorkChild[item.id]?.length ?? 0,
                  onShowDetails: () async {
                    DialogUtils.showLoadingDialog(context);
                    // await cubitHr.getDataUser(data.task.assignees);
                    await cubit.getDataTaskChildAndUser(item.id, item.assignees);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    DialogUtils.showAlertDialog(context,
                        child: TaskPopupView(
                            task: item,
                            subtasks: cubit.mapWorkChild[item.id] != null
                                ? cubit.mapWorkChild[item.id]!
                                : [],
                            assignees: item.assignees
                                .map((e) => cubit.mapUserModel[e])
                                .where((e) => e != null)
                                .cast<UserModel>()
                                .toList(),
                            listScopes: cubit.listScopeUser));
                  },
                  weight: weight),
              const ZSpace(h: 9)
            ],
          )),
        if (cubit.epicSelected.isEmpty &&
            cubit.sprintSelected.isEmpty &&
            cubit.mapWorkInScope.containsKey(cubit.scopeSelected))
          ...cubit.mapWorkInScope[cubit.scopeSelected]!
              .where((e) => e.type == cubit.tabTaskSelected)
              .map((item) => Column(
            children: [
              CardTaskDataWidget(
                  data: item,
                  children:
                  cubit.mapWorkChild[item.id]?.length ?? 0,
                  onShowDetails: () async {
                    DialogUtils.showLoadingDialog(context);
                    // await cubitHr.getDataUser(data.task.assignees);
                    await cubit.getDataTaskChildAndUser(item.id, item.assignees);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    DialogUtils.showAlertDialog(context,
                        child: TaskPopupView(
                            task: item,
                            subtasks: cubit.mapWorkChild[item.id] != null
                                ? cubit.mapWorkChild[item.id]!
                                : [],
                            assignees: item.assignees
                                .map((e) => cubit.mapUserModel[e])
                                .where((e) => e != null)
                                .cast<UserModel>()
                                .toList(),
                            listScopes: cubit.listScopeUser));
                  },
                  weight: weight),
              const ZSpace(h: 9)
            ],
          )),
        if (cubit.loadingDataTask > 0) const ZSpace(h: 9),
        if (cubit.loadingDataTask > 0)
          const Center(
            child: CircularProgressIndicator(
              color: ColorConfig.primary3,
            ),
          )
      ],
    );
  }
}