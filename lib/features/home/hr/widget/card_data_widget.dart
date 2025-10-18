import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whms/features/home/hr/widget/expand_card_data_hr_widget.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

import '../../main_tab/widgets/personal/history_card_task_widget.dart';

class CardDataWidget extends StatefulWidget {
  const CardDataWidget({super.key,
    required this.weight,
    required this.data,
    this.isPersonal = false});

  final List<int> weight;
  final CardHRModel data;
  final bool isPersonal;

  @override
  State<CardDataWidget> createState() => _CardDataWidgetState();
}

class _CardDataWidgetState extends State<CardDataWidget> {
  bool isExpand = false;
  String icon = "success";
  String messageStatus = AppText.textDoItFully.text;

  @override
  Widget build(BuildContext context) {
    switch (widget.data.statusCheckIn) {
      case 0: icon = "success"; messageStatus = AppText.textDoItFully.text; break;
      case 1: icon = "off"; messageStatus = AppText.textBreakFromWork.text; break;
      case 2: icon = "fail"; messageStatus = AppText.textNotPay.text; break;
      case 3: icon = "doing_status"; messageStatus = AppText.titleDoing.text; break;
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
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
              if(widget.data.details.isNotEmpty)
              setState(() {
                isExpand = !isExpand;
              });
            },
            child: Row(
              children: [
                if(widget.isPersonal)
                  Expanded(
                      flex: widget.weight[8],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                            message: messageStatus,
                            child: Image.asset(
                              "assets/images/icons/ic_${icon}.png",
                              height: ScaleUtils.scaleSize(20, context),),
                          )
                        ],
                      )),
                Expanded(
                    flex: widget.weight[0],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              "${DateTimeUtils.getWeekday(
                                  widget.data.date)}, ${widget.data.dateStr}",
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(14, context),
                                  fontWeight: FontWeight.w500,
                                  color: ColorConfig.textColor,
                                  letterSpacing: -0.02,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        )
                      ],
                    )),
                Expanded(
                    flex: widget.weight[1],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardView(
                            content: DateTimeUtils.formatDuration(
                                widget.data.logtime)),
                      ],
                    )),
                Expanded(
                    flex: widget.weight[2],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardView(
                            content: DateTimeUtils.formatDuration(
                                widget.data.workingTime)),
                      ],
                    )),
                Expanded(
                    flex: widget.weight[3],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardView(
                            content: "${widget.data.taskOther} nhiệm vụ"),
                      ],
                    )),
                Expanded(
                    flex: widget.weight[4],
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(2.5, context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CardView(
                              content: "${widget.data.workingPoint} điểm"),
                        ],
                      ),
                    )),
                if (widget.isPersonal)
                  Expanded(
                      flex: widget.weight[6],
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScaleUtils.scaleSize(2.5, context)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CardView(
                                content: widget.data.statusCheckIn == 1
                                    ? ""
                                    : DateTimeUtils.convertTimestampToTime(
                                    widget.data.checkIn)),
                          ],
                        ),
                      )),
                if (widget.isPersonal)
                  Expanded(
                      flex: widget.weight[7],
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScaleUtils.scaleSize(2.5, context)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CardView(
                                content: widget.data.statusCheckIn != 0
                                    ? ""
                                    : DateTimeUtils.convertTimestampToTime(
                                    widget.data.checkOut)),
                          ],
                        ),
                      )),
                Expanded(
                    flex: widget.weight[5],
                    child: widget.data.details.isNotEmpty
                        ? Align(
                      alignment: Alignment.center,
                      child: Icon(
                        isExpand
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: ScaleUtils.scaleSize(20, context),
                        color: const Color(0xFF646464),
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
                ? ExpandCardDataHrWidget(
                weight: widget.weight, listData: widget.data.details)
                : const SizedBox.shrink(
              key: ValueKey<bool>(false),
            ),
          )
        ],
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
  final Timestamp checkIn;
  final Timestamp checkOut;
  final List<WorkingUnitModel> assignees;
  final List<HrTaskModel> details;
  final int statusCheckIn;

  // 0 - checkout
  // 1 - nghi lam
  // 2 - quen checkout
  // 3 - dang lam

  CardHRModel({
    DateTime? date,
    String? dateStr,
    int? logtime,
    int? workingTime,
    int? taskDone,
    int? taskDoing,
    int? taskOther,
    int? workingPoint,
    Timestamp? checkIn,
    Timestamp? checkOut,
    List<WorkingUnitModel>? assignees,
    List<HrTaskModel>? details,
    int? statusCheckIn,
  })
      : date = date ?? DateTime.now(),
        dateStr = dateStr ?? '',
        logtime = logtime ?? 0,
        workingTime = workingTime ?? 0,
        taskDone = taskDone ?? 0,
        taskDoing = taskDoing ?? 0,
        taskOther = taskOther ?? 0,
        workingPoint = workingPoint ?? 0,
        checkIn = checkIn ?? Timestamp.now(),
        checkOut = checkOut ?? Timestamp.now(),
        assignees = assignees ?? [],
        details = details ?? [],
        statusCheckIn = statusCheckIn ?? 0;

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
    Timestamp? checkIn,
    Timestamp? checkOut,
    List<WorkingUnitModel>? assignees,
    List<HrTaskModel>? details,
    int? statusCheckIn,
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
        checkIn: checkIn ?? this.checkIn,
        checkOut: checkOut ?? this.checkOut,
        assignees: assignees ?? List.from(this.assignees),
        details: details ?? List.from(this.details),
        statusCheckIn: statusCheckIn ?? this.statusCheckIn);
  }
}

class HrTaskModel {
  final WorkingUnitModel task;
  final List<UserModel> users;
  final int workingTime;
  final int status;
  final int workingPoint;
  final int statusCheckIn;

  // Constructor không tham số với giá trị mặc định
  HrTaskModel({
    WorkingUnitModel? task,
    List<UserModel>? users,
    int? workingTime,
    int? status,
    int? workingPoint,
    int? statusCheckIn,
  })
      : task = task ?? WorkingUnitModel(),
        workingTime = workingTime ?? 0,
        users = users ?? [],
        status = status ?? 0,
        workingPoint = workingPoint ?? 0,
        statusCheckIn = statusCheckIn ?? 0;

  // Phương thức copyWith
  HrTaskModel copyWith({WorkingUnitModel? task,
    int? workingTime,
    List<UserModel>? users,
    int? status,
    int? workingPoint,
    int? statusCheckIn}) {
    return HrTaskModel(
      task: task ?? this.task,
      workingTime: workingTime ?? this.workingTime,
      users: users ?? this.users,
      status: status ?? this.status,
      workingPoint: workingPoint ?? this.workingPoint,
      statusCheckIn: statusCheckIn ?? this.statusCheckIn,
    );
  }

  @override
  String toString() {
    return 'HrTaskModel(task: $task, workingTime: $workingTime)';
  }
}
