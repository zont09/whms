import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/features/home/main_tab/views/task/task_popup_view.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class DetailTaskInDayWidget extends StatelessWidget {
  const DetailTaskInDayWidget({super.key, required this.tasks});

  final List<WorkingUnitModel> tasks;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: ScaleUtils.scaleSize(6, context),
              horizontal: ScaleUtils.scaleSize(10, context)),
          child: Column(
            children: [
              ...tasks.map((e) => CalendarTaskWidget(task: e))
            ],
          ),
        )));
  }
}

class CalendarTaskWidget extends StatelessWidget {
  const CalendarTaskWidget({super.key, required this.task});

  final WorkingUnitModel task;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    return InkWell(
      onTap: () {
        DialogUtils.showAlertDialog(context, child: TaskPopupView(
            task: task,
            subtasks: cfC.allWorkingUnit.where((e) => e.parent == task.id).toList(),
            assignees: task.assignees
                .map((e) => cfC.usersMap[e])
                .where((e) => e != null)
                .cast<UserModel>()
                .toList(),
            listScopes: cfC.allScopes));
      },
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
            color: PriorityLevelExtension.convertToPriority(task.priority).color,
          ),
          padding: EdgeInsets.all(ScaleUtils.scaleSize(6, context)),
          margin:
              EdgeInsets.symmetric(vertical: ScaleUtils.scaleSize(3, context)),
          child: Text(
            task.title,
            style: TextStyle(
                color: Colors.white,
                fontSize: ScaleUtils.scaleSize(14, context),
                fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )),
    );
  }
}
