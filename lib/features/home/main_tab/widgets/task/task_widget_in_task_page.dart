import 'package:whms/features/home/main_tab/blocs/task_main_page_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/task_popup_view.dart';
import 'package:whms/features/home/main_tab/widgets/personal/personal_task_widget.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class TaskWidgetInTaskPage extends StatelessWidget {
  const TaskWidgetInTaskPage(
      {super.key,
      required this.cubitMT,
      required this.mapAddress,
      required this.numberOfSubtask,
      required this.mapScope,
      required this.getDataWorkChild,
      required this.mapWorkChild,
      required this.mapUser,
      required this.listScope,
      required this.cubit,
      required this.updateListTask,
      required this.item});

  final MainTabCubit cubitMT;
  final Map<String, List<WorkingUnitModel>> mapAddress;
  final Map<String, int> numberOfSubtask;
  final Map<String, ScopeModel> mapScope;
  final Function(String p1) getDataWorkChild;
  final Map<String, List<WorkingUnitModel>> mapWorkChild;
  final Map<String, UserModel> mapUser;
  final List<ScopeModel> listScope;
  final TaskMainPageCubit cubit;
  final Function(WorkingUnitModel p1) updateListTask;
  final WorkingUnitModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(25, context)),
      padding: EdgeInsets.symmetric(vertical: ScaleUtils.scaleSize(4, context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PersonalTaskWidget(
            isToday: cubitMT.listToday.any((e) => e.id == item.id),
            work: item,
            address: mapAddress[item.id] ?? [],
            subTask: numberOfSubtask[item.id] ?? 0,
            scope: item.scopes.isNotEmpty
                ? (mapScope[item.scopes.first] ??
                    ScopeModel(title: AppText.titlePersonal.text))
                : ScopeModel(title: AppText.titlePersonal.text),
            showDetailTask: () async {
              DialogUtils.showLoadingDialog(context);
              // await cubitHr.getDataUser(data.task.assignees);
              await getDataWorkChild(item.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
              DialogUtils.showAlertDialog(context,
                  child: TaskPopupView(
                      task: item,
                      subtasks: mapWorkChild[item.id] != null
                          ? mapWorkChild[item.id]!
                          : [],
                      assignees: item.assignees
                          .map((e) => mapUser[e])
                          .where((e) => e != null)
                          .cast<UserModel>()
                          .toList(),
                      listScopes: listScope));
            },
            isInTask: true,
            afterUpdateWorkInTask: (v) {
              cubit.updateTask(v);
              updateListTask(v);
            },
          ),
          // const ZSpace(h: 5)
        ],
      ),
    );
  }
}
