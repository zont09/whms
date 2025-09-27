import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/create_sub_task_cubit.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/services/working_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class BottomButton extends StatelessWidget {
  const BottomButton(
      {super.key,
      required this.cubit,
      required this.endEvent,
      required this.workPar,
      required this.subtask,
      this.isDefaultTask = false,
      required this.isTaskToday,
      required this.addSubtask,
      required this.updateSubtask,
      this.updateWF});

  final CreateSubTaskCubit cubit;
  final Function() endEvent;
  final WorkingUnitModel workPar;
  final WorkingUnitModel? subtask;
  final bool isTaskToday;
  final bool isDefaultTask;
  final Function(WorkingUnitModel)? addSubtask;
  final Function(WorkingUnitModel)? updateSubtask;
  final Function(WorkFieldModel)? updateWF;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ZButton(
            title: AppText.btnCancel.text,
            icon: "",
            colorTitle: ColorConfig.primary2,
            colorBackground: Colors.transparent,
            colorBorder: Colors.transparent,
            fontWeight: FontWeight.w600,
            sizeTitle: 16,
            onPressed: () {
              Navigator.of(context).pop();
            }),
        SizedBox(width: ScaleUtils.scaleSize(12, context)),
        ZButton(
            title: subtask == null
                ? AppText.btnCreateTask.text
                : AppText.btnUpdateTask.text,
            icon: "",
            sizeTitle: 16,
            paddingVer: 7,
            paddingHor: 16,
            onPressed: () async {
              if (cubit.conName.text.isEmpty) {
                DialogUtils.showResultDialog(context, AppText.textHasError.text,
                    AppText.textLackOfInformation.text);
                return;
              }
              bool isSuccess = false;
              await DialogUtils.handleDialog(context, () async {
                try {
                  final user = ConfigsCubit.fromContext(context).user;
                  WorkingUnitModel newSubtask = WorkingUnitModel(
                    id: subtask == null
                        ? FirebaseFirestore.instance
                            .collection('whms_pls_working_unit')
                            .doc()
                            .id
                        : subtask!.id,
                    title: cubit.conName.text,
                    description: cubit.conDes.text,
                    duration: cubit.workingTime,
                    owner: subtask == null ? user.id : subtask!.owner,
                    priority: workPar.priority,
                    type: TypeAssignmentDefine.subtask.title,
                    // scopes: workPar.scopes,
                    status: subtask == null
                        ? StatusWorkingDefine.none.value
                        : subtask!.status,
                    assignees: workPar.assignees,
                    assigneesPending: workPar.assigneesPending,
                    parent: workPar.id,
                    createAt:
                        subtask == null ? Timestamp.now() : subtask!.createAt,
                  );
                  if (subtask == null) {
                    cfC.addWorkingUnit(newSubtask);
                    // await WorkingService.instance.addNewWorkingUnit(newSubtask);
                    if (addSubtask != null) {
                      addSubtask!(newSubtask);
                    }
                  } else {
                    cfC.updateWorkingUnit(newSubtask, subtask!);
                    // await WorkingService.instance
                    //     .updateWorkingUnitField(newSubtask, subtask!, userCf);
                    if (updateSubtask != null) {
                      updateSubtask!(newSubtask);
                    }
                    // if (isDefaultTask) {
                    //   await WorkingService.instance.updateWorkingUnit(
                    //       newSubtask.copyWith(status: cubit.status));
                    // }
                  }
                  if (isTaskToday) {
                    final workShift = await UserServices.instance
                        .getWorkShiftByIdUserAndDate(
                            user.id, DateTimeUtils.getCurrentDate());
                    if (workShift != null) {
                      final workField = await WorkingService.instance
                          .getWorkFieldByWorkShiftAndIdWork(
                              workShift.id, newSubtask.id);
                      if (workField != null) {
                        cfC.updateWorkField(workField.copyWith(toStatus: cubit.status), workField);
                        // await WorkingService.instance.updateWorkField(
                        //     workField.copyWith(toStatus: cubit.status));
                      } else {
                        final newWF = WorkFieldModel(
                            id: FirebaseFirestore.instance
                                .collection('whms_pls_work_field')
                                .doc()
                                .id,
                            taskId: newSubtask.id,
                            fromStatus: newSubtask.status,
                            toStatus: newSubtask.status,
                            duration: newSubtask.duration,
                            date: DateTimeUtils.getCurrentDate(),
                            workShift: workShift.id,
                            enable: true);
                        cfC.addWorkField(newWF);
                        // await WorkingService.instance.addNewWorkField(newWF);
                        if (updateWF != null) {
                          updateWF!(newWF);
                        }
                      }
                      endEvent();
                    }
                  }
                  isSuccess = true;
                  return ResponseModel(status: ResponseStatus.ok, results: "");
                } catch (e) {
                  return ResponseModel(
                      status: ResponseStatus.error,
                      error: ErrorModel(text: e.toString()));
                }
              }, () {},
                  successMessage: AppText.titleSuccess.text,
                  successTitle: AppText.titleSuccess.text,
                  failedMessage: AppText.titleFailed.text,
                  failedTitle: AppText.textFailed.text,
                  isShowDialogSuccess: false);
              if (isSuccess && context.mounted) {
                // endEvent();
                // try {
                //   if(context.mounted) {
                //     var cubitMT = BlocProvider.of<MainTabCubit>(context);
                //     cubitMT.initData(context);
                //   }
                // }catch(e){
                //   debugPrint("xxxxxxxxxxxx Failed");
                // }
                Navigator.of(context).pop();
              }
            }),
      ],
    );
  }
}
