import 'package:whms/configs/color_config.dart';
import 'package:whms/models/user_overview_data.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/avatar_item.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

import '../../checkin/widgets/history_card_widget.dart';

class CardHrDataWidget extends StatelessWidget {
  const CardHrDataWidget({super.key, required this.data, required this.weight});

  final UserOverviewData data;
  final List<int> weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
          color: Colors.white,
          boxShadow: const [ColorConfig.boxShadow2]),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(16, context),
          vertical: ScaleUtils.scaleSize(8, context)),
      child: Row(
        children: [
          Expanded(
              flex: weight[0],
              child: Row(
                children: [
                  AvatarItem(data.user.avt, size: 30),
                  const ZSpace(w: 4),
                  Expanded(
                      child: Text(
                    data.user.name,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w500,
                        color: ColorConfig.textColor,
                        overflow: TextOverflow.ellipsis),
                  ))
                ],
              )),
          Expanded(
              flex: weight[1],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CardView(content: DateTimeUtils.formatDuration(data.logTime)),
                ],
              )),
          Expanded(
              flex: weight[2],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CardView(content: "${data.workingPoint} điểm"),
                ],
              )),
          Expanded(
              flex: weight[3],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CardView(
                      content:
                          "${data.taskDone + data.taskDoing + data.taskOther} nhiệm vụ"),
                ],
              )),
          Expanded(
              flex: weight[4],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CardView(
                      content: DateTimeUtils.formatDuration(data.workingTime)),
                ],
              )),
        ],
      ),
    );
  }
}
