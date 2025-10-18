import 'package:whms/features/home/hr/views/personal_hr_view.dart';
import 'package:whms/features/home/hr/widget/dropdown_project.dart';
import 'package:whms/features/home/hr/widget/dropdown_user.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/hr/bloc/hr_tab_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/personal/header_personal_task_widget.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_String.dart';
import 'package:whms/widgets/multitab_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class TaskInHrMainView extends StatelessWidget {
  const TaskInHrMainView({super.key, required this.cubit});

  final HrTabCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: MultitabWidget(
                        fontSize: 14,
                          tabs: [
                            AppText.titleOverview.text,
                            AppText.titleTask.text,
                          ],
                          tabSelected: !cubit.isInTaskHr
                              ? AppText.titleOverview.text
                              : AppText.titleTask.text,
                          selectTab: (v) {
                            cubit.changeHrTaskView(!cubit.isInTaskHr);
                          })),
                  DropdownString(
                      radius: 8,
                      maxWidth: 90,
                      onChanged: (v) {
                        cubit.changeFilterAssignTV(v!);
                      },
                      initItem: cubit.filterAssignTV,
                      options: [
                        AppText.textAll.text,
                        AppText.textByAssign.text,
                        AppText.textByUnassign.text,
                      ]),
                  const ZSpace(w: 8),
                  DropdownString(
                      radius: 8,
                      maxWidth: 90,
                      onChanged: (v) {
                        cubit.changeFilterStatusTV(v!);
                      },
                      initItem: cubit.filterStatusTV,
                      options: [
                        AppText.textAll.text,
                        AppText.textNeedToDo.text,
                        AppText.titleDoing.text,
                        AppText.textDone.text,
                        AppText.textNone.text
                      ]),
                  const ZSpace(w: 8),
                  DropdownString(
                      radius: 8,
                      maxWidth: 90,
                      onChanged: (v) {
                        cubit.changeFilterClosedTV(v!);
                      },
                      initItem: cubit.filterClosedTV,
                      options: [
                        AppText.textAll.text,
                        AppText.textOpened.text,
                        AppText.textClosed.text,
                      ]),
                  const ZSpace(w: 8),
                  DropdownString(
                      radius: 8,
                      maxWidth: 90,
                      onChanged: (v) {
                        cubit.changeFilterDeadlineTV(v!);
                      },
                      initItem: cubit.filterDeadlineTV,
                      options: [
                        AppText.textAll.text,
                        AppText.textThisWeek.text,
                        AppText.textNextWeek.text,
                        AppText.text2Week.text,
                        AppText.text3Week.text,
                        AppText.text4Week.text,
                        AppText.text5Week.text,
                        AppText.text6Week.text,
                        AppText.text7Week.text,
                        AppText.text8Week.text,
                        AppText.text9Week.text,
                        AppText.text10Week.text,
                        AppText.text11Week.text,
                        AppText.text12Week.text,
                        AppText.textThisMonth.text,
                        AppText.textNextMonth.text,
                      ]),
                  const ZSpace(w: 8),
                  if (cubit.mapEpicInScope.containsKey(cubit.scopeSelected))
                    DropdownProject(
                        radius: 8,
                        maxWidth: 150,
                        key: ValueKey(cubit.scopeSelected),
                        onChanged: (v) {
                          cubit.changeFilterEpicTV(v!);
                        },
                        initTime: cubit.filterEpicTV,
                        options: [
                          cubit.allEpic,
                          ...cubit.mapEpicInScope[cubit.scopeSelected] ?? []
                        ]),
                  const ZSpace(w: 8),
                  DropdownUser(
                    maxWidth: 150,
                      maxHeight: 25,
                      onChanged: (v) {
                        cubit.changeFilterUserTV(v!);
                      },
                      initItem: cubit.filterUserTV,
                      options: [
                        cubit.userAll,
                        ...cubit.mapUserInScope[cubit.scopeSelected] ?? []
                      ])
                ],
              ),
              const ZSpace(h: 10),
              HeaderPersonalTaskWidget(
                isInHrTab: true,
                isClickToDeadline: () {
                  cubit.changeSortDeadline(!cubit.isSortDeadline);
                },
                isClickToAssignees: () {
                  cubit.changeSortAssignees(!cubit.isSortAssignees);
                },
              ),
              const ZSpace(h: 9),
              if (cubit.loadingTaskView == 0)
                ...cubit.mapDataTaskScopeGroup.entries
                    .map((item) => PersonalHrView(item: item, cubit: cubit, assignees: cubit.mapUserModel, isShowAssignees: true,)),
              if (cubit.loadingTaskView > 0)
                Center(
                  child: CircularProgressIndicator(
                    color: ColorConfig.primary3,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
