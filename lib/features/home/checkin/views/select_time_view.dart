import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/features/home/checkin/blocs/check_in_cubit.dart';
import 'package:whms/features/home/checkin/blocs/check_in_main_view_cubit.dart';
import 'package:whms/features/home/checkin/widgets/select_time_of_day.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/date_time_utils.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';

class SelectTimeView extends StatelessWidget {
  const SelectTimeView(
      {super.key,
      required this.cubitLocal,
      required this.cubit,
      required this.isCheckIn,
      required this.startTime,
      required this.onTap,
      this.endTime});

  final CheckInMainViewCubit? cubitLocal;
  final CheckInCubit? cubit;
  final bool isCheckIn;
  final Timestamp? startTime;
  final Function() onTap;
  final Timestamp? endTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: ScaleUtils.scaleSize(18, context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text("${AppText.titleTimeRecordOnShift.text} :",
                style: TextStyle(
                    fontSize: ScaleUtils.scaleSize(18, context),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF332233),
                    shadows: const [ColorConfig.textShadow])),
            const ZSpace(w: 9),
            Row(children: [
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          ScaleUtils.scaleSize(34, context)),
                      border: Border.all(
                          width: ScaleUtils.scaleSize(1, context),
                          color: ColorConfig.primary3),
                      color: const Color(0xFFedf8ff)),
                  padding: EdgeInsets.symmetric(
                      horizontal: ScaleUtils.scaleSize(12, context),
                      vertical: ScaleUtils.scaleSize(4, context)),
                  child: Text(
                      isCheckIn
                          ? DateTimeUtils.convertTimestampToString(
                              DateTimeUtils.getTimestampNow())
                          : DateTimeUtils.convertTimestampToString(
                              startTime!),
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(16, context),
                          fontWeight: FontWeight.w400,
                          color: ColorConfig.textColor)))
            ])
          ]),
          SizedBox(height: ScaleUtils.scaleSize(20, context)),
          const Spacer(),
          if (!isCheckIn)
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text("${AppText.titleTimeRecordEndShift.text} :",
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(18, context),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF332233),
                      shadows: const [ColorConfig.textShadow])),
              const ZSpace(w: 9),
              Row(children: [
                SelectTimeOfDayWidget(
                    onTap: () {
                      onTap();
                    },
                    time: endTime!)
              ])
            ]),
          if (isCheckIn)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("${AppText.titleExpectedEndTime.text} :",
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(18, context),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF332233),
                        shadows: const [ColorConfig.textShadow])),
                const ZSpace(w: 9),
                SelectTimeOfDayWidget(
                    onTap: () => cubitLocal?.changeStatusSelectTime(),
                    time: cubit!.endTime)
              ],
            ),
        ],
      ),
    );
  }
}
