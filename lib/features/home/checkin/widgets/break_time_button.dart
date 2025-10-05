import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/checkin/blocs/check_out_cubit.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/services/user_service.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class BreakTimeButton extends StatelessWidget {
  const BreakTimeButton({super.key, required this.cubit});

  final CheckOutCubit cubit;

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    return ZButton(
        paddingHor: 14,
        title: AppText.btnResume.text,
        icon: "",
        colorBackground: ColorConfig.primary3,
        colorBorder: ColorConfig.primary3,
        sizeTitle: 16,
        paddingVer: 6,
        fontWeight: FontWeight.w600,
        onPressed: () async {
          bool isSuccess = false;
          await DialogUtils.handleDialog(context, () async {
            try {
              final user = ConfigsCubit.fromContext(context).user;
              final userService = UserServices.instance;
              final workShift = await userService.getWorkShiftByIdUserAndDate(
                  user.id, DateTimeUtils.getCurrentDate());
              List<Timestamp> resumeTime = [
                ...workShift!.resumeTimes
                    .sublist(0, workShift.resumeTimes.length - 1),
                DateTimeUtils.getTimestampNow()
              ];
              final newWorkShift = workShift.copyWith(
                  resumeTimes: resumeTime,
                  status: StatusCheckInDefine.checkIn.value);
              cfC.updateWorkShift(newWorkShift, workShift);
              // await userService.updateWorkShift(newWorkShift);
              cubit.updateWorkShift(newWorkShift);
              await ConfigsCubit.fromContext(context)
                  .changeCheckIn(StatusCheckInDefine.checkIn);
              isSuccess = true;
              return ResponseModel(status: ResponseStatus.ok, results: "");
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
        });
  }
}
