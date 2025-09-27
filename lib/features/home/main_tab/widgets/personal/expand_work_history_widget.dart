import 'package:whms/features/home/main_tab/blocs/work_history_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/personal/header_task_history.dart';
import 'package:whms/features/home/main_tab/widgets/personal/work_history_widget.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class ExpandWorkHistoryWidget extends StatelessWidget {
  const ExpandWorkHistoryWidget({super.key, required this.cubit, required this.date});

  final WorkHistoryCubit cubit;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: ScaleUtils.scaleSize(20, context)),
    child: Column(
      children: [
        const HeaderTaskHistory(),
        SizedBox(height: ScaleUtils.scaleSize(10, context)),
        ...cubit.mapHistoryTask[date]!.map((item) =>
          Column(
            children: [
              WorkHistoryWidget(data: item),
              SizedBox(height: ScaleUtils.scaleSize(8, context))
            ],
          )
        )
      ],
    ),);
  }
}
