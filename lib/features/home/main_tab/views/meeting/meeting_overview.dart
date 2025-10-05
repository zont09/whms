import 'package:whms/features/home/main_tab/views/meeting/detail_meeting/detail_meeting_view.dart';
import 'package:whms/features/home/main_tab/views/meeting/header_meeting_overview.dart';
import 'package:whms/features/home/main_tab/views/meeting/meeting_option_view.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/card_meeting.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/meeting_cubit.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/drag_task_widget.dart';
import 'package:whms/widgets/no_data_available_widget.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class MeetingOverview extends StatelessWidget {
  const MeetingOverview({super.key, required this.cubit});

  final MeetingCubit cubit;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [8, 16, 4, 4, 2, 6, 1];
    if (cubit.meetingSelected.id != "none") {
      return DetailMeetingView(
        meeting: cubit.meetingSelected,
        cubitM: cubit,
      );
    }
    return Padding(
      padding: EdgeInsets.all(ScaleUtils.scaleSize(20, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppText.titleListMeetings.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(20, context),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.33,
                  color: ColorConfig.primary3,
                  shadows: const [ColorConfig.textShadow])),
          const ZSpace(h: 9),
          MeetingOptionView(cubit: cubit),
          const ZSpace(h: 12),
          if (cubit.listShow.isEmpty) const NoDataAvailableWidget(),
          if (cubit.listShow.isNotEmpty)
            HeaderMeetingOverview(
              weight: weight,
              cubit: cubit,
            ),
          if (cubit.listShow.isNotEmpty) const ZSpace(h: 8),
          if (cubit.listShow.isNotEmpty &&
              cubit.filterTime != AppText.titleThisWeek.text)
            Expanded(
              child: DragTaskWidget(
                  key: ValueKey(
                      "key_list_meeting_${cubit.listShow}_${cubit.filterTime}_${cubit.filterStatus}_${cubit.sortTitle}_${cubit.sortTime}"),
                  changeOrder: (a, b) {
                    cubit.changeOrder(a, b);
                  },
                  position: DragIconPosition.left,
                  children: [
                    ...cubit.listShow.map((e) => InkWell(
                          onTap: () {
                            cubit.getDataSection(e);
                            cubit.getDataPreparation(e);
                            cubit.getDataRecord(e);
                            cubit.selectMeeting(e);
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: ScaleUtils.scaleSize(20, context),
                                right: ScaleUtils.scaleSize(5, context)),
                            padding: EdgeInsets.symmetric(
                                vertical: ScaleUtils.scaleSize(5, context)),
                            child: CardMeeting(
                              meeting: e,
                              weight: weight,
                              onUpdate: (v) {
                                cubit.updateMeeting(v);
                              },
                            ),
                          ),
                        ))
                  ]),
            ),
          if (cubit.listShow.isNotEmpty &&
              cubit.filterTime == AppText.titleThisWeek.text)
            Expanded(
                child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: ScaleUtils.scaleSize(6, context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < cubit.listShow.length; i++) ...[
                      if (i > 0 &&
                          !cubit.isSameDate(cubit.listShow[i].time,
                              cubit.listShow[i - 1].time))
                        const ZSpace(h: 12),
                      if (i == 0 ||
                          !cubit.isSameDate(cubit.listShow[i].time,
                              cubit.listShow[i - 1].time))
                        Padding(
                          padding: EdgeInsets.only(
                              left: ScaleUtils.scaleSize(20, context)),
                          child: Text(
                            ">> ${getDiffDate(cubit.listShow[i].time, DateTime.now()) == 0 ? "Họp hôm nay" : (getDiffDate(cubit.listShow[i].time, DateTime.now()) > 0 ? "Còn ${getDiffDate(cubit.listShow[i].time, DateTime.now())} ngày tới cuộc họp" : "Cuộc họp đã diễn ra ${getDiffDate(cubit.listShow[i].time, DateTime.now()).abs()} ngày trước")}",
                            style: TextStyle(
                                fontSize: ScaleUtils.scaleSize(16, context),
                                fontWeight: FontWeight.w600,
                                color: ColorConfig.textColor6,
                                shadows: const [ColorConfig.textShadow]),
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          cubit.getDataSection(cubit.listShow[i]);
                          cubit.getDataPreparation(cubit.listShow[i]);
                          cubit.getDataRecord(cubit.listShow[i]);
                          cubit.selectMeeting(cubit.listShow[i]);
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              left: ScaleUtils.scaleSize(20, context),
                              right: ScaleUtils.scaleSize(5, context)),
                          padding: EdgeInsets.symmetric(
                              vertical: ScaleUtils.scaleSize(5, context)),
                          child: CardMeeting(
                            meeting: cubit.listShow[i],
                            weight: weight,
                            onUpdate: (v) {
                              cubit.updateMeeting(v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ))
        ],
      ),
    );
  }

  int getDiffDate(DateTime a, DateTime b) {
    final dateA = DateTime(a.year, a.month, a.day);
    final dateB = DateTime(b.year, b.month, b.day);

    return dateA.difference(dateB).inDays;
  }
}
