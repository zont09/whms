import 'package:whms/features/home/main_tab/blocs/work_history_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/personal/header_sub_task.dart';
import 'package:whms/features/home/main_tab/widgets/personal/subtask_work_history_widget.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class ExpandWorkHistoryTaskWidget extends StatelessWidget {
  const ExpandWorkHistoryTaskWidget({super.key, required this.cubit, required this.work});

  final WorkHistoryCubit cubit;
  final WorkHistorySynthetic work;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ScaleUtils.scaleSize(20, context)),
      child: Column(
        children: [
          const HeaderSubTask(),
          SizedBox(height: ScaleUtils.scaleSize(4, context)),
          ...cubit.mapChildWHS[work.work.id]!.map((item) =>
              Column(
                children: [
                  SubtaskWorkHistoryWidget(data: item),
                  SizedBox(height: ScaleUtils.scaleSize(2, context))
                ],
              )
          )
        ],
      ),);
  }
}
