
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/features/home/main_tab/blocs/main_tab_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/task_main_view_cubit.dart';
import 'package:whms/features/home/main_tab/views/task/detail_task_view/detail_assignment_view.dart';
import 'package:whms/features/home/main_tab/views/task/sub_task_view.dart';
import 'package:whms/features/home/main_tab/views/task/task_popup_view.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/convert_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class DetailTaskView extends StatelessWidget {
  const DetailTaskView(
      {super.key,
        required this.work,
        required this.cubit,
        required this.tab,
        required this.cubitMT});

  final TaskMainViewCubit cubit;
  final MainTabCubit cubitMT;
  final WorkingUnitModel work;
  final String tab;

  @override
  Widget build(BuildContext context) {
    final user = ConfigsCubit.fromContext(context).user;
    final configCubit = ConfigsCubit.fromContext(context);
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(14, context)),
        border: Border.all(
            width: ScaleUtils.scaleSize(1, context),
            color: ColorConfig.border5),
        boxShadow: [
          BoxShadow(
            offset: const Offset(1, 1),
            blurRadius: 5.9,
            spreadRadius: 0,
            color: const Color(0xFF000000).withOpacity(0.16),
          ),
        ],
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(
          vertical: ScaleUtils.scaleSize(5, context),
          horizontal: ScaleUtils.scaleSize(5, context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 504,
              child: SingleChildScrollView(
                child: DetailAssignmentView(
                  userCf: user,
                  cfC: configCubit,
                  onDoToday: (v) {
                    cubitMT.listToday.add(v);
                    cubitMT.taskToday++;
                    cubit.cntUpdateTask++;
                    cubit.EMIT();
                    cubitMT.EMIT();
                  },
                  onRemoveToday: (v) {
                    cubitMT.listToday.remove(v);
                    cubitMT.taskToday--;
                    cubit.cntUpdateTask++;
                    cubit.EMIT();
                    cubitMT.EMIT();
                  },
                  onDoing: (v) {
                    cubitMT.listDoing.add(v.copyWith(
                        status: StatusWorkingDefine.processing.value));
                    cubitMT.updateWorkingUnit(v.copyWith(
                        status: StatusWorkingDefine.processing.value));
                    cubit.updateTask(v.copyWith(
                        status: StatusWorkingDefine.processing.value));
                    cubit.cntUpdateTask++;
                    cubitMT.taskDoing++;
                    cubit.EMIT();
                    cubitMT.EMIT();
                  },
                  onUpdate: (v, o) {
                    // cubitMT.updateWorkingUnit(v);
                    configCubit.updateWorkingUnit(v, o);
                    // WorkingService.instance
                    //     .updateWorkingUnitField(v, o, user.id);
                    // cubit.updateTask(v);
                  },
                  work,
                  [user],
                  ConvertUtils.convertStringToScope(
                      work, cubit.listAllScope, []),
                  endEvent: () {},
                  call: (v) {
                    cubit.updateWorkingUnit(work.copyWith(title: v));
                  },
                  reload: (v) async {
                    // cubitMT.initData(context);
                  },
                  isTaskToday:
                  cubitMT.listToday.any((e) => e.id == work.id) ? 1 : 2,
                  onTapPath: (v) async {
                    DialogUtils.showLoadingDialog(context);
                    // await cubitHr.getDataUser(data.task.assignees);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    DialogUtils.showAlertDialog(context,
                        child: TaskPopupView(
                            task: v,
                            subtasks: [],
                            assignees: v.assignees
                                .map((e) => configCubit.usersMap[e])
                                .where((e) => e != null)
                                .cast<UserModel>()
                                .toList(),
                            listScopes: cubit.listScope));
                  },
                  listPath: cubitMT.mapAddress[work.id] ?? [],
                ),
              )),
          SizedBox(width: ScaleUtils.scaleSize(18, context)),
          Expanded(
              flex: 232,
              child: SubTaskView(
                user: user,
                mapWorkChild: cubitMT.mapWorkChild,
                mapWorkField: cubitMT.mapWorkFieldfTask,
                work: work,
                tab: tab,
                cubitMV: cubit,
                isTaskToday: cubitMT.listToday.any((e) => e.id == work.id),
                cntUpdate: cubit.cntUpdateTask,
                onUpdateWF: (v) {
                  cubitMT.updateWorkFieldfTask(v);
                },
              )),
        ],
      ),
    );
  }
}
