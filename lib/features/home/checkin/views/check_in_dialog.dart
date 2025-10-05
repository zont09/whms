import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/views/check_in_view.dart';
import 'package:whms/features/home/checkin/views/check_out_view.dart';
import 'package:whms/features/home/checkin/views/done_checkout_view.dart';
import 'package:whms/untils/scale_utils.dart';

class CheckInDialog {
  static Future<void> showCheckInDialog(BuildContext context) async {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
    final cfC = ConfigsCubit.fromContext(context);
    final status = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Center(
            child: checkIn == StatusCheckInDefine.notCheckIn
                ? const CheckInView()
                : (checkIn == StatusCheckInDefine.checkOut
                    ? const DoneCheckoutView()
                    : const CheckOutView()),
          ),
        );
      },
    );

    // if (status == true) {
    //   final meetings =
    //       await MeetingService.instance.getMeetingsForUserToday(cfC.user.id);
    //   if(context.mounted) {
    //     DialogUtils.showAlertDialog(context,
    //         child: AnnounceMeetingTodayPopup(data: meetings));
    //   }
    // }
  }

  static Future<TimeOfDay?> showTimePickerDialog(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.grey[900],
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              dialBackgroundColor: Color(0xFFFFDDDD),
              hourMinuteTextColor: Colors.black,
              hourMinuteColor: Color(0xFFFFDDDD),
              dayPeriodTextColor: Colors.white,
              dayPeriodColor: Color(0xFFFFDDDD),
              dialHandColor: Color(0xFFFF474D),
              entryModeIconColor: Colors.white,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.black),
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.blueGrey,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor:ColorConfig.primary2,
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: ScaleUtils.scaleSize(18, context))),
            ),
          ),
          child: child!,
        );
      },
    );
    return selectedTime;
  }
}
