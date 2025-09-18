import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/config_cubit.dart';
import 'package:whms/defines/status_check_in_define.dart';
import 'package:whms/features/home/main_tab/screens/task_done_today_view.dart';
import 'package:whms/models/response_model.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/dialog_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/custom_button.dart';

class DoneCheckoutView extends StatelessWidget {
  const DoneCheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final cfC = ConfigsCubit.fromContext(context);
    return Container(
      width: ScaleUtils.scaleSize(750, context),
      height: ScaleUtils.scaleSize(400, context),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(24, context)),
          color: Colors.white),
      child: Stack(
        children: [
          Container(
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(50, context),
                  vertical: ScaleUtils.scaleSize(26, context)),
              child: Column(
                children: [
                  const TaskDoneToDayView(
                    heightImg: 150,
                    sizeHeader: 24,
                    sizeTitle: 20,
                    sizeDes: 16,
                    isExpandFull: false,
                    paddingHor: 80,
                  ),
                  SizedBox(height: ScaleUtils.scaleSize(18, context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ZButton(
                          paddingHor: 24,
                          paddingVer: 6,
                          title: AppText.btnReCheckIn.text,
                          icon: "",
                          onPressed: () async {
                            bool isSuccess = false;
                            await DialogUtils.handleDialog(context, () async {
                              try {
                                final user =
                                    ConfigsCubit.fromContext(context).user;
                                final workShift = await cfC.getWorkShiftByUser(
                                    user.id, DateTimeUtils.getCurrentDate());
                                // final workShift = await UserServices.instance
                                //     .getWorkShiftByIdUserAndDate(user.id,
                                //         DateTimeUtils.getCurrentDate());
                                cfC.updateWorkShift(
                                    workShift!.copyWith(
                                        breakTimes: [
                                          ...workShift.breakTimes as List<Timestamp>,
                                          workShift.checkOut! as Timestamp
                                        ],
                                        resumeTimes: [
                                          ...workShift.resumeTimes as List<Timestamp>,
                                          DateTimeUtils.getTimestampNow()
                                        ],
                                        status:
                                            StatusCheckInDefine.checkIn.value),
                                    workShift);
                                // await UserServices.instance.updateWorkShift(
                                //     workShift!.copyWith(breakTimes: [
                                //   ...workShift.breakTimes,
                                //   workShift.checkOut!
                                // ], resumeTimes: [
                                //   ...workShift.resumeTimes,
                                //   DateTimeUtils.getTimestampNow()
                                // ], status: StatusCheckInDefine.checkIn.value));
                                isSuccess = true;
                                return ResponseModel(
                                    status: ResponseStatus.ok, results: "");
                              } catch (e) {
                                return ResponseModel(
                                    status: ResponseStatus.error,
                                    error: ErrorModel(text: e.toString()));
                              }
                            }, () {},
                                successMessage: AppText.titleSuccess.text,
                                successTitle: AppText.titleSuccess.text,
                                failedMessage: AppText.textHasError.text,
                                failedTitle: AppText.titleFailed.text);
                            if (isSuccess && context.mounted) {
                              await ConfigsCubit.fromContext(context)
                                  .changeCheckIn(StatusCheckInDefine.checkIn);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          }),
                      SizedBox(width: ScaleUtils.scaleSize(9, context)),
                      ZButton(
                          title: AppText.btnOk.text,
                          paddingHor: 24,
                          paddingVer: 6,
                          icon: "",
                          onPressed: () {
                            Navigator.of(context).pop();
                          })
                    ],
                  )
                ],
              )),
          Positioned(
            top: ScaleUtils.scaleSize(20, context),
            right: ScaleUtils.scaleSize(20, context),
            child: InkWell(
              onTap: () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Image.asset('assets/images/icons/ic_close_check_in.png',
                  height: ScaleUtils.scaleSize(16, context)),
            ),
          )
        ],
      ),
    );
  }
}
