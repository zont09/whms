import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/main_tab/blocs/meeting/create_meeting_cubit.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class CreateMeetingPopupPickTime extends StatelessWidget {
  const CreateMeetingPopupPickTime({
    super.key,
    required this.cubit,
  });

  final CreateMeetingCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(AppText.textTimeMeeting.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textColor6,
                letterSpacing: -0.41,
                height: 1.5)),
        const ZSpace(w: 5),
        InkWell(
          onTap: () async {
            final date = await DateTimeUtils.pickTimeAndDate(context);
            if (date != null) {
              cubit.changeTimeMeeting(date);
            }
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(229),
                border: Border.all(
                    width: ScaleUtils.scaleSize(1, context),
                    color: ColorConfig.border4)),
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(8, context),
                vertical: ScaleUtils.scaleSize(4, context)),
            child: Row(
              children: [
                Image.asset('assets/images/icons/ic_calendar3.png',
                    height: ScaleUtils.scaleSize(16, context)),
                const ZSpace(w: 4),
                Text(cubit.timeMeeting != null ?
                  formatDateTime(cubit.timeMeeting!) : AppText.textChooseTimeMeeting.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w500,
                      color: ColorConfig.textColor),
                )
              ],
            ),
          ),
        ),
        const ZSpace(w: 9),
        Text(AppText.textTimeReminderMeeting.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(16, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textColor6,
                letterSpacing: -0.41,
                height: 1.5)),
        const ZSpace(w: 5),
        InkWell(
          onTap: () async {
            final times = await DateTimeUtils.pickDateTime(context);
            if (times != null) {
              cubit.changeTimeReminder(times);
            }
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(229),
                border: Border.all(
                    width: ScaleUtils.scaleSize(1, context),
                    color: ColorConfig.border4)),
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(8, context),
                vertical: ScaleUtils.scaleSize(4, context)),
            child: Row(
              children: [
                Image.asset('assets/images/icons/ic_calendar3.png',
                    height: ScaleUtils.scaleSize(16, context)),
                const ZSpace(w: 4),
                Text(
                  DateTimeUtils.formatDateDayMonthYear(cubit.timeReminder),
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w500,
                      color: ColorConfig.textColor),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
  String formatDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
  }
}