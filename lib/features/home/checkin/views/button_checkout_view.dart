import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/blocs/select_work_cubit.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/function_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class ButtonCheckoutView extends StatelessWidget {
  const ButtonCheckoutView({super.key, required this.cubit});

  final CheckOutCubit cubit;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ZButton(
            title: AppText.btnCancel.text,
            icon: "",
            colorTitle:ColorConfig.primary2,
            colorBackground: Colors.white,
            colorBorder: Colors.white,
            sizeTitle: 16,
            paddingHor: 20,
            paddingVer: 6,
            fontWeight: FontWeight.w600,
            onPressed: () {
              cubit.tab == 0 ? Navigator.of(context).pop() : cubit.changeTab(0);
            }),
        SizedBox(width: ScaleUtils.scaleSize(18, context)),
        if (cubit.tab == 0)
          ZButton(
              paddingHor: 14,
              title: AppText.btnCheckOut.text,
              icon: "",
              colorBackground: cubit.listWorkCheckOut.isNotEmpty
                  ? ColorConfig.primary2
                  : ColorConfig.border4,
              colorBorder: cubit.listWorkCheckOut.isNotEmpty
                  ? ColorConfig.primary2
                  : ColorConfig.border4,
              sizeTitle: 16,
              paddingVer: 6,
              fontWeight: FontWeight.w600,
              onPressed: () async {
                if (cubit.listWorkCheckOut.isEmpty) {
                  ToastUtils.showBottomToast(
                      context, AppText.textPleaseSelectTaskToCheckOut.text,
                      duration: 4);
                  return;
                }
                bool isSuccess = false;
                int sumWT = 0;
                List<String> listTask = [];
                for (var e in cubit.listWorkCheckOut) {
                  sumWT += cubit.mapWorkingTime[e.id] ?? 0;
                  if (!listTask.contains(e.parent)) {
                    listTask.add(e.parent);
                  }
                }
                int sumWP = 0;
                for (var e in listTask) {
                  sumWP += max(cfC.mapWorkingUnit[e]?.workingPoint ?? 0, 0);
                }
                final workShift = cubit.workShift;
                int logTime = FunctionUtils.getLogTimeFromWorkShift(
                    workShift.copyWith(
                        status: StatusCheckInDefine.checkOut.value,
                        checkOut: Timestamp.now()));
                bool isCheckOut = await DialogUtils.showConfirmCheckoutDialog(
                    context,
                    AppText.titleConfirm.text,
                    sumWP,
                    sumWT,
                    logTime,
                    AppText.textConfirmCheckOut.text);
                await cfC.getWorkFieldByWorkShift(workShift.id);
                final listWorkField = cfC.mapWFfWS[workShift.id] ?? [];
                bool checkTimeDoing = true;
                for (var e in listWorkField) {
                  debugPrint(
                      "=====> checkout task: ${cfC.mapWorkingUnit[e.taskId]?.title} - ${e.fromStatus} - ${e.toStatus} - ${e.duration}}");
                  if (e.fromStatus != e.toStatus &&
                      e.duration <= 0 &&
                      cfC.mapWorkingUnit[e.taskId] != null &&
                      !cfC.mapWorkingUnit[e.taskId]!.closed &&
                      cfC.mapWorkingUnit[e.taskId]!.type !=
                          TypeAssignmentDefine.task.title) {
                    checkTimeDoing = false;
                    break;
                  }
                }

                if (!checkTimeDoing) {
                  ToastUtils.showBottomToast(
                      context, AppText.textPleaseChooseTimeDoingTask.text,
                      duration: 4);
                  return;
                }

                if (isCheckOut && context.mounted) {
                  await DialogUtils.handleDialog(context, () async {
                    try {
                      List<String> listTaskCheckout = [];
                      final workService = WorkingService.instance;
                      final workShift = cubit.workShift;
                      for (var work in cubit.listWorkCheckOut) {
                        // debugPrint("=====> Task checkout: ${work.title} - ${work.id}");
                        if (work.parent.isNotEmpty &&
                            !listTaskCheckout.contains(work.parent)) {
                          listTaskCheckout.add(work.parent);
                        }
                        final workField =
                            await workService.getWorkFieldByWorkShiftAndIdWork(
                                workShift.id, work.id);
                        // debugPrint("-----> get workfie;d: ${workField?.taskId} - ${workField?.id} - ${workField?.fromStatus} - ${workField?.toStatus}");
                        if (workField != null) {
                          cfC.updateWorkingUnit(
                              work.copyWith(status: workField.toStatus),
                              work.copyWith(status: workField.fromStatus));
                          // await workService.updateWorkingUnitField(
                          //     work.copyWith(status: workField.toStatus),
                          //     work,
                          //     idU);
                        }
                      }
                      cfC.updateWorkShift(
                          workShift.copyWith(
                              checkOut: DateTimeUtils.getTimestampWithDateTime(
                                  cubit.timeCheckout),
                              status: StatusCheckInDefine.checkOut.value),
                          workShift);
                      // await UserServices.instance.updateWorkShift(
                      //     workShift.copyWith(
                      //         checkOut: DateTimeUtils.getTimestampWithDateTime(
                      //             cubit.timeCheckout),
                      //         status: StatusCheckInDefine.checkOut.value));
                      if (context.mounted) {
                        await ConfigsCubit.fromContext(context)
                            .changeCheckIn(StatusCheckInDefine.checkOut);
                      }

                      // final listWorkField = await WorkingService.instance
                      //     .getWorkFieldByIdWorkShift(workShift.id);

                      for (var work in listTaskCheckout) {
                        final listSubWork = await WorkingService.instance
                            .getWorkingUnitByIdParent(work);

                        int cnt = 0;
                        int process = 0;
                        int mandatoryStatus = -9;
                        if (listSubWork.isNotEmpty) {
                          for (var sW in listSubWork) {
                            int status = sW.status;

                            final workk = listWorkField
                                .where((item) => item.taskId == sW.id)
                                .firstOrNull;
                            if (workk != null) {
                              status = workk.toStatus;
                            }
                            if (sW.owner.isEmpty &&
                                (status ==
                                        StatusWorkingDefine.cancelled.value ||
                                    status ==
                                        StatusWorkingDefine.failed.value)) {
                              mandatoryStatus = status;
                            }
                            if (status == StatusWorkingDefine.cancelled.value)
                              continue;
                            cnt++;
                            if (status == StatusWorkingDefine.done.value) {
                              process++;
                            }
                          }
                        }
                        WorkFieldModel? newWF;
                        WorkFieldModel? oldModel;
                        final newId = FirebaseFirestore.instance
                            .collection('whms_pls_work_field')
                            .doc()
                            .id;
                        if (mandatoryStatus != -9) {
                          final workUnit = await workService
                              .getWorkingUnitByIdIgnoreClosed(work);
                          cfC.updateWorkingUnit(
                              workUnit!.copyWith(status: mandatoryStatus),
                              workUnit);
                          // await workService.updateWorkingUnitField(
                          //     workUnit!.copyWith(status: mandatoryStatus),
                          //     workUnit,
                          //     idU);
                          newWF = await workService
                              .getWorkFieldByWorkShiftAndIdWork(
                                  workShift.id, workUnit.id);
                          if (newWF != null) {
                            oldModel = newWF.copyWith();
                            newWF = newWF.copyWith(toStatus: mandatoryStatus);
                          } else {
                            newWF = WorkFieldModel(
                              id: newId,
                              taskId: workUnit.id,
                              fromStatus: workUnit.status,
                              toStatus: mandatoryStatus,
                              date: DateTimeUtils.getCurrentDate(),
                              workShift: workShift.id,
                              enable: true,
                            );
                          }
                        } else if (cnt == process) {
                          final workUnit = await workService
                              .getWorkingUnitByIdIgnoreClosed(work);
                          cfC.updateWorkingUnit(
                              workUnit!.copyWith(
                                  status: StatusWorkingDefine.done.value),
                              workUnit);
                          // await workService.updateWorkingUnitField(
                          //     workUnit!.copyWith(
                          //         status: StatusWorkingDefine.done.value),
                          //     workUnit,
                          //     idU);
                          newWF = await workService
                              .getWorkFieldByWorkShiftAndIdWork(
                                  workShift.id, workUnit.id);
                          if (newWF != null) {
                            oldModel = newWF.copyWith();
                            newWF = newWF.copyWith(
                                toStatus: StatusWorkingDefine.done.value);
                          } else {
                            newWF = WorkFieldModel(
                              id: newId,
                              taskId: work,
                              fromStatus: workUnit.status,
                              toStatus: StatusWorkingDefine.done.value,
                              date: DateTimeUtils.getCurrentDate(),
                              workShift: workShift.id,
                              enable: true,
                            );
                          }
                        } else if (cnt > 0) {
                          final workUnit = await workService
                              .getWorkingUnitByIdIgnoreClosed(work);
                          cfC.updateWorkingUnit(
                              workUnit!.copyWith(
                                  status: StatusWorkingDefine.processing.value +
                                      (process * 100) ~/ cnt),
                              workUnit);
                          // await workService.updateWorkingUnitField(
                          //     workUnit!.copyWith(
                          //         status: StatusWorkingDefine.processing.value +
                          //             (process * 100) ~/ cnt),
                          //     workUnit,
                          //     idU);
                          newWF = await workService
                              .getWorkFieldByWorkShiftAndIdWork(
                                  workShift.id, workUnit.id);
                          if (newWF != null) {
                            oldModel = newWF.copyWith();
                            newWF = newWF.copyWith(
                                toStatus: StatusWorkingDefine.processing.value +
                                    (process * 100) ~/ cnt);
                          } else {
                            newWF = WorkFieldModel(
                              id: newId,
                              taskId: workUnit.id,
                              fromStatus: workUnit.status,
                              toStatus: StatusWorkingDefine.processing.value +
                                  (process * 100) ~/ cnt,
                              date: DateTimeUtils.getCurrentDate(),
                              workShift: workShift.id,
                              enable: true,
                            );
                          }
                        }

                        if (newWF != null) {
                          if (newWF.id == newId) {
                            cfC.addWorkField(newWF);
                            // await workService.addNewWorkField(newWF);
                          } else {
                            cfC.updateWorkField(newWF, oldModel!);
                            // await workService.updateWorkField(newWF);
                          }
                        }
                      }
                      isSuccess = true;
                      return ResponseModel(
                          status: ResponseStatus.ok, results: "");
                    } catch (e) {
                      return ResponseModel(
                          status: ResponseStatus.error,
                          error: ErrorModel(text: e.toString()));
                    }
                  }, () {},
                      successMessage: AppText.textCheckoutSuccess.text,
                      successTitle: AppText.titleSuccess.text,
                      failedMessage: AppText.textHasError.text,
                      failedTitle: AppText.titleFailed.text);
                }
                if (isSuccess && context.mounted) {
                  Navigator.of(context).pop();
                }
              }),
        if (cubit.tab == 2)
          ZButton(
              paddingHor: 14,
              title: AppText.btnAdd.text,
              icon: "",
              colorBackground: ColorConfig.primary2,
              colorBorder: ColorConfig.primary2,
              sizeTitle: 16,
              paddingVer: 6,
              fontWeight: FontWeight.w600,
              onPressed: () async {
                DialogUtils.showLoadingDialog(context);
                await cubit.selectWork(
                    BlocProvider.of<SelectWorkCubit>(context).selectWork,
                    context);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                cubit.changeTab(0);
              }),
      ],
    );
  }
}
