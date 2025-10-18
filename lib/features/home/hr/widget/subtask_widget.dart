import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';
import 'package:whms/widgets/time_card.dart';

class SubtaskWidget extends StatelessWidget {
  const SubtaskWidget({super.key, required this.subtask});

  final WorkingUnitModel subtask;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [8, 2, 2];
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
          color: Colors.white,
          boxShadow: const [ColorConfig.boxShadow2]),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(12, context),
          vertical: ScaleUtils.scaleSize(8, context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: weight[0],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(2.5, context)),
                      child: Text(
                        subtask.title,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(14, context),
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
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [StatusCard(status: subtask.status)],
                ),
              )),
          Expanded(
              flex: weight[2],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TimeCard(
                        time: DateTimeUtils.formatDuration(subtask.duration))
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
