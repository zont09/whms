import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/hr/bloc/hr_tab_cubit.dart';
import 'package:whms/features/home/hr/views/task_popup_view.dart';
import 'package:whms/features/home/main_tab/widgets/personal/personal_task_widget.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

import '../../checkin/widgets/history_card_widget.dart';

class PersonalHrView extends StatelessWidget {
  const PersonalHrView(
      {super.key,
      required this.item,
      required this.cubit,
      this.assignees,
      required this.isShowAssignees,});

  final MapEntry<WorkingUnitModel, List<WorkingUnitModel>> item;
  final HrTabCubit cubit;
  final Map<String, UserModel>? assignees;
  final bool isShowAssignees;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [17, 2, 2, 1];
    return Column(
      children: [
        Container(
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(6, context)),
                color: ColorConfig.primary3,
                boxShadow: const [ColorConfig.boxShadow2]),
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(12, context),
                vertical: ScaleUtils.scaleSize(4, context)),
            child: Row(
              children: [
                Expanded(
                    flex: weight[0],
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(2.5, context)),
                      child: Text(
                        item.key.title,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(16, context),
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    )),
                Expanded(
                    flex: weight[1],
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(2.5, context)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CardView(
                            content:
                                "${cubit.mapTaskSumDataGroup[item.key]?['workingPoint'] ?? 0} điểm",
                            borderColor: Colors.white,
                            textColor: Colors.white,
                            background: ColorConfig.primary3,
                          ),
                        ],
                      ),
                    )),
                Expanded(
                    flex: weight[2],
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(2.5, context)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: ScaleUtils.scaleSize(26, context),
                                width: ScaleUtils.scaleSize(26, context),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: ScaleUtils.scaleSize(1, context),
                                        color: Colors.white)),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                      "${cubit.mapTaskSumDataGroup[item.key]?['numOfSubtask'] ?? 0}",
                                      style: TextStyle(
                                          fontSize:
                                              ScaleUtils.scaleSize(12, context),
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white)),
                                ))
                          ]),
                    )),
                if (assignees != null)
                  Expanded(flex: weight[3], child: const SizedBox.shrink()),
              ],
            )),
        const ZSpace(h: 9),
        ...item.value.map(
          (e) => Column(
            children: [
              PersonalTaskWidget(
                isShowAssignees: isShowAssignees,
                assignees: assignees != null && e.assignees.isNotEmpty
                    ? assignees![e.assignees.first]
                    : null,
                isInHrTab: true,
                work: e,
                address: cubit.mapAddress[e.id],
                subTask: cubit.mapWorkChild[e.id] ?? 0,
                showDetailTask: () async {
                  DialogUtils.showLoadingDialog(context);
                  // await cubitHr.getDataUser(data.task.assignees);
                  await cubit.getDataTaskChildAndUser(e.id, e.assignees);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                  DialogUtils.showAlertDialog(context,
                      child: TaskPopupView(
                          task: e,
                          subtasks: cubit.mapTaskChild[e.id] != null
                              ? cubit.mapTaskChild[e.id]!
                              : [],
                          assignees: e.assignees
                              .map((e) => cubit.mapUserModel[e])
                              .where((e) => e != null)
                              .cast<UserModel>()
                              .toList(),
                          listScopes: cubit.listScope));
                },
              ),
              const ZSpace(h: 5)
            ],
          ),
        ),
        const ZSpace(h: 18),
      ],
    );
  }
}
