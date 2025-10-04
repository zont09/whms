import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.editPressed,
    required this.deletePress,
    required this.endEvent,
    required this.work,
    this.onDoToday,
    this.onRemoveToday,
    this.onDoing,
    this.onUpdate,
    this.isTaskToday = 0,
  });

  final Function() editPressed;
  final Function() endEvent;
  final Function() deletePress;
  final Function(WorkingUnitModel)? onDoToday;
  final Function(WorkingUnitModel)? onRemoveToday;
  final Function(WorkingUnitModel)? onDoing;
  final Function(WorkingUnitModel, WorkingUnitModel)? onUpdate;
  final WorkingUnitModel work;

  final int isTaskToday;

  @override
  Widget build(BuildContext context) {
    var user = ConfigsCubit
        .fromContext(context)
        .user;
    final cfC = ConfigsCubit.fromContext(context);
    final checkInStatus = ConfigsCubit
        .fromContext(context)
        .isCheckIn;
    return MenuAnchor(
        style: MenuStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            elevation:
            WidgetStateProperty.all(ScaleUtils.scaleSize(2, context)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
                side: BorderSide(
                    width: ScaleUtils.scaleSize(1, context),
                    color: ColorConfig.border))),
            padding: WidgetStateProperty.all(EdgeInsets.zero)),
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              customBorder: const CircleBorder(),
              child: Padding(
                padding: EdgeInsets.all(ScaleUtils.scaleSize(3, context)),
                child: Image.asset('assets/images/icons/ic_expand.png',
                    height: ScaleUtils.scaleSize(16, context)),
              ),
            ),
          );
        },
        menuChildren: [
          if (work.status == StatusWorkingDefine.none.value &&
              work.type == TypeAssignmentDefine.task.title)
            Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: IntrinsicHeight(
                    child: MenuItemButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () async {
                          DialogUtils.showLoadingDialog(context);
                          cfC.updateWorkingUnit(
                              work.copyWith(
                                  status: StatusWorkingDefine.processing.value),
                              work);
                          // await workService.updateWorkingUnitField(work.copyWith(
                          //     status: StatusWorkingDefine.processing.value), work, user.id);
                          endEvent();
                          // if (context.mounted) {
                          //   cubitMT.initData(context);
                          // }
                          if (onDoing != null) {
                            onDoing!(work);
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(12, context),
                                vertical: ScaleUtils.scaleSize(6, context)),
                            child: Row(
                              children: [
                                Icon(Icons.not_started_outlined,
                                    size: ScaleUtils.scaleSize(14, context),
                                    color: ColorConfig.textTertiary),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(2, context)),
                                Text(AppText.textStart.text,
                                    style: TextStyle(
                                        fontSize:
                                        ScaleUtils.scaleSize(14, context),
                                        color: ColorConfig.textTertiary)),
                              ],
                            ))))),
          if ((work.owner == user.id &&
              work.type != TypeAssignmentDefine.okrs.title) ||
              (work.type == TypeAssignmentDefine.okrs.title &&
                  work.assignees.contains(user.id)))
            Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: IntrinsicHeight(
                  // Wrap với IntrinsicHeight
                    child: MenuItemButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () {
                          editPressed();
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(12, context),
                                vertical: ScaleUtils.scaleSize(6, context)),
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: ScaleUtils.scaleSize(14, context),
                                    color: ColorConfig.textTertiary),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(2, context)),
                                Text(AppText.textEdit.text,
                                    style: TextStyle(
                                        fontSize:
                                        ScaleUtils.scaleSize(14, context),
                                        color: ColorConfig.textTertiary)),
                              ],
                            ))))),
          if ((work.owner == user.id &&
              work.type != TypeAssignmentDefine.okrs.title) ||
              (work.type == TypeAssignmentDefine.okrs.title &&
                  work.assignees.contains(user.id)))
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: IntrinsicHeight(
                  child: MenuItemButton(
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(Size.zero),
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: () async {
                        final isDelete = await DialogUtils.showConfirmDialog(
                            context,
                            AppText.titleConfirm.text,
                            AppText.textConfirmDeleteTask.text);
                        if (!isDelete) return;
                        bool isSuccess = false;
                        await DialogUtils.handleDialog(context, () async {
                          try {
                            await deletePress();
                            isSuccess = true;
                            return ResponseModel(
                                status: ResponseStatus.ok, results: "");
                          } catch (e) {
                            return ResponseModel(
                                status: ResponseStatus.error,
                                error: ErrorModel(text: e.toString()));
                          }
                        }, () {},
                            successMessage: AppText.titleSuccess.text,
                            successTitle: AppText.titleSuccess.text,
                            failedMessage: AppText.titleFailed.text,
                            failedTitle: AppText.textHasError.text,
                            isShowDialogSuccess: false);
                        if (isSuccess && context.mounted) {
                          endEvent();
                        }
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(12, context),
                              vertical: ScaleUtils.scaleSize(6, context)),
                          child: Row(
                            children: [
                              Icon(Icons.highlight_remove,
                                  size: ScaleUtils.scaleSize(14, context),
                                  color: ColorConfig.textTertiary),
                              SizedBox(width: ScaleUtils.scaleSize(2, context)),
                              Text(AppText.textDelete.text,
                                  style: TextStyle(
                                      fontSize:
                                      ScaleUtils.scaleSize(14, context),
                                      color: ColorConfig.textTertiary)),
                            ],
                          )))),
            ),
          Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: IntrinsicHeight(
                // Wrap với IntrinsicHeight
                  child: MenuItemButton(
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(Size.zero),
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: () async {
                        // DialogUtils.showLoadingDialog(context);
                        final workPrime = await WorkingService.instance
                            .getWorkingUnitById(work.id);
                        if (workPrime != null) {
                          cfC.updateWorkingUnit(
                              workPrime.copyWith(closed: true), workPrime);
                          // await WorkingService.instance.updateWorkingUnitField(
                          //     workPrime.copyWith(closed: true),
                          //     workPrime,
                          //     user.id);
                          if (work.type == TypeAssignmentDefine.task.title) {
                            final listChild = await WorkingService.instance
                                .getWorkingUnitByIdParent(work.id);
                            for (var workChild in listChild) {
                              cfC.updateWorkingUnit(
                                  workChild.copyWith(closed: true), workChild);
                              // await WorkingService.instance
                              //     .updateWorkingUnitField(
                              //         workChild.copyWith(closed: true),
                              //         workChild,
                              //         user.id);
                            }
                          }
                          if (onUpdate != null) {
                            onUpdate!(
                                workPrime.copyWith(closed: true), workPrime);
                            if (context.mounted) {
                              ToastUtils.showBottomToast(
                                  context, AppText.textCloseTaskSuccess.text,
                                  duration: 6);
                            }
                          }
                        }

                        // endEvent();
                        // debugPrint("=====> Closed loading: ${context.mounted}");
                        // if (context.mounted) {
                        //   Navigator.of(context).pop();
                        // }
                      },
                      child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(12, context),
                              vertical: ScaleUtils.scaleSize(6, context)),
                          child: Row(
                            children: [
                              Icon(
                                  work.closed
                                      ? Icons.open_in_browser_outlined
                                      : Icons.close,
                                  size: ScaleUtils.scaleSize(14, context),
                                  color: ColorConfig.textTertiary),
                              SizedBox(width: ScaleUtils.scaleSize(2, context)),
                              Text(
                                  work.closed
                                      ? AppText.textReOpen.text
                                      : AppText.textClose.text,
                                  style: TextStyle(
                                      fontSize:
                                      ScaleUtils.scaleSize(14, context),
                                      color: ColorConfig.textTertiary)),
                            ],
                          ))))),
          if (isTaskToday == 2 && checkInStatus == StatusCheckInDefine.checkIn)
            Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: IntrinsicHeight(
                    child: MenuItemButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () async {
                          // DialogUtils.showLoadingDialog(context);
                          final workShift = await UserServices.instance
                              .getWorkShiftByIdUserAndDate(
                              user.id, DateTimeUtils.getCurrentDate());
                          if (onDoToday != null) {
                            onDoToday!(work);
                          }
                          if (workShift != null) {
                            final workService = WorkingService.instance;
                            final wf = await workService
                                .getWorkFieldByWorkShiftAndIdWorkIgnoreEnable(
                                workShift.id, work.id);

                            if (wf != null) {
                              cfC.updateWorkField(
                                  wf.copyWith(enable: true), wf);
                              // await workService
                              //     .updateWorkField(wf.copyWith(enable: true));
                            } else {
                              WorkFieldModel newWF = WorkFieldModel(
                                  id: FirebaseFirestore.instance
                                      .collection('daily_pls_work_field')
                                      .doc()
                                      .id,
                                  taskId: work.id,
                                  fromStatus: work.status,
                                  toStatus: work.status,
                                  duration: work.duration,
                                  date: DateTimeUtils.getCurrentDate(),
                                  workShift: workShift.id,
                                  enable: true);
                              cfC.addWorkField(newWF);
                              // await workService.addNewWorkField(newWF);
                            }

                            final subtasks = await WorkingService.instance
                                .getWorkingUnitByIdParent(work.id);

                            for (var st in subtasks) {
                              final wfst = await workService
                                  .getWorkFieldByWorkShiftAndIdWorkIgnoreEnable(
                                  workShift.id, st.id);
                              if (wfst != null) {
                                cfC.updateWorkField(
                                    wfst.copyWith(enable: true), wfst);
                                // await workService.updateWorkField(
                                //     wfst.copyWith(enable: true));
                              } else {
                                WorkFieldModel newWF = WorkFieldModel(
                                    id: FirebaseFirestore.instance
                                        .collection('daily_pls_work_field')
                                        .doc()
                                        .id,
                                    taskId: st.id,
                                    fromStatus: st.status,
                                    toStatus: st.status,
                                    duration: st.duration,
                                    date: DateTimeUtils.getCurrentDate(),
                                    workShift: workShift.id,
                                    enable: true);
                                cfC.addWorkField(newWF);
                                // await workService.addNewWorkField(newWF);
                              }
                            }
                          }
                          endEvent();

                          // if (context.mounted) {
                          //   Navigator.of(context).pop();
                          // }
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(12, context),
                                vertical: ScaleUtils.scaleSize(6, context)),
                            child: Row(
                              children: [
                                Icon(Icons.add_circle_outline,
                                    size: ScaleUtils.scaleSize(14, context),
                                    color: ColorConfig.textTertiary),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(2, context)),
                                Text(AppText.textDoToday.text,
                                    style: TextStyle(
                                        fontSize:
                                        ScaleUtils.scaleSize(14, context),
                                        color: ColorConfig.textTertiary)),
                              ],
                            ))))),
          if (isTaskToday == 1 && checkInStatus == StatusCheckInDefine.checkIn)
            Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: IntrinsicHeight(
                    child: MenuItemButton(
                        style: ButtonStyle(
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () async {
                          // DialogUtils.showLoadingDialog(context);
                          if (onRemoveToday != null) {
                            onRemoveToday!(work);
                          }
                          final workShift = await UserServices.instance
                              .getWorkShiftByIdUserAndDate(
                              user.id, DateTimeUtils.getCurrentDate());
                          if (workShift != null) {
                            final workService = WorkingService.instance;
                            final wf = await workService
                                .getWorkFieldByWorkShiftAndIdWorkIgnoreEnable(
                                workShift.id, work.id);

                            if (wf != null) {
                              cfC.updateWorkField(
                                  wf.copyWith(enable: false), wf);
                              // await workService
                              //     .updateWorkField(wf.copyWith(enable: false));
                            }

                            final subtasks = await WorkingService.instance
                                .getWorkingUnitByIdParent(work.id);

                            for (var st in subtasks) {
                              final wfst = await workService
                                  .getWorkFieldByWorkShiftAndIdWorkIgnoreEnable(
                                  workShift.id, st.id);
                              if (wfst != null) {
                                cfC.updateWorkField(
                                    wfst.copyWith(enable: false), wfst);
                                // await workService.updateWorkField(
                                //     wfst.copyWith(enable: false));
                              }
                            }
                          }
                          endEvent();

                          // if (context.mounted) {
                          //   Navigator.of(context).pop();
                          // }
                        },
                        child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: ScaleUtils.scaleSize(12, context),
                                vertical: ScaleUtils.scaleSize(6, context)),
                            child: Row(
                              children: [
                                Icon(Icons.remove_circle_outline,
                                    size: ScaleUtils.scaleSize(14, context),
                                    color: ColorConfig.textTertiary),
                                SizedBox(
                                    width: ScaleUtils.scaleSize(2, context)),
                                Text(AppText.textRemoveFromToday.text,
                                    style: TextStyle(
                                        fontSize:
                                        ScaleUtils.scaleSize(14, context),
                                        color: ColorConfig.textTertiary)),
                              ],
                            ))))),
          // if(work.owner == cfC.user.id &&
          //    (work.type == TypeAssignmentDefine.sprint.title ||
          //     work.type == TypeAssignmentDefine.story.title ||
          //     work.type == TypeAssignmentDefine.task.title))
          //   Container(
          //       decoration: BoxDecoration(
          //         border: Border(
          //           bottom: BorderSide(color: Colors.grey.shade200),
          //         ),
          //       ),
          //       child: IntrinsicHeight(
          //           child: MenuItemButton(
          //               style: ButtonStyle(
          //                 minimumSize: WidgetStateProperty.all(Size.zero),
          //                 padding: WidgetStateProperty.all(EdgeInsets.zero),
          //               ),
          //               onPressed: () async {
          //                 // DialogUtils.showAlertDialog(context, child: DuplicateWuPopup(model: work));
          //               },
          //               child: Container(
          //                   width: double.infinity,
          //                   padding: EdgeInsets.symmetric(
          //                       horizontal: ScaleUtils.scaleSize(12, context),
          //                       vertical: ScaleUtils.scaleSize(6, context)),
          //                   child: Row(
          //                     children: [
          //                       Icon(Icons.control_point_duplicate,
          //                           size: ScaleUtils.scaleSize(14, context),
          //                           color: ColorConfig.textTertiary),
          //                       SizedBox(
          //                           width: ScaleUtils.scaleSize(2, context)),
          //                       Text(AppText.textDuplicateWU.text,
          //                           style: TextStyle(
          //                               fontSize:
          //                               ScaleUtils.scaleSize(14, context),
          //                               color: ColorConfig.textTertiary)),
          //                     ],
          //                   ))))),
        ]);
  }
}
