import 'dart:math';

import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/features/home/main_tab/widgets/personal/task_preview.dart';
import 'package:whms/features/home/main_tab/widgets/task/menu_task_option.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/dropdown_scope.dart';
import 'package:whms/widgets/mouse_hover_popup.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

import 'history_card_task_widget.dart';

class PersonalTaskWidget extends StatelessWidget {
  const PersonalTaskWidget(
      {super.key,
      required this.work,
      required this.address,
      required this.subTask,
      this.showDetailTask,
      this.isInHrTab = false,
      this.isInTask = false,
      this.isToday = false,
      this.afterUpdateWorkInTask,
      this.assignees,
      this.isShowAssignees = false,
      this.scope,
      this.mousePos});

  final WorkingUnitModel work;
  final List<WorkingUnitModel>? address;
  final int subTask;
  final bool isInHrTab;
  final bool isToday;
  final bool isInTask;
  final Function()? showDetailTask;
  final Function(WorkingUnitModel)? afterUpdateWorkInTask;
  final UserModel? assignees;
  final bool isShowAssignees;
  final Offset? mousePos;

  final ScopeModel? scope;

  @override
  Widget build(BuildContext context) {
    final List<int> tableWeight =
        !isInHrTab ? [8, 4, 3, 3, 1, 1, 1, 3] : [10, 2, 2, 2, 1, 2, 2, 1];
    return InkWell(
      onTap: () {
        if (showDetailTask != null) {
          showDetailTask!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
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
            if (isInTask) const ZSpace(w: 12),
            Expanded(
                flex: tableWeight[0],
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(2.5, context)),
                  child: TaskPersonalGeneralView(
                    isToday: isToday,
                    work: work,
                    address: address,
                  ),
                )),
            if (isInTask)
              Expanded(
                  flex: tableWeight[7],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: ScaleUtils.scaleSize(22, context),
                              width: double.infinity,
                              child: ItemScopeWidget(
                                item: scope != null
                                    ? scope!
                                    : ScopeModel(
                                        title: AppText.titlePersonal.text),
                                fontSize: 12,
                                radius: 229,
                                isSelected: false,
                              ),
                            ),
                          )
                        ]),
                  )),
            Expanded(
                flex: tableWeight[1],
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(2.5, context)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [StatusCard(status: work.status)]),
                )),
            Expanded(
                flex: tableWeight[2],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PriorityViewWidget(work: work),
                  ],
                )),
            Expanded(
                flex: tableWeight[3],
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(2.5, context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DeadlineViewWidget(work: work),
                    ],
                  ),
                )),
            Expanded(
                flex: tableWeight[4],
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(2.5, context)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      UrgentViewWidget(work: work),
                    ],
                  ),
                )),
            if (isInHrTab)
              Expanded(
                  flex: tableWeight[6],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CardView(content: "${max(0, work.workingPoint)} điểm")
                      ],
                    ),
                  )),
            Expanded(
                flex: tableWeight[5],
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(2.5, context)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: ScaleUtils.scaleSize(26, context),
                            width: ScaleUtils.scaleSize(26, context),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: ScaleUtils.scaleSize(1, context),
                                    color: ColorConfig.border4)),
                            child: Text("$subTask",
                                style: TextStyle(
                                    fontSize: ScaleUtils.scaleSize(12, context),
                                    fontWeight: FontWeight.w500,
                                    color: ColorConfig.textColor)))
                      ]),
                )),
            if (isShowAssignees)
              Expanded(
                  flex: tableWeight[7],
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(assignees != null)
                          Tooltip(
                            message: assignees!.name,
                            child: AvatarItem(
                              assignees!.avt,
                              size: 20,
                            ),
                          )
                        ]),
                  )),
            if (isInTask)
              Expanded(
                  flex: tableWeight[6],
                  child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(2.5, context)),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          popupMenuTheme: PopupMenuThemeData(
                            color: Colors.white,
                            // Đổi màu nền của PopupMenu
                            textStyle: const TextStyle(
                              color: ColorConfig
                                  .textColor, // Đổi màu chữ của tất cả các mục
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(
                                  ScaleUtils.scaleSize(12, context))),
                              // Bo góc cho PopupMenu
                              side: BorderSide(
                                color: ColorConfig.border,
                                // Màu viền của PopupMenu
                                width: ScaleUtils.scaleSize(
                                    2, context), // Độ dày của viền
                              ),
                            ),
                          ),
                        ),
                        child: MenuTaskOption(
                            work: work,
                            afterUpdateAction: (v) {
                              if (afterUpdateWorkInTask != null) {
                                afterUpdateWorkInTask!(v);
                              }
                            }),
                      ))),
          ],
        ),
      ),
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
          color: PriorityLevelExtension.convertToPriority(work.priority)
              .background),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(6, context),
          vertical: ScaleUtils.scaleSize(3, context)),
      alignment: Alignment.center,
      child: Text(
        work.priority,
        style: TextStyle(
            fontSize: ScaleUtils.scaleSize(10, context),
            fontWeight: FontWeight.w500,
            color: PriorityLevelExtension.convertToPriority(work.priority)
                .color),
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
          decoration: BoxDecoration(
              color:
                  DateTimeUtils.getCurrentDate().isAfter(work.deadline.toDate())
                      ? Colors.black
                      : DateTime.now().isAfter(work.urgent.toDate())
                          ? ColorConfig.primary3
                          : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: [
                if (work.priority == PriorityLevelDefine.top.title)
                  const BoxShadow(
                      blurRadius: 4,
                      color: Color(0x1AB71C1C),
                      offset: Offset(0, 4))
              ]),
          child: Image.asset(
            'assets/images/icons/ic_epic.png',
            color: Colors.white,
            // DateTime.now().isAfter(work.urgent.toDate())
            //     ? 'assets/images/icons/ic_urgent_active.png'
            //     : 'assets/images/icons/ic_urgent_inactive.png',
            height: ScaleUtils.scaleSize(18, context),
          ),
        ),
      ],
    );
  }
}

class TaskPersonalGeneralView extends StatelessWidget {
  const TaskPersonalGeneralView({
    super.key,
    required this.work,
    required this.address,
    required this.isToday,
  });

  final WorkingUnitModel work;
  final List<WorkingUnitModel>? address;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          if (address != null)
            for (int i = address!.length - 1; i >= 0; i--)
              Row(children: [
                Tooltip(
                    message: address![i].title,
                    child: Text(address![i].type,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(11, context),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFA6A6A6)))),
                if (i > 0)
                  Text(" > ",
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(11, context),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFA6A6A6)))
              ])
        ]),
        SizedBox(height: ScaleUtils.scaleSize(2, context)),
        Row(
          children: [
            if (isToday)
              Image.asset('assets/images/icons/tab_bar/ic_tab_today.png',
                  height: ScaleUtils.scaleSize(12, context),
                  color: ColorConfig.primary3),
            if (isToday) SizedBox(width: ScaleUtils.scaleSize(3, context)),
            Expanded(
              child: MousePopup(
                width: 400,
                popupContent: TaskPreview(task: work, width: 400),
                child: Text(
                  work.title,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(14, context),
                      fontWeight: FontWeight.w500,
                      color:
                          isToday ? ColorConfig.primary3 : ColorConfig.textColor,
                      overflow: TextOverflow.ellipsis,
                      letterSpacing: -0.02),
                  maxLines: 3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
