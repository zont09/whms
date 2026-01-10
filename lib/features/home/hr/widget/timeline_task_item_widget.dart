import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/defines/status_working_define.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';

class TimelineTaskItemWidget extends StatelessWidget {
  const TimelineTaskItemWidget({
    super.key,
    required this.task,
    required this.startDate,
    required this.dayWidth,
    this.workDate,
  });

  final WorkingUnitModel task;
  final DateTime startDate;
  final double dayWidth;
  final DateTime? workDate; // Ngày làm việc thực tế của task

  @override
  Widget build(BuildContext context) {
    // Nếu không có workDate (ngày làm việc), không hiển thị
    if (workDate == null) {
      return const SizedBox.shrink();
    }

    // Hiển thị task tại ngày làm việc
    final taskDate = workDate!;

    // Số ngày từ startDate đến taskDate
    final daysFromStart = taskDate.difference(startDate).inDays.toDouble();

    // Nếu task nằm ngoài phạm vi hiển thị
    if (daysFromStart < 0 || daysFromStart > 100) {
      return const SizedBox.shrink();
    }

    final leftPosition = daysFromStart * dayWidth;
    final width = dayWidth - 8; // Chiếm 1 ngày, trừ margin

    // Get status type và percent dựa trên StatusWorkingDefine
    final statusType = StatusWorkingExtension.fromValue(task.status ?? -1);
    final percentValue = StatusWorkingExtension.fromPercent(task.status ?? -1, isTask: true);

    String getTooltipMessage() {
      String message = '${task.title}\n';
      message += 'Ngày làm việc: ${DateTimeUtils.formatDateDayMonthYear(taskDate)}\n';
      message += 'Trạng thái: ${statusType.description}\n';
      if (percentValue > 0) {
        message += 'Tiến độ: $percentValue%';
      }
      return message;
    }

    return Positioned(
      left: leftPosition + 4, // Thêm margin trái
      top: 8,
      child: Container(
        width: width,
        height: 44,
        child: Tooltip(
          message: getTooltipMessage(),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(6, context),
              vertical: ScaleUtils.scaleSize(4, context),
            ),
            decoration: BoxDecoration(
              color: statusType.colorBackground,
              borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(6, context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Task title
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(11, context),
                      fontWeight: FontWeight.w600,
                      color: statusType.colorTitle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Progress bar - chỉ hiển thị khi có tiến độ (processing, reworking, revising)
                if (statusType.isDynamic && percentValue > 0)
                  Container(
                    height: 4,
                    margin: EdgeInsets.only(top: ScaleUtils.scaleSize(2, context)),
                    decoration: BoxDecoration(
                      color: statusType.colorTitle.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (percentValue / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: statusType.colorTitle,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                // Status text với %
                Text(
                  percentValue > 0 ? '$percentValue%' : statusType.description,
                  style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(9, context),
                    fontWeight: FontWeight.w600,
                    color: statusType.colorTitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}