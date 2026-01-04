import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/services/notification_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/function_utils.dart';
import 'package:whms/untils/toast_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'dart:math';

class CheckoutButtonWithNotification extends StatelessWidget {
  final CheckOutCubit cubit; // CheckoutCubit
  final ConfigsCubit cfC;
  final String idU;

  const CheckoutButtonWithNotification({
    super.key,
    required this.cubit,
    required this.cfC,
    required this.idU,
  });

  @override
  Widget build(BuildContext context) {
    return ZButton(
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
        await _handleCheckout(context);
      },
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    // Validation: Check if there are tasks to checkout
    if (cubit.listWorkCheckOut.isEmpty) {
      ToastUtils.showBottomToast(
          context, AppText.textPleaseSelectTaskToCheckOut.text,
          duration: 4);
      return;
    }

    // Calculate working time and points
    int sumWT = 0;
    List<String> listTask = [];
    for (var e in cubit.listWorkCheckOut) {
      sumWT += (cubit.mapWorkingTime[e.id] ?? 0);
      if (!listTask.contains(e.parent)) {
        listTask.add(e.parent);
      }
    }

    int sumWP = 0;
    for (var e in listTask) {
      sumWP += max(cfC.mapWorkingUnit[e]?.workingPoint ?? 0, 0);
    }

    // Get work shift and log time
    final workShift = cubit.workShift;
    int logTime = FunctionUtils.getLogTimeFromWorkShift(workShift.copyWith(
        status: StatusCheckInDefine.checkOut.value, checkOut: Timestamp.now()));

    // Show confirmation dialog
    bool isCheckOut = await DialogUtils.showConfirmCheckoutDialog(
        context,
        AppText.titleConfirm.text,
        sumWP,
        sumWT,
        logTime,
        AppText.textConfirmCheckOut.text);

    if (!isCheckOut) return;

    // Get work fields
    await cfC.getWorkFieldByWorkShift(workShift.id);
    final listWorkField = cfC.mapWFfWS[workShift.id] ?? [];

    // Validate time doing for tasks
    bool checkTimeDoing = _validateTimeDoing(listWorkField);
    if (!checkTimeDoing) {
      if (context.mounted) {
        ToastUtils.showBottomToast(
            context, AppText.textPleaseChooseTimeDoingTask.text,
            duration: 4);
      }
      return;
    }

    // Process checkout
    if (context.mounted) {
      bool isSuccess = false;
      await DialogUtils.handleDialog(
        context,
            () async {
          try {
            isSuccess = await _processCheckout(
              context,
              listWorkField,
              listTask,
              workShift,
            );
            return ResponseModel(status: ResponseStatus.ok, results: "");
          } catch (e) {
            return ResponseModel(
                status: ResponseStatus.error,
                error: ErrorModel(text: e.toString()));
          }
        },
            () {},
        successMessage: AppText.textCheckoutSuccess.text,
        successTitle: AppText.titleSuccess.text,
        failedMessage: AppText.textHasError.text,
        failedTitle: AppText.titleFailed.text,
      );

      if (isSuccess && context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  bool _validateTimeDoing(List<WorkFieldModel> listWorkField) {
    for (var e in listWorkField) {
      debugPrint(
          "=====> checkout task: ${cfC.mapWorkingUnit[e.taskId]?.title} - ${e.fromStatus} - ${e.toStatus} - ${e.duration}");

      if (e.fromStatus != e.toStatus &&
          e.duration <= 0 &&
          cfC.mapWorkingUnit[e.taskId] != null &&
          !cfC.mapWorkingUnit[e.taskId]!.closed &&
          cfC.mapWorkingUnit[e.taskId]!.type !=
              TypeAssignmentDefine.task.title) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _processCheckout(
      BuildContext context,
      List<WorkFieldModel> listWorkField,
      List<String> listTask,
      dynamic workShift,
      ) async {
    final workService = WorkingService.instance;
    final notificationService = NotificationService.instance;
    List<String> listTaskCheckout = [];

    // ===== STEP 1: Update status for checked out tasks =====
    for (var work in cubit.listWorkCheckOut) {
      if (work.parent.isNotEmpty && !listTaskCheckout.contains(work.parent)) {
        listTaskCheckout.add(work.parent);
      }

      final workField = await workService.getWorkFieldByWorkShiftAndIdWork(
          workShift.id, work.id);

      if (workField != null && workField.fromStatus != workField.toStatus) {
        final oldWork = work.copyWith(status: workField.fromStatus);
        final newWork = work.copyWith(status: workField.toStatus);

        // Update locally
        cfC.updateWorkingUnit(newWork, oldWork);

        // ===== GỬI THÔNG BÁO KHI CẬP NHẬT STATUS LÚC CHECKOUT =====
        try {
          await notificationService.notifyTaskStatusUpdate(
            task: newWork,
            updaterId: idU,
            oldStatus: workField.fromStatus,
            newStatus: workField.toStatus,
            checkInStatus: StatusCheckInDefine.checkOut, path: 'home/manager/${newWork.id}',
          );
          debugPrint(
              "=========> Sent notification for status update: ${work.title}");
        } catch (e) {
          debugPrint("Error sending status update notification: $e");
        }
      }
    }

    // ===== STEP 2: Update work shift status =====
    cfC.updateWorkShift(
        workShift.copyWith(
            checkOut: DateTimeUtils.getTimestampWithDateTime(cubit.timeCheckout),
            status: StatusCheckInDefine.checkOut.value),
        workShift);

    if (context.mounted) {
      await ConfigsCubit.fromContext(context)
          .changeCheckIn(StatusCheckInDefine.checkOut);
    }

    // ===== STEP 3: Update parent tasks status based on children =====
    for (var work in listTaskCheckout) {
      await _updateParentTaskStatus(
        work,
        workShift,
        listWorkField,
        workService,
      );
    }

    return true;
  }

  Future<void> _updateParentTaskStatus(
      String workId,
      dynamic workShift,
      List<WorkFieldModel> listWorkField,
      WorkingService workService,
      ) async {
    final listSubWork = await workService.getWorkingUnitByIdParent(workId);

    int cnt = 0;
    int process = 0;
    int mandatoryStatus = -9;

    if (listSubWork.isNotEmpty) {
      for (var sW in listSubWork) {
        int status = sW.status;

        final workk =
            listWorkField.where((item) => item.taskId == sW.id).firstOrNull;
        if (workk != null) {
          status = workk.toStatus;
        }

        if (sW.owner.isEmpty &&
            (status == StatusWorkingDefine.cancelled.value ||
                status == StatusWorkingDefine.failed.value)) {
          mandatoryStatus = status;
        }

        if (status == StatusWorkingDefine.cancelled.value) continue;

        cnt++;
        if (status == StatusWorkingDefine.done.value) {
          process++;
        }
      }
    }

    WorkFieldModel? newWF;
    WorkFieldModel? oldModel;
    final newId =
        FirebaseFirestore.instance.collection('whms_pls_work_field').doc().id;

    // Determine new status
    int? newStatus;
    if (mandatoryStatus != -9) {
      newStatus = mandatoryStatus;
    } else if (cnt == process && cnt > 0) {
      newStatus = StatusWorkingDefine.done.value;
    } else if (cnt > 0) {
      newStatus = StatusWorkingDefine.processing.value + (process * 100) ~/ cnt;
    }

    if (newStatus != null) {
      final workUnit = await workService.getWorkingUnitByIdIgnoreClosed(workId);
      if (workUnit != null) {
        cfC.updateWorkingUnit(
            workUnit.copyWith(status: newStatus), workUnit);

        // Update or create work field
        newWF = await workService.getWorkFieldByWorkShiftAndIdWork(
            workShift.id, workUnit.id);

        if (newWF != null) {
          oldModel = newWF.copyWith();
          newWF = newWF.copyWith(toStatus: newStatus);
        } else {
          newWF = WorkFieldModel(
            id: newId,
            taskId: workUnit.id,
            fromStatus: workUnit.status,
            toStatus: newStatus,
            date: DateTimeUtils.getCurrentDate(),
            workShift: workShift.id,
            enable: true,
          );
        }

        if (newWF.id == newId) {
          cfC.addWorkField(newWF);
        } else {
          cfC.updateWorkField(newWF, oldModel!);
        }
      }
    }
  }
}