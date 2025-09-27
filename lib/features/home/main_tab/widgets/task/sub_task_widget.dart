import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/features/home/main_tab/views/task/create_sub_task/create_sub_task.dart';
import 'package:whms/features/home/main_tab/widgets/task/more_option_button.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/dropdown_status_working_unit.dart';
import 'package:whms/widgets/time_card.dart';
import 'package:whms/widgets/working_time_field.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class SubTaskWidget extends StatelessWidget {
  const SubTaskWidget(
      {super.key,
      required this.workUnit,
      this.workField,
      this.showMenu = false,
      required this.onSelected,
      required this.address,
      required this.work,
      required this.canEditDefaultTask,
      required this.initData,
      this.isToday = false,
      // required this.cubitST,
      required this.updateSubtask,
      required this.removeSubtask,
      this.updateWF,
      this.isDefaultTask = false,
      required this.tab});

  final WorkingUnitModel workUnit;
  final WorkFieldModel? workField;
  final bool showMenu;
  final Function(String) onSelected;
  final List<WorkingUnitModel> address;
  final WorkingUnitModel work;
  final bool canEditDefaultTask;
  final Function(WorkingUnitModel, bool, BuildContext, UserModel) initData;
  final Function(WorkingUnitModel) updateSubtask;
  final Function(WorkingUnitModel) removeSubtask;
  final Function(WorkFieldModel)? updateWF;
  final bool isDefaultTask;

  // final SubTaskCubit cubitST;
  final bool isToday;
  final String tab;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    final cfC = ConfigsCubit.fromContext(context);
    return Stack(
        key: ValueKey(
            "subtask_widget_key_${workUnit.id}_${workUnit.status}_${workField?.taskId}_${workField?.toStatus}_${workField?.duration}"),
        children: [
          InkWell(
              onTap: () {
                DialogUtils.showAlertDialog(context,
                    child: CreateSubTask(
                      isTaskToday: false,
                      address: address,
                      work: work,
                      subtask: workUnit,
                      isEdit: false,
                      canEditDefaultTask: canEditDefaultTask,
                      // initData: initData,
                      updateSubtask: updateSubtask,
                    ));
              },
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          ScaleUtils.scaleSize(8, context)),
                      border: Border.all(
                        width: ScaleUtils.scaleSize(1, context),
                        color: ColorConfig.border6,
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(1, 1),
                          blurRadius: 5.9,
                          spreadRadius: 0,
                          color: const Color(0xFF000000).withOpacity(0.16),
                        ),
                      ]),
                  padding: EdgeInsets.all(ScaleUtils.scaleSize(10, context))
                      .copyWith(
                          top: ScaleUtils.scaleSize(12, context),
                          left: ScaleUtils.scaleSize(20, context)),
                  margin:
                      EdgeInsets.only(bottom: ScaleUtils.scaleSize(8, context)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            if (isToday)
                              Image.asset(
                                  'assets/images/icons/tab_bar/ic_tab_today.png',
                                  height: ScaleUtils.scaleSize(12, context),
                                  color: ColorConfig.primary3),
                            if (isToday)
                              SizedBox(width: ScaleUtils.scaleSize(3, context)),
                            Expanded(
                                child: Text(
                              workUnit.title,
                              style: TextStyle(
                                  fontSize: ScaleUtils.scaleSize(12, context),
                                  fontWeight: FontWeight.w600,
                                  color: isToday
                                      ? ColorConfig.primary3
                                      : ColorConfig.textColor5),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ],
                        ),
                        SizedBox(height: ScaleUtils.scaleSize(9, context)),
                        if (!isToday)
                          Row(children: [
                            StatusCard(status: workUnit.status),
                            SizedBox(width: ScaleUtils.scaleSize(5, context)),
                            TimeCard(
                                time: DateTimeUtils.formatDuration(
                                    workUnit.duration))
                          ]),
                        if (isToday)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // direction: Axis.horizontal,
                            children: [
                              if (isDefaultTask && !canEditDefaultTask)
                                IntrinsicWidth(
                                    child: StatusCard(status: workUnit.status)),
                              if (!isDefaultTask || canEditDefaultTask)
                                DropdownStatusWorkingUnit(
                                  onChanged: (v) async {
                                    updateSubtask(workUnit.copyWith(status: v));
                                    final workShift = await UserServices
                                        .instance
                                        .getWorkShiftByIdUserAndDate(user.id,
                                            DateTimeUtils.getCurrentDate());
                                    if (workShift != null) {
                                      final wf = await WorkingService.instance
                                          .getWorkFieldByWorkShiftAndIdWork(
                                              workShift.id, workUnit.id);
                                      if (wf != null) {
                                        cfC.updateWorkField(wf.copyWith(toStatus: v), wf);
                                        // await WorkingService.instance
                                        //     .updateWorkField(
                                        //         wf.copyWith(toStatus: v));
                                        if (updateWF != null) {
                                          updateWF!(wf.copyWith(toStatus: v));
                                        }
                                      }
                                    }
                                  },
                                  initItem: workUnit.status,
                                  typeOption: 1,
                                  fontSize: 8,
                                  maxHeight: 22,
                                ),
                              const ZSpace(h: 5),
                              if (workField != null &&
                                  (!isDefaultTask || canEditDefaultTask))
                                WorkingTimeField(
                                    initTime: workField!.duration,
                                    onChange: (v) {
                                      final newWF =
                                          workField!.copyWith(duration: v);
                                      cfC.updateWorkField(newWF, workField!);
                                      // WorkingService.instance
                                      //     .updateWorkField(newWF);
                                      if (updateWF != null) {
                                        updateWF!(newWF);
                                      }
                                    })
                              // WorkingTimeDropdown(
                              //   maxWidth: 110,
                              //     onChanged: (v) async {
                              //       await WorkingService.instance.updateWorkingUnit(
                              //           workUnit.copyWith(duration: v));
                              //       updateSubtask(workUnit.copyWith(duration: v));
                              //     },
                              //     initTime: workUnit.duration,
                              //     isAddTask: false,
                              //     isEdit: true)
                            ],
                          )
                      ]))),
          Positioned(
            top: ScaleUtils.scaleSize(5, context),
            right: ScaleUtils.scaleSize(10, context),
            child: Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  color: Colors.white,
                  textStyle: const TextStyle(
                    color: ColorConfig.textColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(ScaleUtils.scaleSize(12, context))),
                    side: BorderSide(
                      color: ColorConfig.border,
                      width:
                          ScaleUtils.scaleSize(2, context), // Độ dày của viền
                    ),
                  ),
                ),
              ),
              child: MoreOptionButton(
                showEdit: canEditDefaultTask,
                tab: tab,
                work: workUnit,
                endEvent: () async {
                  await initData(work, tab == "201", context, user);
                },
                deletePress: () {
                  ConfigsCubit.fromContext(context).updateWorkingUnit(
                      workUnit.copyWith(enable: false), work);
                  removeSubtask(workUnit);
                },
                editPressed: (isTaskToday) async {
                  await DialogUtils.showAlertDialog(context,
                      child: CreateSubTask(
                        updateWF: updateWF,
                        isToday: tab == "201",
                        isTaskToday: isTaskToday,
                        address: address,
                        work: work,
                        subtask: workUnit,
                        isEdit: true,
                        canEditDefaultTask: canEditDefaultTask,
                        // initData: initData,
                        updateSubtask: updateSubtask,
                      ));
                },
              ),
            ),
          )
        ]);
  }
}
