import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/hr/bloc/hr_tab_cubit.dart';
import 'package:whms/features/home/hr/widget/timeline_task_item_widget.dart';
import 'package:whms/models/working_unit_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/no_data_available_widget.dart';
import 'package:whms/widgets/z_space.dart';

class TimelineCalendarView extends StatefulWidget {
  const TimelineCalendarView({
    super.key,
    required this.cubit,
  });

  final HrTabCubit cubit;

  @override
  State<TimelineCalendarView> createState() => _TimelineCalendarViewState();
}

class _TimelineCalendarViewState extends State<TimelineCalendarView> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  // Kích thước cho timeline
  final double dayWidth = 80.0;
  final double rowHeight = 60.0;
  final double headerHeight = 80.0;
  final double leftColumnWidth = 200.0;

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  List<DateTime> _getDateRange() {
    final List<DateTime> dates = [];
    DateTime current = widget.cubit.startTime;

    while (current.isBefore(widget.cubit.endTime) ||
        current.isAtSameMomentAs(widget.cubit.endTime)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  Map<String, List<WorkingUnitModel>> _groupTasksByUser() {
    Map<String, List<WorkingUnitModel>> grouped = {};

    if (widget.cubit.userSelected.isNotEmpty) {
      // Nếu đã chọn user cụ thể
      grouped[widget.cubit.userSelected] = widget.cubit.listDataWorkOfUser;
    } else {
      // Lấy tất cả tasks từ listHRData
      for (var cardData in widget.cubit.listHRData) {
        for (var hrTask in cardData.details) {
          final task = hrTask.task;

          // Chỉ lấy task có urgent và deadline
          if (task.urgent == null || task.deadline == null) continue;

          // Group theo từng assignee
          if (task.assignees.isEmpty) {
            // Task không có assignee, bỏ qua hoặc gán vào "Unassigned"
            continue;
          }

          for (var userId in task.assignees) {
            if (!grouped.containsKey(userId)) {
              grouped[userId] = [];
            }
            // Kiểm tra task đã tồn tại chưa (tránh duplicate)
            if (!grouped[userId]!.any((t) => t.id == task.id)) {
              grouped[userId]!.add(task);
            }
          }
        }
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final dates = _getDateRange();
    final groupedTasks = _groupTasksByUser();

    // Debug: In ra số lượng data
    print('=== TIMELINE DEBUG ===');
    print('listHRData count: ${widget.cubit.listHRData.length}');
    print('groupedTasks users: ${groupedTasks.keys.length}');
    groupedTasks.forEach((userId, tasks) {
      print('User $userId has ${tasks.length} tasks');
    });
    print('Date range: ${dates.length} days');
    print('=====================');

    if (widget.cubit.loading > 0) {
      return const Center(
        child: CircularProgressIndicator(color: ColorConfig.primary3),
      );
    }

    if (groupedTasks.isEmpty) {
      return const Column(
        children: [
          ZSpace(h: 20),
          NoDataAvailableWidget(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với ngày tháng
        _buildHeader(context, dates),

        const ZSpace(h: 10),

        // Timeline content
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột bên trái - danh sách user/task
              _buildLeftColumn(context, groupedTasks),

              const ZSpace(w: 10),

              // Timeline grid
              Expanded(
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: _buildTimelineGrid(context, dates, groupedTasks),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, List<DateTime> dates) {
    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        color: ColorConfig.primary3.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
      ),
      child: Row(
        children: [
          // Space cho left column
          SizedBox(width: leftColumnWidth + 10),

          // Dates header
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: dates.map((date) {
                  final isToday = DateTimeUtils.isSameDay(date, DateTime.now());

                  return Container(
                    width: dayWidth,
                    padding: EdgeInsets.all(ScaleUtils.scaleSize(8, context)),
                    decoration: BoxDecoration(
                      color: isToday ? ColorConfig.primary3.withOpacity(0.2) : Colors.transparent,
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateTimeUtils.getDayOfWeek(date),
                          style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(12, context),
                            fontWeight: FontWeight.w500,
                            color: isToday ? ColorConfig.primary3 : const Color(0xFF666666),
                          ),
                        ),
                        const ZSpace(h: 4),
                        Text(
                          '${date.day}/${date.month}',
                          style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(14, context),
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                            color: isToday ? ColorConfig.primary3 : const Color(0xFF191919),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context, Map<String, List<WorkingUnitModel>> groupedTasks) {
    return Container(
      width: leftColumnWidth,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: groupedTasks.entries.map((entry) {
            final userId = entry.key;
            final tasks = entry.value;
            final user = widget.cubit.mapUserModel[userId];

            return Column(
              children: [
                Container(
                  height: rowHeight,
                  padding: EdgeInsets.all(ScaleUtils.scaleSize(8, context)),
                  decoration: BoxDecoration(
                    color: ColorConfig.primary3.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(6, context)),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: ScaleUtils.scaleSize(16, context),
                        backgroundColor: ColorConfig.primary3,
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScaleUtils.scaleSize(14, context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const ZSpace(w: 8),
                      // User name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user?.name ?? 'Unknown',
                              style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(14, context),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF191919),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${tasks.length} task${tasks.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(12, context),
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ...tasks.map((task) => Container(
                  height: rowHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(8, context),
                    vertical: ScaleUtils.scaleSize(4, context),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(13, context),
                        color: const Color(0xFF191919),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimelineGrid(
      BuildContext context,
      List<DateTime> dates,
      Map<String, List<WorkingUnitModel>> groupedTasks,
      ) {
    return Column(
      children: groupedTasks.entries.map((entry) {
        final tasks = entry.value;

        return Column(
          children: [
            // User row (empty, chỉ để spacing)
            Container(
              height: rowHeight,
              width: dates.length * dayWidth,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Task rows
            ...tasks.map((task) {
              return Container(
                height: rowHeight,
                width: dates.length * dayWidth,
                child: Stack(
                  children: [
                    // Grid lines
                    Row(
                      children: dates.map((date) {
                        final isToday = DateTimeUtils.isSameDay(date, DateTime.now());

                        return Container(
                          width: dayWidth,
                          decoration: BoxDecoration(
                            color: isToday
                                ? ColorConfig.primary3.withOpacity(0.05)
                                : Colors.transparent,
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1,
                              ),
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Task bar
                    TimelineTaskItemWidget(
                      task: task,
                      startDate: widget.cubit.startTime,
                      dayWidth: dayWidth,
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }
}