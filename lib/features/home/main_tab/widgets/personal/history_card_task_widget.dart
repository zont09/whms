import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/work_history_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/personal/expand_work_history_task_widget.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class HistoryCardTaskWidget extends StatefulWidget {
  const HistoryCardTaskWidget({super.key, required this.data, required this.cubit});

  final WorkHistorySynthetic data;
  final WorkHistoryCubit cubit;

  @override
  State<HistoryCardTaskWidget> createState() => _HistoryCardTaskWidgetState();
}

class _HistoryCardTaskWidgetState extends State<HistoryCardTaskWidget> {
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [18, 4, 4, 10, 10, 1];
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
          color: Colors.white,
          boxShadow: const [ColorConfig.boxShadow2]),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(16, context),
          vertical: ScaleUtils.scaleSize(12, context)),
      child: Column(
        children: [
          AbsorbPointer(
            absorbing: widget.cubit.mapChildWHS[widget.data.work.id] == null,
            child: InkWell(
              onTap: () {
                setState(() {
                  isExpand = !isExpand;
                });
              },
              child: Row(
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
                          CardView(
                            content: widget.data.workingPoint.toString(),
                          ),
                        ],
                      )),
                  Expanded(
                      flex: weight[2],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CardView(content: DateTimeUtils.formatDuration(widget.data.workingTime)),
                        ],
                      )),
                  Expanded(
                    flex: weight[5],
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        isExpand
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: ScaleUtils.scaleSize(20, context),
                        color: const Color(0xFF646464),
                      ),
                    ),
                  )
                  // Expanded(
                  //     flex: weight[3],
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         StatusCard(status: widget.data.fromStatus)
                  //       ],
                  //     )),
                  // Expanded(
                  //     flex: weight[4],
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         StatusCard(status: widget.data.toStatus)
                  //       ],
                  //     )),
                ],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 229),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                axisAlignment: 0.0,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: isExpand
                ? ExpandWorkHistoryTaskWidget(
                cubit: widget.cubit, work: widget.data,)
                : const SizedBox.shrink(
              key: ValueKey<bool>(false),
            ),
          )
        ],
      ),
    );
  }
}

class CardView extends StatelessWidget {
  const CardView(
      {super.key, required this.content, this.background = Colors.white, this.size = 12});

  final String content;
  final Color background;
  final double size;

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
              fontSize: ScaleUtils.scaleSize(size, context),
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
