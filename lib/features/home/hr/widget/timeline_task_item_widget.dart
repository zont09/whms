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
  });

  final WorkingUnitModel task;
  final DateTime startDate;
  final double dayWidth;

  @override
  Widget build(BuildContext context) {
    // Tính toán vị trí và độ rộng của task bar
    final taskStart = task.urgent.toDate();
    final taskEnd = task.deadline.toDate();

    // Số ngày từ startDate đến taskStart
    final daysFromStart = taskStart.difference(startDate).inDays.toDouble();

    // Độ dài task tính bằng ngày
    final taskDuration = taskEnd.difference(taskStart).inDays.toDouble() + 1;

    // Nếu task nằm ngoài phạm vi hiển thị
    if (daysFromStart + taskDuration < 0 || daysFromStart > 100) {
      return const SizedBox.shrink();
    }

    final leftPosition = daysFromStart * dayWidth;
    final width = taskDuration * dayWidth - 4; // -4 để có margin

    // Màu sắc theo trạng thái
    Color getTaskColor() {
      if (task.status == StatusWorkingDefine.completed.value) {
        return Colors.green;
      } else if (StatusWorkingExtension.fromValue(task.status).isInRange(task.status)) {
        return ColorConfig.primary3;
      } else if (task.status == StatusWorkingDefine.pending.value) {
        return Colors.orange;
      } else if (taskEnd.isBefore(DateTime.now()) &&
          task.status != StatusWorkingDefine.completed.value) {
        return Colors.red; // Quá hạn
      }
      return Colors.grey;
    }

    String getStatusText() {
      if (task.status == StatusWorkingDefine.completed.value) {
        return 'Hoàn thành';
      } else if (StatusWorkingExtension.fromValue(task.status).isInRange(task.status)) {
        return 'Đang làm';
      } else if (task.status == StatusWorkingDefine.pending.value) {
        return 'Chờ';
      } else if (taskEnd.isBefore(DateTime.now())) {
        return 'Quá hạn';
      }
      return 'Mới';
    }

    return Positioned(
      left: leftPosition.clamp(0, double.infinity),
      top: 8,
      child: Container(
        width: width > 0 ? width : 20,
        height: 44,
        child: Tooltip(
          message: '''
${task.title}
Bắt đầu: ${DateTimeUtils.formatDateDayMonthYear(taskStart)}
Kết thúc: ${DateTimeUtils.formatDateDayMonthYear(taskEnd)}
Trạng thái: ${getStatusText()}
Tiến độ: ${task.status?.toStringAsFixed(0) ?? '0'}%
''',
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScaleUtils.scaleSize(6, context),
              vertical: ScaleUtils.scaleSize(4, context),
            ),
            decoration: BoxDecoration(
              color: getTaskColor(),
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
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Progress bar
                if (task.status != null)
                  Container(
                    height: 4,
                    margin: EdgeInsets.only(top: ScaleUtils.scaleSize(2, context)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (task.status ?? 0) / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                // Status text
                Text(
                  getStatusText(),
                  style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(9, context),
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
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