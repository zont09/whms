import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/widgets/task/subtask_widget.dart';
import 'package:whms/models/scope_model.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/invisible_scroll_bar_widget.dart';
import 'package:whms/widgets/z_space.dart';

class TaskPopupView extends StatelessWidget {
  const TaskPopupView(
      {super.key,
      required this.task,
      required this.subtasks,
      required this.assignees,
      required this.listScopes});

  final WorkingUnitModel task;
  final List<UserModel> assignees;
  final List<ScopeModel> listScopes;
  final List<WorkingUnitModel> subtasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(800, context),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
            child: ScrollConfiguration(
                behavior: InvisibleScrollBarWidget(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // DetailAssignmentView(task, assignees, listScopes,
                      //     userCf: ConfigsCubit.fromContext(context).user,
                      //     cfC: ConfigsCubit.fromContext(context),
                      //     reload: (v) {}),
                      const ZSpace(h: 9),
                      if (subtasks.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: ScaleUtils.scaleSize(20, context)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppText.titleListSubtask.text,
                                  style: TextStyle(
                                      fontSize:
                                          ScaleUtils.scaleSize(16, context),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing:
                                          ScaleUtils.scaleSize(-0.33, context),
                                      color: ColorConfig.textColor)),
                              const ZSpace(h: 9),
                              ...subtasks.map((item) => Column(
                                    children: [
                                      SubtaskWidget(subtask: item),
                                      const ZSpace(
                                        h: 5,
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        )
                    ],
                  ),
                )),
          ),
          Positioned(
            top: ScaleUtils.scaleSize(20, context),
            right: ScaleUtils.scaleSize(20, context),
            child: InkWell(
              onTap: () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Image.asset('assets/images/icons/ic_close_check_in.png',
                  height: ScaleUtils.scaleSize(16, context)),
            ),
          )
        ],
      ),
    );
  }
}
