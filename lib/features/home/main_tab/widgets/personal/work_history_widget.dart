import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/work_history_cubit.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

import '../../../checkin/widgets/history_card_widget.dart';

class WorkHistoryWidget extends StatelessWidget {
  const WorkHistoryWidget({super.key, required this.data});

  final HistoryTaskModel data;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [6, 2, 2, 2];
    return Row(
      children: [
        Expanded(
            flex: weight[0],
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(2.5, context)),
              child: Text(
                data.work.title,
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(14, context),
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.02,
                    color: ColorConfig.textColor,
                    overflow: TextOverflow.ellipsis),
                maxLines: 2,
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
                  CardView(content: "${data.workingPoint} điểm"),
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
                  CardView(
                      content: DateTimeUtils.formatDuration(data.workingTime)),
                ],
              ),
            )),
        Expanded(
            flex: weight[3],
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(2.5, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CardView(content: "${data.subtask}"),
                ],
              ),
            )),
      ],
    );
  }
}
