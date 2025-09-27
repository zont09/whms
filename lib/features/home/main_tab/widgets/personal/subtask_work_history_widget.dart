import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/widgets/status_card.dart';
import 'package:whms/features/home/main_tab/blocs/work_history_cubit.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class SubtaskWorkHistoryWidget extends StatefulWidget {
  const SubtaskWorkHistoryWidget({super.key, required this.data});

  final WorkHistorySynthetic data;

  @override
  State<SubtaskWorkHistoryWidget> createState() => _SubtaskWorkHistoryWidgetState();
}

class _SubtaskWorkHistoryWidgetState extends State<SubtaskWorkHistoryWidget> {
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [16, 6, 6, 6, 1];
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(0, context),
          vertical: ScaleUtils.scaleSize(12, context)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  flex: weight[0],
                  child: Text(
                    widget.data.work.title,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(14, context),
                        fontWeight: FontWeight.w500,
                        color: ColorConfig.textColor,
                        overflow: TextOverflow.ellipsis,
                        letterSpacing: -0.02),
                    maxLines: 3,
                  )),

              Expanded(
                  flex: weight[1],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CardView(content: DateTimeUtils.formatDuration(widget.data.workingTime)),
                    ],
                  )),
              Expanded(
                  flex: weight[2],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusCard(status: widget.data.fromStatus)
                    ],
                  )),
              Expanded(
                  flex: weight[3],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusCard(status: widget.data.toStatus)
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class CardView extends StatelessWidget {
  const CardView(
      {super.key, required this.content, this.background = Colors.white});

  final String content;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(ScaleUtils.scaleSize(20, context)),
            border: Border.all(
                width: ScaleUtils.scaleSize(1, context),
                color: ColorConfig.border4),
            color: background),
        padding: EdgeInsets.symmetric(
            horizontal: ScaleUtils.scaleSize(11, context),
            vertical: ScaleUtils.scaleSize(2, context)),
        child: Text(
          content.isEmpty ? "-" : content,
          style: TextStyle(
              fontSize: ScaleUtils.scaleSize(12, context),
              fontWeight: FontWeight.w500,
              color: ColorConfig.textColor),
        ),
      ),
    );
  }
}

class WorkHistoryData {
  final String date;
  final String logTime;
  final String workingPoint;
  final int numOfTask;
  final String checkIn;
  final String checkOut;
  final String sumBreak;
  final Color background;

  WorkHistoryData(this.date, this.logTime, this.workingPoint, this.numOfTask,
      this.checkIn, this.checkOut, this.sumBreak, this.background);
}
