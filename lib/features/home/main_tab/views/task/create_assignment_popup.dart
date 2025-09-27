import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/defines/type_assignment_define.dart';
import 'package:whms/features/home/main_tab/blocs/assignment_popup_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/task/create_assignment_form.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/convert_utils.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/two_buttons.dart';

class CreateAssignmentPopup extends StatelessWidget {
  final WorkingUnitModel selectedWorking;
  final List<String> assignees;
  final List<String> scopes;
  final bool isSub;
  final bool isSubTask;
  final bool isEdit;
  final String userId;
  final int typeAssignment;
  final Function(WorkingUnitModel) reload;
  final Function(WorkingUnitModel)? edited;
  final Function(WorkingUnitModel)? endEvent;
  final List<String> ancestries;

  const CreateAssignmentPopup(
      {this.isSub = false,
      required this.selectedWorking,
      required this.assignees,
      required this.userId,
      required this.scopes,
      required this.reload,
      required this.typeAssignment,
      this.isEdit = false,
      this.isSubTask = false,
      this.edited,
      this.endEvent,
      this.ancestries = const [],
      super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            AssignmentPopupCubit(isSubTask, ConfigsCubit.fromContext(context))
              ..load(isSubTask, typeAssignment,
                  model: isEdit ? selectedWorking : null),
        child: BlocBuilder<AssignmentPopupCubit, int>(builder: (c, s) {
          var cubit = BlocProvider.of<AssignmentPopupCubit>(c);
          return SizedBox(
              key: Key(selectedWorking.id),
              width: ScaleUtils.scaleSize(600, context),
              height: ScaleUtils.scaleSize(550, context),
              child: Stack(children: [
                CreateAssignmentForm(
                    isSub: isSub,
                    ancestries: ancestries,
                    cubit: cubit,
                    isSubtask: isSubTask,
                    typeAssignment: typeAssignment),
                Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.only(
                        right: ScaleUtils.scalePadding(30, context),
                        bottom: ScaleUtils.scalePadding(30, context)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TwoButtons(
                              titleCancel: AppText.btnCancel.text,
                              titleOK: isEdit
                                  ? AppText.btnUpdate.text
                                  : AppText.btnCreateAssignment.text.replaceAll(
                                      '@',
                                      cubit.selectedType.title.toLowerCase()),
                              onCancel: () => Navigator.pop(context),
                              onOK: () async {
                                if (isEdit) {
                                  await cubit.updateAssignment(
                                      selectedWorking, c);
                                  var working = selectedWorking.copyWith(
                                      title: cubit.conName.text,
                                      description: cubit.conDes.text,
                                      workingPoint: cubit.selectedWP,
                                      // okr: ConvertUtils.convertScopeToString(cubit.selectedScopeOkrs),
                                      priority: cubit.selectedPriority.title,
                                      urgent: DateTimeUtils.getTimestampWithDay(
                                          DateTimeUtils.convertToDateTime(
                                              cubit.conExecuteDate.text)),
                                      deadline:
                                          DateTimeUtils.getTimestampWithDay(
                                              DateTimeUtils.convertToDateTime(
                                                  cubit.conEndDate.text)),
                                      start: DateTimeUtils.getTimestampWithDay(
                                          DateTimeUtils.convertToDateTime(
                                              cubit.conStartDate.text)));
                                  if (edited != null) {
                                    edited!(working);
                                  }
                                } else {
                                  final work = await cubit.createNewAssignment(
                                      selectedWorking,
                                      assignees,
                                      scopes,
                                      userId,
                                      isSub,
                                      reload: reload,
                                      c);
                                  if (endEvent != null) {
                                    endEvent!(work);
                                  }
                                  // reload();
                                }
                              })
                        ]))
              ]));
        }));
  }
}
