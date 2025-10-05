import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/features/home/checkin/widgets/break_time_button.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class ButtonBreaktimeView extends StatelessWidget {
  const ButtonBreaktimeView({super.key, required this.cubit, required this.timeResume});

  final CheckOutCubit cubit;
  final DateTime timeResume;

  @override
  Widget build(BuildContext context) {
    final checkIn = ConfigsCubit.fromContext(context).isCheckIn;
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
            }),
        SizedBox(width: ScaleUtils.scaleSize(18, context)),
        if (checkIn == StatusCheckInDefine.checkIn)
          ZButton(
              paddingHor: 14,
              title: AppText.btnBreak.text,
              icon: "",
              colorBackground: ColorConfig.primary3,
              colorBorder: ColorConfig.primary3,
              sizeTitle: 16,
              paddingVer: 6,
              fontWeight: FontWeight.w600,
              onPressed: () async {
                bool isSuccess = false;
                bool isBreak = await DialogUtils.showConfirmDialog(context,
                    AppText.titleConfirm.text, AppText.textConfirmBreak.text);
                if (!isBreak) return;
                await DialogUtils.handleDialog(context, () async {
                  try {
                    final user = ConfigsCubit.fromContext(context).user;
                    final workShift = await cfC.getWorkShiftByUser(user.id, DateTimeUtils.getCurrentDate());
                    // final workShift =
                    //     await userService.getWorkShiftByIdUserAndDate(
                    //         user.id, DateTimeUtils.getCurrentDate());
                    List<Timestamp> breakTime = [
                      ...workShift!.breakTimes,
                      DateTimeUtils.getTimestampWithDateTime(cubit.timeBreak)
                    ];
                    List<Timestamp> resumeTime = [
                      ...workShift.resumeTimes,
                      DateTimeUtils.getTimestampWithDateTime(timeResume)
                    ];
                    final newWorkShift = workShift.copyWith(
                        breakTimes: breakTime,
                        resumeTimes: resumeTime,
                        status: StatusCheckInDefine.breakTime.value);
                    cfC.updateWorkShift(newWorkShift, workShift);
                    // await userService.updateWorkShift(newWorkShift);
                    cubit.updateWorkShift(newWorkShift);
                    await ConfigsCubit.fromContext(context).changeCheckIn(StatusCheckInDefine.breakTime);
                    isSuccess = true;
                    return ResponseModel(
                        status: ResponseStatus.ok, results: "");
                  } catch (e) {
                    return ResponseModel(
                        status: ResponseStatus.error,
                        error: ErrorModel(text: e.toString()));
                  }
                }, () {},
                    isShowDialogSuccess: false,
                    isShowDialogError: true,
                    successMessage: "",
                    successTitle: "",
                    failedMessage: AppText.textHasError.text,
                    failedTitle: AppText.titleFailed.text);
                if (isSuccess && context.mounted) {
                  Navigator.of(context).pop();
                }
              }),
        if (checkIn == StatusCheckInDefine.breakTime)
          BreakTimeButton(cubit: cubit)
      ],
    );
  }
}
