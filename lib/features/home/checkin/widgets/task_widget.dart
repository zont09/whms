import 'dart:math';

import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/features/home/checkin/widgets/custom_check_box.dart';
import 'package:whms/features/home/checkin/widgets/history_card_widget.dart';
import 'package:whms/features/home/checkin/widgets/priority_working_unit_circle.dart';
import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/features/home/checkin/widgets/task_general_view.dart';
import 'package:whms/features/manager/widgets/list_status_dropdown.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/working_time_field.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget(
      {super.key,
      required this.work,
      required this.cubit,
      required this.isSelected,
      required this.onChangedWorkingTime,
      required this.onChangeStatus,
      required this.removeWork,
      required this.mapAddress,
      required this.mapScope,
      required this.workPar,
      this.cubitCO,
      this.workingTime = 10,
      this.isAddTask = true});

  final WorkingUnitModel work;
  final String workPar;
  final SelectWorkCubit cubit;
  final CheckOutCubit? cubitCO;
  final Map<String, List<WorkingUnitModel>> mapAddress;
  final Map<String, ScopeModel> mapScope;
  final Function(WorkingUnitModel) removeWork;
  final Function(int) onChangedWorkingTime;
  final Function(int) onChangeStatus;
  final bool isSelected;
  final bool isAddTask;
  final int workingTime;

  @override
  Widget build(BuildContext context) {
    final List<int> tableWeight = [1, 6, 2, 2, 2, 1, 1, 2];
    final isCheckedIn = ConfigsCubit.fromContext(context).isCheckIn ==
        StatusCheckInDefine.checkIn;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              offset: Offset(1, 1),
              blurRadius: 5.9,
              spreadRadius: 0,
            )
          ]),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(12, context),
          vertical: ScaleUtils.scaleSize(6, context)),
      child: Row(
        children: [
          if (isAddTask)
            Expanded(
                flex: tableWeight[0],
                child: CheckBoxViewWidget(
                    isSelected: isSelected,
                    cubitCO: cubitCO,
                    cubit: cubit,
                    work: work)),
          if (isAddTask || isCheckedIn)
            SizedBox(width: ScaleUtils.scaleSize(5, context)),
          Expanded(
              flex: tableWeight[1],
              child: TaskGeneralView(
                mapScope: mapScope,
                work: work,
                mapAddress: mapAddress,
              )),
          if (cubitCO == null)
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if (cubitCO == null)
          Expanded(
              flex: tableWeight[2],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CardView(
                      content: DateTimeUtils.formatDateDayMonthYear(
                          work.deadline.toDate())),
                ],
              )),
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if (isAddTask || !isCheckedIn)
            Expanded(
                flex: tableWeight[3],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [StatusCard(status: work.status)],
                )),
          if (!isAddTask && isCheckedIn)
            Expanded(
                flex: tableWeight[3],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: ListStatusDropdown(
                        isPermission: true,
                        size: 8,
                        height: 21,
                        paddingHor: 6,
                        iconSize: 16,
                        maxWidth: 100,
                        selector: work.status,
                        typeOption: work.owner.isEmpty ? 2 : 1,
                        onChanged: (value) {
                          onChangeStatus(value!);
                        },
                        // onChangedProgress: (value) {
                        //   onChangeStatus((work.status ~/ 100) * 100 + value);
                        // },
                      ),
                    ),
                  ],
                )),
          if (cubitCO == null)
            SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if (cubitCO == null)
            Expanded(
                flex: tableWeight[5],
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  PriorityWorkingUnitCircle(
                      priority: PriorityLevelExtension.convertToPriority(
                          work.priority),
                      size: 20),
                ])),
          if (cubitCO == null)
          SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if (cubitCO == null)
          Expanded(
              flex: tableWeight[4],
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                CardView(content: "${max(0, work.workingPoint)} điểm")
                // if (!isAddTask)
                //   // ListWorkingPointDropdown(selector: 10, onChanged: (v) {}),
                //   WorkingTimeDropdown(
                //       maxWidth: 100,
                //       onChanged: (v) async {
                //         DialogUtils.showLoadingDialog(context);
                //         await WorkingService.instance
                //             .updateWorkingUnit(work.copyWith(duration: v));
                //         if (context.mounted) {
                //           Navigator.of(context).pop();
                //         }
                //       },
                //       initTime: work.duration,
                //       isAddTask: isAddTask,
                //       isEdit: true),
                // if (isAddTask) TimeCard(time: work.duration.toString())
              ])),
          if (!isAddTask && cubitCO != null)
            SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if (!isAddTask && cubitCO != null)
            Expanded(
                flex: tableWeight[7],
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center, children: [
                      WorkingTimeField(initTime: workingTime, onChange: (v) {
                        onChangedWorkingTime(v);
                      })
                ])),
          if (!isAddTask) SizedBox(width: ScaleUtils.scaleSize(5, context)),
          if (!isAddTask)
            Expanded(
                flex: tableWeight[5],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        removeWork(work);
                      },
                      child: Image.asset('assets/images/icons/ic_trash.png',
                          height: ScaleUtils.scaleSize(16, context)),
                    )
                  ],
                )),
        ],
      ),
    );
  }
}

class CheckBoxViewWidget extends StatelessWidget {
  const CheckBoxViewWidget({
    super.key,
    required this.isSelected,
    required this.cubitCO,
    required this.cubit,
    required this.work,
  });

  final bool isSelected;
  final CheckOutCubit? cubitCO;
  final SelectWorkCubit cubit;
  final WorkingUnitModel work;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomCheckBox(
            isActive: isSelected,
            onTap: () {
              if (isSelected) {
                if (cubitCO == null) {
                  cubit.removeWork(work);
                } else {
                  cubitCO!.removeWorkCheckOut(work);
                }
              } else {
                if (cubitCO == null) {
                  cubit.selectedWork(work);
                } else {
                  cubitCO!.selectWorkCheckOut(work);
                }
              }
            }),
      ],
    );
  }
}

class PriorityViewWidget extends StatelessWidget {
  const PriorityViewWidget({
    super.key,
    required this.work,
  });

  final WorkingUnitModel work;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(20, context)),
          color: const Color(0xFFEEECFC)),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(6, context),
          vertical: ScaleUtils.scaleSize(3, context)),
      alignment: Alignment.center,
      child: Text(
        work.priority,
        style: TextStyle(
            fontSize: ScaleUtils.scaleSize(10, context),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4A24FF)),
      ),
    );
  }
}

class DeadlineViewWidget extends StatelessWidget {
  const DeadlineViewWidget({
    super.key,
    required this.work,
  });

  final WorkingUnitModel work;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(20, context)),
              border: Border.all(
                  width: ScaleUtils.scaleSize(1, context),
                  color: ColorConfig.border4),
              color: Colors.white),
          padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(6, context),
              vertical: ScaleUtils.scaleSize(3, context)),
          child: Text(
            DateTimeUtils.convertTimestampToDateString(work.deadline),
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(10, context),
                fontWeight: FontWeight.w500,
                color: ColorConfig.textColor),
          ),
        ),
      ],
    );
  }
}

class UrgentViewWidget extends StatelessWidget {
  const UrgentViewWidget({
    super.key,
    required this.work,
  });

  final WorkingUnitModel work;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
            if (work.priority == PriorityLevelDefine.top.title)
              const BoxShadow(
                  blurRadius: 4, color: Color(0x1AB71C1C), offset: Offset(0, 4))
          ]),
          child: Image.asset(
            work.priority == PriorityLevelDefine.top.title
                ? 'assets/images/icons/ic_urgent_active.png'
                : 'assets/images/icons/ic_urgent_inactive.png',
            height: ScaleUtils.scaleSize(18, context),
          ),
        ),
      ],
    );
  }
}


