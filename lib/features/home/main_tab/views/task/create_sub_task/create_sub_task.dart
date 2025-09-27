import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/create_sub_task_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/create_sub_task/bottom_button.dart';
import 'package:whms/features/home/main_tab/views/task/create_sub_task/header_view.dart';
import 'package:whms/features/home/main_tab/views/task/create_sub_task/setting_view.dart';
import 'package:whms/models/work_field_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/format_text_field/format_text_field.dart';
import 'package:whms/widgets/format_text_field/format_text_view.dart';

import '../../../../../../widgets/textfield_custom_2.dart';

class CreateSubTask extends StatelessWidget {
  const CreateSubTask(
      {super.key,
      required this.address,
      required this.work,
      required this.canEditDefaultTask,
      required this.isTaskToday,
      this.subtask,
      this.isEdit = true,
      this.isToday = true,
      // required this.initData,
      required this.updateSubtask,
      this.addSubtask,
      this.updateWF});

  final List<WorkingUnitModel> address;
  final WorkingUnitModel work;

  // final SubTaskCubit cubitST;
  final bool canEditDefaultTask;
  final WorkingUnitModel? subtask;
  final bool isEdit;
  final bool isToday;
  final bool isTaskToday;
  // final Function(WorkingUnitModel, bool, BuildContext, UserModel) initData;
  final Function(WorkingUnitModel) updateSubtask;
  final Function(WorkingUnitModel)? addSubtask;
  final Function(WorkFieldModel)? updateWF;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
        child: BlocProvider(
            create: (context) => CreateSubTaskCubit()..initData(subtask),
            child: BlocBuilder<CreateSubTaskCubit, int>(builder: (c, s) {
              var cubit = BlocProvider.of<CreateSubTaskCubit>(c);
              return Container(
                  // height: ScaleUtils.scaleSize(418, context),
                  width: ScaleUtils.scaleSize(704, context),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          ScaleUtils.scaleSize(12, context)),
                      color: Colors.white),
                  child: Stack(children: [
                    Positioned(
                      right: ScaleUtils.scaleSize(15, context),
                      top: ScaleUtils.scaleSize(15, context),
                      child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Image.asset(
                              'assets/images/icons/ic_close_check_in.png',
                              height: ScaleUtils.scaleSize(16, context))),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.all(ScaleUtils.scaleSize(32, context)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HeaderView(
                                address: address,
                                isEdit: isEdit,
                                isDetail: subtask != null,
                              ),
                              SizedBox(
                                  height: ScaleUtils.scaleSize(5, context)),
                              Text(AppText.titleNameTask.text,
                                  style: TextStyle(
                                      fontSize:
                                          ScaleUtils.scaleSize(16, context),
                                      fontWeight: FontWeight.w500,
                                      color: ColorConfig.textColor6,
                                      letterSpacing: -0.41,
                                      shadows: const [ColorConfig.textShadow])),
                              SizedBox(
                                  height: ScaleUtils.scaleSize(5, context)),
                              TextFieldCustom(
                                  controller: cubit.conName,
                                  isEdit: isEdit &&
                                      (subtask == null ||
                                          subtask!.owner.isNotEmpty),
                                  hint: AppText.textCreateNameForTask.text),
                              SizedBox(
                                  height: ScaleUtils.scaleSize(8, context)),
                              Text(AppText.titleDescription.text,
                                  style: TextStyle(
                                      fontSize:
                                          ScaleUtils.scaleSize(16, context),
                                      fontWeight: FontWeight.w500,
                                      color: ColorConfig.textColor6,
                                      letterSpacing: -0.41,
                                      shadows: const [ColorConfig.textShadow])),
                              SizedBox(
                                  height: ScaleUtils.scaleSize(5, context)),
                              if (isEdit &&
                                  (subtask == null ||
                                      subtask!.owner.isNotEmpty))
                                FormatTextField(
                                  initialContent: cubit.conDes.text,
                                  onContentChanged: (v) {
                                    cubit.conDes.text = v;
                                  },
                                  fixedLines: 10,
                                ),
                              if (!(isEdit &&
                                  (subtask == null ||
                                      subtask!.owner.isNotEmpty)))
                                FormatTextView(content: cubit.conDes.text),
                              // TextFieldCustom(
                              //     isEdit: isEdit && (subtask == null || subtask!.owner.isNotEmpty),
                              //     controller: cubit.conDes,
                              //     hint: AppText.textTaskDescription.text,
                              //     radius: 11,
                              //     minLines: 5),
                              SizedBox(
                                  height: ScaleUtils.scaleSize(8, context)),
                              SettingView(
                                isTaskToday: isTaskToday,
                                work: subtask,
                                canEditDefault: canEditDefaultTask &&
                                    subtask != null &&
                                    subtask!.owner.isEmpty,
                                initTime: cubit.workingTime,
                                onChanged: (value) {
                                  cubit.changeWorkingTime(value);
                                },
                                onChangedStatus: (value) {
                                  cubit.changeWorkStatus(value);
                                  updateSubtask(work.copyWith(status: value));
                                },
                                isEdit: isEdit,
                              ),
                              if (isEdit)
                                BottomButton(
                                    isDefaultTask: canEditDefaultTask &&
                                        subtask != null &&
                                        subtask!.owner.isEmpty,
                                    isTaskToday: isTaskToday,
                                    subtask: subtask,
                                    cubit: cubit,
                                    endEvent: () {
                                      // initData(work, isToday, context, user);
                                    },
                                    updateWF: updateWF,
                                    addSubtask: addSubtask,
                                    updateSubtask: updateSubtask,
                                    workPar: work)
                            ]))
                  ]));
            })));
  }
}
