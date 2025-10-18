import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/features/home/hr/widget/expand_card_data_hr_subtask_widget.dart';
import 'package:whms/features/home/main_tab/blocs/work_history_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/personal/task_preview.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:whms/widgets/mouse_hover_popup.dart';

import '../../main_tab/widgets/personal/history_card_task_widget.dart';

class CardDataHrTaskWidget extends StatefulWidget {
  const CardDataHrTaskWidget(
      {super.key,
      required this.weight,
      required this.task,
      required this.subTask,
      this.showDetailTask});

  final List<int> weight;
  final WorkHistorySynthetic task;
  final List<WorkHistorySynthetic> subTask;
  final Function()? showDetailTask;

  @override
  State<CardDataHrTaskWidget> createState() => _CardDataHrTaskWidgetState();
}

class _CardDataHrTaskWidgetState extends State<CardDataHrTaskWidget> {
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    return MousePopup(
      width: 400,
      popupContent: TaskPreview(task: widget.task.work, width: 400),
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
            border: Border.all(
                width: ScaleUtils.scaleSize(1, context),
                color: ColorConfig.border8),
            color: Colors.white,
            boxShadow: const [ColorConfig.boxShadow2]),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(16, context),
            vertical: ScaleUtils.scaleSize(12, context)),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                if (widget.showDetailTask != null) {
                  widget.showDetailTask!();
                }
              },
              child: Row(
                children: [
                  Expanded(
                      flex: widget.weight[0],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.task.work.title,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(14, context),
                                  fontWeight: FontWeight.w500,
                                  color: ColorConfig.textColor,
                                  letterSpacing: -0.02,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          )
                        ],
                      )),
                  Expanded(
                      flex: widget.weight[1],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CardView(content: "${widget.task.workingPoint} điểm"),
                        ],
                      )),
                  Expanded(
                      flex: widget.weight[2],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CardView(
                              content: DateTimeUtils.formatDuration(
                                  widget.task.workingTime)),
                        ],
                      )),
                  Expanded(
                      flex: widget.weight[3],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.task.fromStatus == -2209)
                            const CardView(content: ""),
                          if (widget.task.fromStatus != -2209)
                            StatusCard(status: widget.task.fromStatus),
                        ],
                      )),
                  Expanded(
                      flex: widget.weight[4],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.task.toStatus == -2209)
                            const CardView(content: ""),
                          if (widget.task.toStatus != -2209)
                            StatusCard(status: widget.task.toStatus),
                        ],
                      )),
                  Expanded(
                      flex: widget.weight[5],
                      child: widget.subTask.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  isExpand = !isExpand;
                                });
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  isExpand
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: ScaleUtils.scaleSize(20, context),
                                  color: const Color(0xFF646464),
                                ),
                              ),
                            )
                          : Container()),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 229),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: 0.0,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: isExpand
                  ? ExpandCardDataHrSubtaskWidget(
                      weight: widget.weight, listData: widget.subTask)
                  : const SizedBox.shrink(
                      key: ValueKey<bool>(false),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class CardHRModel {
  final DateTime date;
  final String dateStr;
  final int logtime;
  final int workingTime;
  final int taskDone;
  final int taskDoing;
  final int taskOther;
  final int workingPoint;
  final List<WorkingUnitModel> assignees;
  final List<HrTaskModel> details;

  // Constructor không cần tham số đầu vào, khởi tạo với giá trị mặc định
  CardHRModel({
    DateTime? date,
    String? dateStr,
    int? logtime,
    int? workingTime,
    int? taskDone,
    int? taskDoing,
    int? taskOther,
    int? workingPoint,
    List<WorkingUnitModel>? assignees,
    List<HrTaskModel>? details,
  })  : date = date ?? DateTime.now(),
        dateStr = dateStr ?? '',
        logtime = logtime ?? 0,
        workingTime = workingTime ?? 0,
        taskDone = taskDone ?? 0,
        taskDoing = taskDoing ?? 0,
        taskOther = taskOther ?? 0,
        workingPoint = workingPoint ?? 0,
        assignees = assignees ?? [],
        details = details ?? [];

  // copyWith method
  CardHRModel copyWith({
    DateTime? date,
    String? dateStr,
    int? logtime,
    int? workingTime,
    int? taskDone,
    int? taskDoing,
    int? taskOther,
    int? workingPoint,
    List<WorkingUnitModel>? assignees,
    List<HrTaskModel>? details,
  }) {
    return CardHRModel(
      date: date ?? this.date,
      dateStr: dateStr ?? this.dateStr,
      logtime: logtime ?? this.logtime,
      workingTime: workingTime ?? this.workingTime,
      taskDone: taskDone ?? this.taskDone,
      taskDoing: taskDoing ?? this.taskDoing,
      taskOther: taskOther ?? this.taskOther,
      workingPoint: workingPoint ?? this.workingPoint,
      assignees: assignees ?? List.from(this.assignees),
      details:
          details ?? List.from(this.details), // Clone list to avoid mutation
    );
  }
}

class HrTaskModel {
  final WorkingUnitModel task;
  final List<UserModel> users;
  final int workingTime;
  final int status;
  final int workingPoint;

  // Constructor không tham số với giá trị mặc định
  HrTaskModel({
    WorkingUnitModel? task,
    List<UserModel>? users,
    int? workingTime,
    int? status,
    int? workingPoint,
  })  : task = task ?? WorkingUnitModel(),
        workingTime = workingTime ?? 0,
        users = users ?? [],
        status = status ?? 0,
        workingPoint = workingPoint ?? 0;

  // Phương thức copyWith
  HrTaskModel copyWith(
      {WorkingUnitModel? task,
      int? workingTime,
      List<UserModel>? users,
      int? status,
      int? workingPoint}) {
    return HrTaskModel(
      task: task ?? this.task,
      workingTime: workingTime ?? this.workingTime,
      users: users ?? this.users,
      status: status ?? this.status,
      workingPoint: workingPoint ?? this.workingPoint,
    );
  }

  @override
  String toString() {
    return 'HrTaskModel(task: $task, workingTime: $workingTime)';
  }
}
