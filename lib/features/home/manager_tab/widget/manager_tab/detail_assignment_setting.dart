import 'package:whms/features/home/manager_tab/widget/manager_tab/list_status_dropdown.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/detail_assignment_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/task/choose_datetime_item.dart';
import 'package:whms/features/home/main_tab/widgets/task/list_priority_dropdown.dart';
import 'package:whms/features/home/main_tab/widgets/task/list_working_point_dropdown.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:flutter/material.dart';

class DetailAssignmentSetting extends StatelessWidget {
  final bool isHandlerEdit;
  final bool isOwnerEdit;
  final DetailAssignCubit cubit;
  final Function(WorkingUnitModel, WorkingUnitModel)? onUpdate;

  const DetailAssignmentSetting(
      {required this.cubit,
      required this.isHandlerEdit,
      required this.isOwnerEdit,
        this.onUpdate,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: ScaleUtils.scaleSize(5, context),
        runSpacing: ScaleUtils.scaleSize(5, context),
        children: [
          if (cubit.wu.type == TypeAssignmentDefine.epic.title ||
              cubit.wu.type == TypeAssignmentDefine.sprint.title ||
              cubit.wu.type == TypeAssignmentDefine.story.title)
            InkWell(
                onTap: () => ToastUtils.showBottomToast(
                    context, AppText.toastNotEditStatus.text),
                child: Container(
                    height: ScaleUtils.scaleSize(32, context),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(20, context)),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: cubit.wu.percent <= 0
                                ? ColorConfig.statusPendingText
                                : cubit.wu.percent == 100
                                    ? ColorConfig.statusCompletedText
                                    : ColorConfig.statusProcessingText,
                            width: ScaleUtils.scaleSize(1, context)),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x26000000),
                              offset: Offset(1, 1),
                              blurRadius: 5.9,
                              spreadRadius: 0)
                        ],
                        color: cubit.wu.percent <= 0
                            ? ColorConfig.statusPendingBG
                            : cubit.wu.percent == 100
                                ? ColorConfig.statusCompletedBG
                                : ColorConfig.statusProcessingBG,
                        borderRadius: BorderRadius.circular(
                            ScaleUtils.scaleSize(1000, context))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                          '${AppText.titleProgress.text} ${cubit.wu.percent < 0 ? 0 : cubit.wu.percent}%',
                          style: TextStyle(
                              fontSize: ScaleUtils.scaleSize(12, context),
                              fontWeight: FontWeight.w500,
                              color: cubit.wu.percent <= 0
                                  ? ColorConfig.statusPendingText
                                  : cubit.wu.percent == 100
                                      ? ColorConfig.statusCompletedText
                                      : ColorConfig.statusProcessingText))
                    ]))),
          if (cubit.wu.type == TypeAssignmentDefine.task.title ||
              cubit.wu.type == TypeAssignmentDefine.subtask.title)
            ListStatusDropdown(
                isPermission: false,
                maxWidth: 130,
                selector: cubit.wu.status,
                onChanged: (v) async {
                  await cubit.updateStatus(v!);
                }),
          if (cubit.wu.type == TypeAssignmentDefine.task.title)
            ListPriorityDropdown(
                isEdit: isOwnerEdit,
                selector:
                    PriorityLevelExtension.convertToPriority(cubit.wu.priority),
                onChanged: (v) async {
                  await cubit.updatePriority(v!.title);
                }),
          if (cubit.wu.type != TypeAssignmentDefine.epic.title)
            Row(mainAxisSize: MainAxisSize.min, children: [
              ChooseDatetimeItem(
                  isEdit: isHandlerEdit,
                  icon: 'assets/images/icons/ic_calendar3.png',
                  onTap: (v) async {
                    await cubit.updateDeadline(v);
                  },
                  controller: TextEditingController(
                      text: DateTimeUtils.convertTimestampToDateString(
                          cubit.wu.deadline)),
                  initialStart: DateTimeUtils.convertToDateTime(
                      DateTimeUtils.convertTimestampToDateString(
                          cubit.wu.start)))
            ]),
          if (cubit.wu.type == TypeAssignmentDefine.task.title)
            Row(mainAxisSize: MainAxisSize.min, children: [
              ChooseDatetimeItem(
                  isEdit: isHandlerEdit,
                  onTap: (v) async {
                    await cubit.updateUrgent(v, context);
                  },
                  controller: TextEditingController(
                      text: DateTimeUtils.convertTimestampToDateString(
                          cubit.wu.urgent)),
                  initialStart: DateTimeUtils.convertToDateTime(
                      DateTimeUtils.convertTimestampToDateString(
                          cubit.wu.start)))
            ]),
          if (cubit.wu.type == TypeAssignmentDefine.task.title ||
              cubit.wu.type == TypeAssignmentDefine.subtask.title)
            ListWorkingPointDropdown(
                isEdit: isOwnerEdit,
                selector: cubit.wu.workingPoint,
                onChanged: (v) async {
                  await cubit.updateWP(v!);
                }),
        ]);
  }
}
