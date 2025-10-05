import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_in_cubit.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class ButtonBreakView extends StatelessWidget {
  const ButtonBreakView({super.key, required this.cubit});

  final CheckInCubit cubit;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ZButton(
          title: AppText.btnCancel.text,
          icon: "",
          colorTitle: ColorConfig.primary2,
          colorBackground: Colors.white,
          colorBorder: Colors.white,
          sizeTitle: 16,
          paddingHor: 20,
          paddingVer: 6,
          fontWeight: FontWeight.w600,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        SizedBox(width: ScaleUtils.scaleSize(18, context)),
        ZButton(
          paddingHor: 14,
          title: AppText.btnResume.text,
          icon: "",
          colorBackground: ColorConfig.primary2,
          colorBorder: ColorConfig.primary2,
          sizeTitle: 16,
          paddingVer: 6,
          fontWeight: FontWeight.w600,
          onPressed: () async {
            DialogUtils.showLoadingDialog(context);
            await ConfigsCubit.fromContext(
              context,
            ).changeCheckIn(StatusCheckInDefine.checkIn);
            if (context.mounted) {
              final user = ConfigsCubit.fromContext(context).user;
              final workShift = await cfC.getWorkShiftByUser(
                user.id,
                DateTimeUtils.getCurrentDate(),
              );
              cfC.updateWorkShift(
                workShift!.copyWith(
                  status: StatusCheckInDefine.checkIn.value,
                  resumeTimes: [
                    ...workShift.resumeTimes.sublist(
                      0,
                      workShift.resumeTimes.length - 1,
                    ),
                    DateTimeUtils.getTimestampNow(),
                  ],
                ),
                workShift,
              );
              // await UserServices.instance.updateWorkShift();
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
