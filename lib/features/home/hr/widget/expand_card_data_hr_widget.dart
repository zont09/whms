import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/priority_level_define.dart';
import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/features/home/hr/bloc/hr_tab_cubit.dart';
import 'package:whms/features/home/hr/views/task_popup_view.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/untils/text_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../main_tab/widgets/personal/history_card_widget.dart';
import 'card_data_widget.dart';

class ExpandCardDataHrWidget extends StatelessWidget {
  const ExpandCardDataHrWidget(
      {super.key, required this.weight, required this.listData});

  final List<int> weight;
  final List<HrTaskModel> listData;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HrTabCubit, int>(
      builder: (c, s) {
        var cubitHr = BlocProvider.of<HrTabCubit>(c);
        return Container(
          padding: EdgeInsets.symmetric(
                  // horizontal: ScaleUtils.scaleSize(16, context),
                  vertical: ScaleUtils.scaleSize(12, context))
              .copyWith(top: ScaleUtils.scaleSize(20, context)),
          child: Column(
            children: [
              ...listData.map(
                (data) => Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        // DialogUtils.showLoadingDialog(context);
                        // await cubitHr.getDataUser(data.task.assignees);
                        // // await cubitHr.getDataTaskChild(data.task.id);
                        // if(context.mounted) {
                        //   Navigator.of(context).pop();
                        // }
                        DialogUtils.showLoadingDialog(context);
                        // await cubitHr.getDataUser(data.task.assignees);
                        await cubitHr.getDataTaskChildAndUser(
                            data.task.id, data.task.assignees);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        DialogUtils.showAlertDialog(context,
                            child: TaskPopupView(
                                task: data.task,
                                subtasks:
                                    cubitHr.mapTaskChild[data.task.id] != null
                                        ? cubitHr.mapTaskChild[data.task.id]!
                                        : [],
                                assignees: data.task.assignees
                                    .map((e) => cubitHr.mapUserModel[e])
                                    .where((e) => e != null)
                                    .cast<UserModel>()
                                    .toList(),
                                listScopes: cubitHr.listScope));
                      },
                      child: Row(
                        children: [
                          Expanded(
                              flex: weight[0],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        data.task.title,
                                        style: TextStyle(
                                            fontSize: ScaleUtils.scaleSize(
                                                14, context),
                                            fontWeight: FontWeight.w500,
                                            color: ColorConfig.textColor,
                                            letterSpacing: -0.02,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  )
                                ],
                              )),
                          Expanded(
                              flex: weight[1],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (data.status >= -1)
                                    StatusCard(status: data.status),
                                  if (data.status == -2) CardView(content: "-"),
                                ],
                              )),
                          Expanded(
                              flex: weight[2],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CardView(
                                      content: DateTimeUtils.formatDuration(
                                          data.workingTime)),
                                ],
                              )),
                          Expanded(
                              flex: weight[3],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Tooltip(
                                      message: data.task.priority,
                                      child: CircleAvatar(
                                          backgroundColor:
                                              PriorityLevelExtension.convertToPriority(
                                                      data.task.priority)
                                                  .background,
                                          radius:
                                              ScaleUtils.scaleSize(12, context),
                                          child: Text(
                                              TextUtils.firstCharInString(
                                                  data.task.priority),
                                              style: TextStyle(
                                                  color: PriorityLevelExtension.convertToPriority(
                                                          data.task.priority)
                                                      .color,
                                                  fontSize: ScaleUtils.scaleSize(10, context))))),
                                ],
                              )),
                          Expanded(
                              flex: weight[4],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CardView(
                                      content: "${data.workingPoint} điểm"),
                                ],
                              )),
                          Expanded(
                              flex: weight[5],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (data.users.isNotEmpty)
                                    Tooltip(
                                      message: data.users.first.name,
                                      child: AvatarItem(data.users.first.avt),
                                    )
                                ],
                              )),
                        ],
                      ),
                    ),
                    const ZSpace(h: 9)
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
