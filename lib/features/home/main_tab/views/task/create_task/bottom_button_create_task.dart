import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/create_task_cubit.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class BottomButtonCreateTask extends StatelessWidget {
  const BottomButtonCreateTask(
      {super.key,
      required this.cubit,
      required this.endEvent,
      required this.onAdd});

  final CreateTaskCubit cubit;
  final Function() endEvent;
  final Function(WorkingUnitModel) onAdd;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
          title: AppText.btnCreateTask.text,
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
            if (cubit.workSelected == null) {
              DialogUtils.showResultDialog(context, AppText.textHasError.text,
                  AppText.titlePleaseChooseTask.text);
              return;
            }
            bool isSuccess = false;
            String idWork = FirebaseFirestore.instance
                .collection('whms_pls_working_unit')
                .doc()
                .id;
            final user = ConfigsCubit.fromContext(context).user;
            WorkingUnitModel newSubtask = WorkingUnitModel(
              id: idWork,
              title: cubit.conName.text,
              description: cubit.conDes.text,
              duration: cubit.workingTime,
              owner: user.id,
              priority: cubit.workSelected!.priority,
              type: TypeAssignmentDefine.subtask.title,
              status: StatusWorkingDefine.none.value,
              assignees: [user.id],
              parent: cubit.workSelected!.id,
              createAt: Timestamp.now(),
            );
            await DialogUtils.handleDialog(context, () async {
              try {
                ConfigsCubit.fromContext(context).addWorkingUnit(newSubtask);
                onAdd(newSubtask);
                // await WorkingService.instance.addNewWorkingUnit(newSubtask);
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
              final user = ConfigsCubit.fromContext(context).user;
              final workShift = await UserServices.instance
                  .getWorkShiftByIdUserAndDate(
                      user.id, DateTimeUtils.getCurrentDate());
              if (workShift != null) {
                final newWorkField = WorkFieldModel(
                  id: FirebaseFirestore.instance
                      .collection('whms_pls_work_field')
                      .doc()
                      .id,
                  taskId: idWork,
                  fromStatus: newSubtask.status,
                  toStatus: newSubtask.status,
                  date: DateTimeUtils.getCurrentDate(),
                  workShift: workShift.id,
                );
                cfC.addWorkField(newWorkField);
                // await WorkingService.instance.addNewWorkField(newWorkField);
              }
              endEvent();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          })
    ]);
  }
}
