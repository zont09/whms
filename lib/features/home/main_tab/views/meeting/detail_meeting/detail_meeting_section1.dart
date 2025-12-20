import 'package:go_router/go_router.dart';
import 'package:whms/defines/status_meeting_define.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/detail_meeting_cubit.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/meeting_cubit.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/dropdown_status_meeting.dart';
import 'package:whms/features/home/main_tab/widgets/meeting/meeting_text_field.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/models/meeting_model.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class DetailMeetingSection1 extends StatelessWidget {
  const DetailMeetingSection1({
    super.key,
    required this.cubitM,
    required this.meeting,
    required this.cubit,
  });

  final MeetingCubit cubitM;
  final MeetingModel meeting;
  final DetailMeetingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            cubitM.selectMeeting(MeetingModel(id: "none"));
          },
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_ios_new,
                size: ScaleUtils.scaleSize(20, context),
                color: ColorConfig.textColor6,
              ),
              const ZSpace(w: 4),
              Image.asset(
                'assets/images/icons/tab_bar/ic_tab_meeting.png',
                height: ScaleUtils.scaleSize(20, context),
                color: ColorConfig.primary3,
              ),
              const ZSpace(w: 4),
              Expanded(
                child: Text(
                  AppText.titleMeetingDetails.text,
                  style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(16, context),
                    fontWeight: FontWeight.w500,
                    color: ColorConfig.textColor6,
                    overflow: TextOverflow.ellipsis,
                    shadows: const [ColorConfig.textShadow],
                  ),
                ),
              ),
            ],
          ),
        ),
        // const ZSpace(h: 5),
        MeetingTextField(
          meeting: meeting,
          controller: TextEditingController(text: meeting.title),
          onUpdate: (v) {
            cubit.updateMeeting(meeting.copyWith(title: v));
            cubitM.updateMeeting(meeting.copyWith(title: v));
          },
          hint: AppText.textHintTypingTitle.text,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        // const ZSpace(h: ),
        Row(
          children: [
            InkWell(
              onTap: () async {
                final date = await DateTimeUtils.pickTimeAndDate(
                  context,
                  initDate: cubit.meeting.time,
                );
                if (date != null) {
                  cubit.changeTimeMeeting(date);
                  cubitM.updateMeeting(meeting.copyWith(time: date));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(229),
                  border: Border.all(
                    width: ScaleUtils.scaleSize(1, context),
                    color: ColorConfig.border4,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(8, context),
                  vertical: ScaleUtils.scaleSize(4, context),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icons/ic_calendar3.png',
                      height: ScaleUtils.scaleSize(16, context),
                    ),
                    const ZSpace(w: 4),
                    Text(
                      getTime(cubit.meeting.time),
                      style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textColor,
                        letterSpacing: -0.02,
                      ),
                    ),
                    const ZSpace(w: 5),
                    Text(
                      "|",
                      style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w500,
                        color: ColorConfig.textTertiary,
                        letterSpacing: -0.02,
                      ),
                    ),
                    const ZSpace(w: 5),
                    Text(
                      getDate(cubit.meeting.time),
                      style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w600,
                        color: ColorConfig.textColor,
                        letterSpacing: -0.02,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const ZSpace(w: 9),
            InkWell(
              onTap: () async {
                final times = await DateTimeUtils.pickDateTime(
                  context,
                  initDate: cubit.meeting.reminderTime,
                );
                if (times != null) {
                  cubit.changeTimeReminder(times);
                  cubitM.updateMeeting(meeting.copyWith(reminderTime: times));
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(229),
                  border: Border.all(
                    width: ScaleUtils.scaleSize(1, context),
                    color: ColorConfig.border4,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(8, context),
                  vertical: ScaleUtils.scaleSize(4, context),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/icons/ic_calendar3.png',
                      height: ScaleUtils.scaleSize(16, context),
                    ),
                    const ZSpace(w: 4),
                    Text(
                      DateTimeUtils.formatDateDayMonthYear(
                        cubit.meeting.reminderTime,
                      ),
                      style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w500,
                        color: ColorConfig.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const ZSpace(w: 9),
            // CardStatusMeeting(
            //     status: cubit.meeting.status, isSelected: false),
            DropdownStatusMeeting(
              maxHeight: 28,
              onChanged: (v) {
                cubit.changeStatus(v!);
                cubitM.updateMeeting(meeting.copyWith(status: v));
              },
              initItem: cubit.meeting.status,
              options: StatusMeetingDefine.values.map((e) => e.title).toList(),
            ),
            const ZSpace(w: 9),
            if (meeting.time.difference(DateTime.now()).inMinutes <= 15 &&
                meeting.status != StatusMeetingDefine.done.title)
              InkWell(
                onTap: () {
                  context.go("/meeting/${meeting.id}");
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(229),
                    color: ColorConfig.primary3,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(10, context),
                    vertical: ScaleUtils.scaleSize(5, context),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.login,
                        color: Colors.white,
                        size: ScaleUtils.scaleSize(18, context),
                      ),
                      const ZSpace(w: 5),
                      Text(
                        "Tham gia cuộc họp",
                        style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String getTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String getDate(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}";
  }
}
