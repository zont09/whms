import 'package:whms/features/home/hr/bloc/hr_tab_cubit.dart';
import 'package:whms/features/home/hr/views/header_table_hr_task_view.dart';
import 'package:whms/features/home/hr/views/header_table_hr_view.dart';
import 'package:whms/features/home/hr/views/hr_main_view.dart';
import 'package:whms/features/home/hr/views/task_popup_view.dart';
import 'package:whms/features/home/hr/views/timeline_calendar_view.dart';
import 'package:whms/features/home/hr/widget/card_data_hr_task_widget.dart';
import 'package:whms/features/home/hr/widget/card_data_widget.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/user_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:whms/widgets/dropdown_String.dart';
import 'package:flutter/material.dart';
import 'package:whms/widgets/no_data_available_widget.dart';

class HistoryView extends StatelessWidget {
  const HistoryView(
      {super.key,
      required this.widget,
      required this.weight,
      required this.cubit});

  final HrMainView widget;
  final HrTabCubit cubit;
  final List<int> weight;

  @override
  Widget build(BuildContext context) {
    final String idMap =
        "${cubit.startTime}-${cubit.endTime}-${cubit.scopeSelected}-${cubit.userSelected}";
    final bool isShowNoData = widget.cubit.loading == 0 &&
        ((widget.cubit.listHRData.isEmpty &&
                widget.cubit.timeMode != AppText.textSynthetic.text &&
                widget.cubit.timeMode != "Timeline") ||
            (widget.cubit.listTaskData.isEmpty &&
                widget.cubit.timeMode == AppText.textSynthetic.text));
    
    // Nếu là timeline mode, cần trả về layout khác
    if (widget.cubit.timeMode == "Timeline") {
      return Column(
        key: ValueKey(widget.cubit.state),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${DateTimeUtils.formatDateDayMonthYear(widget.cubit.startTime)} - ${DateTimeUtils.formatDateDayMonthYear(widget.cubit.endTime)}",
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(16, context),
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.02,
                    color: const Color(0xFF191919)),
              ),
              DropdownString(
                onChanged: (v) {
                  widget.cubit.changeTimeMode(v!);
                },
                initItem: widget.cubit.timeMode,
                options: [
                  AppText.textByDay.text,
                  AppText.textByWeek.text,
                  AppText.textByMonth.text,
                  AppText.textSynthetic.text,
                  "Timeline"
                ],
                radius: 8,
                textColor: const Color(0xFF191919),
                fontSize: 14,
                maxWidth: 120,
                centerItem: true,
              )
            ],
          ),
          const ZSpace(h: 15),
          SizedBox(
            height: 600,
            child: TimelineCalendarView(cubit: cubit),
          ),
        ],
      );
    }
    
    // Layout bình thường cho các mode khác
    return Column(
      key: ValueKey(widget.cubit.state),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${DateTimeUtils.formatDateDayMonthYear(widget.cubit.startTime)} - ${DateTimeUtils.formatDateDayMonthYear(widget.cubit.endTime)}",
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.02,
                  color: const Color(0xFF191919)),
            ),
            DropdownString(
              onChanged: (v) {
                widget.cubit.changeTimeMode(v!);
              },
              initItem: widget.cubit.timeMode,
              options: [
                AppText.textByDay.text,
                AppText.textByWeek.text,
                AppText.textByMonth.text,
                AppText.textSynthetic.text,
                "Timeline"
              ],
              radius: 8,
              textColor: const Color(0xFF191919),
              fontSize: 14,
              maxWidth: 120,
              centerItem: true,
            )
          ],
        ),
        const ZSpace(h: 15),
        if (isShowNoData) const NoDataAvailableWidget(),
        if (!isShowNoData && cubit.timeMode != AppText.textSynthetic.text)
          HeaderTableHrView(weight: weight, isPersonal: cubit.userSelected.isNotEmpty,),
        if (!isShowNoData && cubit.timeMode == AppText.textSynthetic.text)
          HeaderTableHrTaskView(weight: weight),
        const ZSpace(h: 5),
        if (widget.cubit.timeMode != AppText.textSynthetic.text)
          ...widget.cubit.listHRData.map((item) => Column(
                children: [
                  CardDataWidget(
                      key: ValueKey(
                          "${item.dateStr} - ${widget.cubit.scopeSelected} - ${widget.cubit.timeMode} - ${widget.cubit.state}"),
                      weight: weight,
                      isPersonal: widget.cubit.userSelected.isNotEmpty,
                      data: item),
                    const ZSpace(h: 6)
                  ],
                )),
          if (widget.cubit.timeMode == AppText.textSynthetic.text &&
              widget.cubit.listTaskData.isNotEmpty &&
              widget.cubit.loading == 0)
            ...widget.cubit.mapTaskDataGroup.entries.map((item) => Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              ScaleUtils.scaleSize(6, context)),
                          color: ColorConfig.primary3,
                          boxShadow: const [ColorConfig.boxShadow2]),
                      padding: EdgeInsets.symmetric(
                          horizontal: ScaleUtils.scaleSize(6, context),
                          vertical: ScaleUtils.scaleSize(4, context)),
                      child: Text(
                        item.key.title,
                        style: TextStyle(
                            fontSize: ScaleUtils.scaleSize(16, context),
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                    const ZSpace(h: 9),
                    ...item.value.map(
                      (e) => Column(
                        children: [
                          CardDataHrTaskWidget(
                              key: ValueKey(
                                  "${e.work} - ${widget.cubit.scopeSelected} - ${widget.cubit.timeMode} - ${widget.cubit.state}"),
                              weight: weight,
                              task: e,
                              showDetailTask: () async {
                                DialogUtils.showLoadingDialog(context);
                                // await cubitHr.getDataUser(data.task.assignees);
                                await cubit.getDataTaskChildAndUser(e.work.id, e.work.assignees);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                                DialogUtils.showAlertDialog(context,
                                    child: TaskPopupView(
                                        task: e.work,
                                        subtasks: cubit.mapTaskChild[e.work.id] != null
                                            ? cubit.mapTaskChild[e.work.id]!
                                            : [],
                                        assignees: e.work.assignees
                                            .map((e) => cubit.mapUserModel[e])
                                            .where((e) => e != null)
                                            .cast<UserModel>()
                                            .toList(),
                                        listScopes: cubit.listScope));
                              },
                              subTask: widget.cubit
                                      .mapTaskWorkSynChild[idMap + e.work.id] ??
                                  []),
                          const ZSpace(h: 6)
                        ],
                      ),
                    ),
                    const ZSpace(h: 18),
                  ],
                )),
        if (widget.cubit.loading > 0) const ZSpace(h: 9),
        if (widget.cubit.loading > 0)
          const Center(
              child: CircularProgressIndicator(
          color: ColorConfig.primary3,
        )),
      ],
    );
  }
}
