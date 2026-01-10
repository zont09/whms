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
    Map<String, DateTime> taskWorkDate = {}; // Lưu ngày làm việc của task
    Set<String> addedTaskIds = {}; // Để tránh duplicate tasks

    print('>>> START _groupTasksByUser');
    print('userSelected: ${widget.cubit.userSelected}');
    print('scopeSelected: ${widget.cubit.scopeSelected}');

    // LUÔN LUÔN lấy tasks từ listHRData (tasks được làm việc trong khoảng thời gian)
    print('Processing ${widget.cubit.listHRData.length} HR data cards');

    int taskProcessed = 0;
    int taskFiltered = 0;
    int taskDuplicate = 0;
    int taskNoAssignee = 0;
    int taskNotInScope = 0;
    int taskUserNotInScope = 0;
    int taskNotMatchSelectedUser = 0;

    for (var cardData in widget.cubit.listHRData) {
      print('  Processing ${cardData.dateStr}: ${cardData.details.length} tasks');

      // Parse ngày từ dateStr (format: "DD/MM/YYYY")
      DateTime workDate = DateTime.now();
      try {
        final parts = cardData.dateStr.split('/');
        if (parts.length == 3) {
          workDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        print('    ⚠️  Cannot parse date: ${cardData.dateStr}');
      }

      for (var hrTask in cardData.details) {
        final task = hrTask.task;
        taskProcessed++;

        print('    • Task: ${task.title}');
        print('      - status: ${task.status}');
        print('      - assignees: ${task.assignees}');
        print('      - scopes: ${task.scopes}');
        print('      - work date: ${DateTimeUtils.formatDateDayMonthYear(workDate)}');

        // Bỏ qua task đã được thêm
        if (addedTaskIds.contains(task.id)) {
          print('      ❌ FILTERED: Duplicate');
          taskFiltered++;
          taskDuplicate++;
          continue;
        }

        // Bỏ qua task không có assignee
        if (task.assignees.isEmpty) {
          print('      ❌ FILTERED: No assignee');
          taskFiltered++;
          taskNoAssignee++;
          continue;
        }

        // Filter theo scope nếu có (chỉ khi KHÔNG chọn user cụ thể)
        // Vì nếu đã chọn user, ta muốn xem tất cả tasks mà user đó làm
        if (widget.cubit.scopeSelected.isNotEmpty && widget.cubit.userSelected.isEmpty) {
          if (!task.scopes.contains(widget.cubit.scopeSelected)) {
            print('      ❌ FILTERED: Not in selected scope (${widget.cubit.scopeSelected})');
            taskFiltered++;
            taskNotInScope++;
            continue;
          }
        }

        // Đánh dấu task đã được xử lý và lưu ngày làm việc
        addedTaskIds.add(task.id);
        taskWorkDate[task.id] = workDate;

        // Group theo từng assignee
        bool addedToAnyUser = false;
        for (var userId in task.assignees) {
          // Nếu có chọn user cụ thể, chỉ lấy tasks của user đó
          if (widget.cubit.userSelected.isNotEmpty) {
            if (userId != widget.cubit.userSelected) {
              print('      ⚠️  User $userId not match selected user ${widget.cubit.userSelected}');
              taskNotMatchSelectedUser++;
              continue;
            }
          }

          // Nếu có filter scope, chỉ hiển thị user thuộc scope đó
          if (widget.cubit.scopeSelected.isNotEmpty) {
            final userInScope = widget.cubit.mapUserInScope[widget.cubit.scopeSelected] ?? [];
            if (!userInScope.any((u) => u.id == userId)) {
              print('      ⚠️  User $userId not in scope');
              taskUserNotInScope++;
              continue;
            }
          }

          if (!grouped.containsKey(userId)) {
            grouped[userId] = [];
          }
          grouped[userId]!.add(task);
          addedToAnyUser = true;
          print('      ✅ Added to user: $userId on date ${DateTimeUtils.formatDateDayMonthYear(workDate)}');
        }

        if (!addedToAnyUser) {
          print('      ❌ FILTERED: No valid assignee');
          taskFiltered++;
        }
      }
    }

    print('');
    print('FILTER SUMMARY:');
    print('  Total processed: $taskProcessed');
    print('  Filtered out: $taskFiltered');
    print('    - Duplicate: $taskDuplicate');
    print('    - No assignee: $taskNoAssignee');
    print('    - Not in scope: $taskNotInScope');
    print('    - User not in scope: $taskUserNotInScope');
    print('    - Not match selected user: $taskNotMatchSelectedUser');
    print('  Kept: ${taskProcessed - taskFiltered}');

    // Lưu taskWorkDate vào cubit để TimelineTaskItemWidget sử dụng
    widget.cubit.taskWorkDateMap = taskWorkDate;

    // Sắp xếp tasks theo status (tiến độ) cho mỗi user
    grouped.forEach((userId, tasks) {
      tasks.sort((a, b) => (b.status ?? 0).compareTo(a.status ?? 0));
    });

    print('>>> END _groupTasksByUser - Result: ${grouped.keys.length} users, Total tasks: ${grouped.values.fold(0, (sum, tasks) => sum + tasks.length)}');

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final dates = _getDateRange();
    final groupedTasks = _groupTasksByUser();

    // Debug: In ra số lượng data
    print('');
    print('========== TIMELINE VIEW BUILD ==========');
    print('timeMode: ${widget.cubit.timeMode}');
    print('scopeSelected: ${widget.cubit.scopeSelected.isEmpty ? "ALL" : widget.cubit.scopeSelected}');
    print('userSelected: ${widget.cubit.userSelected.isEmpty ? "ALL" : widget.cubit.userSelected}');
    print('Date range: ${dates.length} days (${DateTimeUtils.formatDateDayMonthYear(widget.cubit.startTime)} - ${DateTimeUtils.formatDateDayMonthYear(widget.cubit.endTime)})');
    print('---');
    print('listHRData count: ${widget.cubit.listHRData.length}');

    // Log chi tiết từng ngày trong listHRData
    for (var cardData in widget.cubit.listHRData) {
      int totalTasks = 0;
      for (var hrTask in cardData.details) {
        totalTasks++;
      }
      print('  • ${cardData.dateStr}: ${cardData.details.length} HR tasks');
    }

    print('---');
    print('Grouped users: ${groupedTasks.keys.length}');
    int totalTasksInTimeline = 0;
    groupedTasks.forEach((userId, tasks) {
      final userName = widget.cubit.mapUserModel[userId]?.name ?? 'Unknown';
      print('  • $userName ($userId): ${tasks.length} tasks');
      totalTasksInTimeline += tasks.length;
      // Log 3 tasks đầu tiên của mỗi user
      for (int i = 0; i < tasks.length && i < 3; i++) {
        final task = tasks[i];
        print('    - ${task.title} (${DateTimeUtils.formatDateDayMonthYear(task.urgent.toDate())} → ${DateTimeUtils.formatDateDayMonthYear(task.deadline.toDate())})');
      }
      if (tasks.length > 3) {
        print('    ... and ${tasks.length - 3} more tasks');
      }
    });
    print('Total tasks in timeline: $totalTasksInTimeline');
    print('=========================================');
    print('');

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
                                fontSize: ScaleUtils.scaleSize(13, context),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF191919),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${tasks.length} task${tasks.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(11, context),
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
                      workDate: widget.cubit.taskWorkDateMap[task.id],
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