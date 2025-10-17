import 'package:whms/features/home/main_tab/views/task/create_sub_task/create_sub_task.dart';
import 'package:whms/features/home/main_tab/widgets/personal/task_preview.dart';
import 'package:whms/features/home/manager_tab/bloc/manager_assignment_item_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/widgets/task/choose_datetime_item.dart';
import 'package:whms/features/home/main_tab/views/task/create_assignment_popup.dart';
import 'package:whms/features/home/main_tab/widgets/task/menu_button.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/text_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/widgets/mouse_hover_popup.dart';

class ManagementAssignmentItem extends StatelessWidget {
  final List<WorkingUnitModel> address;
  final WorkingUnitModel model;
  final int typeAssignment;
  final Function(WorkingUnitModel) reload;
  final Function() endEvent;
  final Function() choose;

  const ManagementAssignmentItem(this.model,
      {required this.reload, required this.endEvent, required this.address,
        required this.typeAssignment,
        required this.choose,
        super.key});

  @override
  Widget build(BuildContext context) {
    var configs = ConfigsCubit.fromContext(context);
    return BlocProvider(
        create: (context) => ManagerAssignmentItemCubit(model, configs),
        child: BlocBuilder<ManagerAssignmentItemCubit, int>(builder: (c, s) {
          var cubit = BlocProvider.of<ManagerAssignmentItemCubit>(c);
          return Card(
              key: Key(cubit.key),
              margin: EdgeInsets.symmetric(
                  vertical: ScaleUtils.scaleSize(5, context)),
              shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                  side: const BorderSide(color: Color(0xFFEDEDED))),
              color: Colors.white,
              child: MousePopup(
                width: 400,
                popupContent: TaskPreview(task: model, width: 400),
                child: Stack(
                    children: [
                      Positioned.fill(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(flex: typeAssignment > 6 ? 4 : 1,
                                child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: ScaleUtils.scaleSize(
                                            20, context)),
                                    child: Text(cubit.wu.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: ColorConfig.textColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScaleUtils.scaleSize(
                                                14, context),
                                            letterSpacing:
                                            ScaleUtils.scaleSize(
                                                -0.02 * 14, context))))),
                            Expanded(flex: typeAssignment > 6 ? 6 : 1,
                                child: Container())
                          ],
                        ),
                      ),
                      Positioned.fill(
                          child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: cubit.wu.type == TypeAssignmentDefine
                                      .subtask.title ?
                                      () {
                                    DialogUtils.showAlertDialog(context,
                                        child: CreateSubTask(
                                          isTaskToday: false,
                                          address: address,
                                          work: cubit.directParent!,
                                          subtask: cubit.wu,
                                          isEdit: false,
                                          canEditDefaultTask: false,
                                          // initData: (a, b, c, d){},
                                          updateSubtask: (v) {},
                                        ));
                                  }
                                      : choose,
                                  borderRadius: BorderRadius.circular(
                                      ScaleUtils.scaleSize(8, context))))),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: ScaleUtils.scaleSize(5, context)),
                          child: typeAssignment > 6
                              ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Container()),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(20, context)),
                                SizedBox(
                                    height: ScaleUtils.scaleSize(24, context),
                                    child: ChooseDatetimeItem(
                                        isEdit: false,
                                        isShowIcon: false,
                                        icon:
                                        'assets/images/icons/ic_calendar3.png',
                                        controller: TextEditingController(
                                            text: DateTimeUtils
                                                .convertTimestampToDateString(
                                                cubit.wu.deadline)),
                                        initialStart: DateTime.now(),
                                        onTap: (v) {})),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(20, context)),
                                Tooltip(
                                    message: cubit.wu.priority,
                                    child: CircleAvatar(
                                        backgroundColor:
                                        PriorityLevelExtension
                                            .convertToPriority(
                                            cubit.wu.priority)
                                            .background,
                                        radius: ScaleUtils.scaleSize(
                                            12, context),
                                        child: Text(TextUtils.firstCharInString(
                                            cubit.wu.priority),
                                            style: TextStyle(
                                                color:
                                                PriorityLevelExtension
                                                    .convertToPriority(
                                                    cubit.wu.priority)
                                                    .color,
                                                fontSize: ScaleUtils.scaleSize(
                                                    10, context))))),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(30, context)),
                                Tooltip(
                                    message:
                                    '${StatusWorkingExtension
                                        .fromValue(cubit.wu.status)
                                        .description} ${StatusWorkingExtension
                                        .fromValue(cubit.wu.status)
                                        .isDynamic
                                        ? '${cubit.wu.status % 100}%'
                                        : ''}',
                                    child: CircleAvatar(
                                        backgroundColor:
                                        StatusWorkingExtension
                                            .fromValue(
                                            cubit.wu.status)
                                            .colorBackground,
                                        radius: ScaleUtils.scaleSize(
                                            12, context),
                                        child: Text(
                                            cubit.wu.status > 99
                                                ? '${cubit.wu.status % 100}%'
                                                : TextUtils.firstCharInString(
                                                StatusWorkingExtension
                                                    .fromValue(
                                                    cubit.wu.status)
                                                    .description),
                                            style: TextStyle(
                                                color:
                                                StatusWorkingExtension
                                                    .fromValue(
                                                    cubit.wu.status)
                                                    .colorTitle,
                                                fontSize: ScaleUtils.scaleSize(
                                                    10, context))
                                        ))
                                ),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(35, context)),
                                Tooltip(
                                    message: cubit.wu.workingPoint < 0
                                        ? AppText.txtWorkingPoint.text
                                        : '${cubit.wu.workingPoint} ${AppText
                                        .txtPoint.text}',
                                    child: CircleAvatar(
                                        backgroundColor: cubit.wu.workingPoint <
                                            0
                                            ? Colors.grey.shade400
                                            : const Color(0xFF0F3A9D),
                                        radius: ScaleUtils.scaleSize(
                                            12, context),
                                        child: cubit.wu.workingPoint < 0
                                            ? Image.asset(
                                            'assets/images/icons/ic_working_unit.png',
                                            scale: 4,
                                            color: Colors.white)
                                            : Text(
                                            cubit.wu.workingPoint.toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScaleUtils.scaleSize(
                                                    10, context))
                                        ))
                                ),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(30, context)),
                                cubit.wu.owner.isEmpty ? SizedBox(
                                  height: ScaleUtils.scaleSize(24, context),
                                  width: ScaleUtils.scaleSize(24, context),
                                  child: const CircularProgressIndicator(),
                                ) :
                                Tooltip(
                                    message:
                                    configs.usersMap[cubit.wu.owner]?.name ??
                                        AppText.textUnknown.text,
                                    child: AvatarItem(
                                        configs.usersMap[cubit.wu.owner]?.avt ??
                                            "",
                                        size: 24)),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(42, context)),
                                if(cubit.wu.type ==
                                    TypeAssignmentDefine.subtask.title)
                                  cubit.wu.owner.isEmpty ? SizedBox(
                                    height: ScaleUtils.scaleSize(24, context),
                                    width: ScaleUtils.scaleSize(24, context),
                                    child: const CircularProgressIndicator(),
                                  ) :
                                  Tooltip(
                                      message:
                                      configs.usersMap[cubit.wu.owner]?.name ?? AppText.textUnknown.text,
                                      child: AvatarItem(
                                          configs.usersMap[cubit.wu.owner]?.avt ?? '',
                                          size: 24)),
                                if(cubit.wu.type !=
                                    TypeAssignmentDefine.subtask.title)
                                  cubit.wu.assignees.isEmpty || configs
                                      .usersMap[cubit.wu.assignees.first] ==
                                      null
                                      ? SizedBox(
                                      width: ScaleUtils.scaleSize(24, context),
                                      height: ScaleUtils.scaleSize(24, context))
                                      : Tooltip(
                                      message: configs
                                          .usersMap[cubit.wu.assignees.first]
                                          ?.name ?? AppText.textUnknown.text,
                                      child: AvatarItem(
                                          configs
                                              .usersMap[
                                          cubit.wu.assignees.first]?.avt ?? "",
                                          size: 24)),
                                SizedBox(width: ScaleUtils.scaleSize(
                                    40, context))
                              ])
                              : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Container()),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(20, context)),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(20, context)),
                                SizedBox(
                                    height: ScaleUtils.scaleSize(24, context),
                                    child: ChooseDatetimeItem(
                                        isShowIcon: false,
                                        isEdit: false,
                                        icon:
                                        'assets/images/icons/ic_calendar3.png',
                                        controller: TextEditingController(
                                            text: DateTimeUtils
                                                .convertTimestampToDateString(
                                                cubit.wu.deadline)),
                                        initialStart: DateTime.now(),
                                        onTap: (v) {})),
                                SizedBox(width: ScaleUtils.scaleSize(
                                    30, context)),
                                Tooltip(
                                    message:
                                    '${cubit.numOfChild} ${cubit.wu.type ==
                                        TypeAssignmentDefine.sprint.title
                                        ? '${AppText.txtTask.text} & ${AppText
                                        .txtStory.text}'
                                        : AppText.txtTask.text}',
                                    child: CircleAvatar(
                                        backgroundColor: ColorConfig
                                            .statusPendingBG,
                                        radius: ScaleUtils.scaleSize(
                                            12, context),
                                        child: cubit.numOfChild < 0
                                            ? SizedBox(
                                            width: ScaleUtils.scaleSize(
                                                20, context),
                                            height: ScaleUtils.scaleSize(
                                                20, context),
                                            child: CircularProgressIndicator(
                                                strokeWidth: ScaleUtils
                                                    .scaleSize(3, context)
                                            )
                                        )
                                            : Text(cubit.numOfChild.toString(),
                                            style: TextStyle(
                                                color:
                                                ColorConfig.statusPendingText,
                                                fontSize: ScaleUtils.scaleSize(
                                                    10, context))
                                        ))
                                ),
                                SizedBox(width: ScaleUtils.scaleSize(
                                    40, context)),
                                Tooltip(
                                    message:
                                    '${AppText.titleProgress.text} ${cubit
                                        .percent}%',
                                    child: CircleAvatar(
                                        backgroundColor: cubit.percent <= 0
                                            ? ColorConfig.statusPendingBG
                                            : cubit.percent == 100 ? ColorConfig
                                            .statusCompletedBG : ColorConfig
                                            .statusProcessingBG,
                                        radius: ScaleUtils.scaleSize(
                                            12, context),
                                        child: cubit.percent < 0
                                            ? SizedBox(
                                          width: ScaleUtils.scaleSize(
                                              20, context),
                                          height: ScaleUtils.scaleSize(
                                              20, context),
                                          child: CircularProgressIndicator(
                                            strokeWidth: ScaleUtils.scaleSize(
                                                3, context),
                                          ),
                                        ) :
                                        Text(cubit.percent < 0 ? '0%' : '${cubit
                                            .percent}%',
                                            style: TextStyle(
                                                color:
                                                cubit.percent <= 0 ? ColorConfig
                                                    .statusPendingText : cubit
                                                    .percent == 100
                                                    ? ColorConfig
                                                    .statusCompletedText
                                                    : ColorConfig
                                                    .statusProcessingText,
                                                fontSize: ScaleUtils.scaleSize(
                                                    10, context))
                                        ))
                                ),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(25, context)),
                                Stack(alignment: Alignment.topRight, children: [
                                  SizedBox(
                                      width: ScaleUtils.scaleSize(32, context),
                                      height: ScaleUtils.scaleSize(32, context),
                                      child:
                                      AvatarItem(configs.user.avt, size: 24)),
                                  if (cubit.wu.assignees.length > 1)
                                    Container(
                                        width: ScaleUtils.scaleSize(
                                            12, context),
                                        height: ScaleUtils.scaleSize(
                                            12, context),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: ColorConfig.primary3,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white,
                                                width: ScaleUtils.scaleSize(
                                                    1, context))),
                                        child: Text(
                                            '+${cubit.wu.assignees.length - 1}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: ScaleUtils.scaleSize(
                                                    8, context),
                                                fontWeight: FontWeight.w600,
                                                letterSpacing:
                                                ScaleUtils.scaleSize(
                                                    -0.02 * 8, context))))
                                ]),
                                SizedBox(width: ScaleUtils.scaleSize(
                                    45, context))
                              ])
                      ),
                      if(cubit.wu.type != TypeAssignmentDefine.subtask.title)
                        Container(
                            alignment: Alignment.topRight,
                            margin: EdgeInsets.only(
                                top: ScaleUtils.scaleSize(3, context),
                                right: ScaleUtils.scaleSize(3, context)),
                            child: Theme(
                                data: Theme.of(context).copyWith(
                                    popupMenuTheme: PopupMenuThemeData(
                                        color: Colors.white,
                                        textStyle:
                                        const TextStyle(
                                            color: ColorConfig.textColor),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    ScaleUtils.scaleSize(
                                                        12, context))),
                                            side: BorderSide(
                                                color: ColorConfig.border,
                                                width:
                                                ScaleUtils.scaleSize(
                                                    2, context))))),
                                child: MenuButton(
                                    work: model,
                                    endEvent: endEvent,
                                    deletePress: () {
                                      configs.updateWorkingUnit(
                                          model.copyWith(enable: false), model);
                                    },
                                    editPressed: () {
                                      DialogUtils.showAlertDialog(context,
                                          child: CreateAssignmentPopup(
                                              typeAssignment: typeAssignment,
                                              isSub: true,
                                              isEdit: true,
                                              reload: reload,
                                              edited: (v) async {
                                                await cubit.updateWU(v);
                                              },
                                              scopes: cubit.wu.scopes,
                                              userId: configs.user.id,
                                              selectedWorking: cubit.wu,
                                              assignees: cubit.wu.assignees));
                                    })))
                    ]),
              ));
        })
    );
  }
}
