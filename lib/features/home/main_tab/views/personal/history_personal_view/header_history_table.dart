import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class HeaderHistoryTable extends StatelessWidget {
  const HeaderHistoryTable({super.key, required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [12, 15, 15, 15, 12, 12, 12, 1];
    final List<int> weight2 = [18, 4, 4, 10, 10, 1];
    final bool isByDay = AppText.textByDay.text == mode;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(16, context)),
      child: Row(
        children: [
          Expanded(
              flex: isByDay ? weight[0] : weight2[0],
              child: Text(
                  isByDay ? AppText.titleDate.text : AppText.titleTask.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400,
                      color: ColorConfig.textTertiary,
                      letterSpacing: -0.33))),
          Expanded(
              flex: isByDay ? weight[1] : weight2[1],
              child: Center(
                child: Text(
                    isByDay
                        ? AppText.titleLogTime.text
                        : AppText.titleWorkingPoint.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textTertiary,
                        letterSpacing: -0.33)),
              )),
          Expanded(
              flex: isByDay ? weight[2] : weight2[2],
              child: Center(
                child: Text(
                    isByDay
                        ? AppText.titleWorkingPoint.text
                        : AppText.titleWorkingTime.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textTertiary,
                        letterSpacing: -0.33)),
              )),
          if(isByDay)
          Expanded(
              flex: isByDay ? weight[3] : weight2[3],
              child: Center(
                child: Text(isByDay ? AppText.titleNumOfTask.text : AppText.titleFromStatus.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textTertiary,
                        letterSpacing: -0.33)),
              )),
          if(isByDay)
          Expanded(
              flex: isByDay ? weight[4] : weight2[4],
              child: Center(
                child: Text(isByDay ? AppText.titleCheckIn.text : AppText.titleToStatus.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textTertiary,
                        letterSpacing: -0.33)),
              )),
          if (isByDay)
            Expanded(
                flex: weight[5],
                child: Center(
                  child: Text(AppText.titleCheckOut.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w400,
                          color: ColorConfig.textTertiary,
                          letterSpacing: -0.33)),
                )),
          if (isByDay)
            Expanded(
                flex: weight[6],
                child: Center(
                  child: Text(AppText.titleSumBreak.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w400,
                          color: ColorConfig.textTertiary,
                          letterSpacing: -0.33)),
                )),
          Expanded(flex: weight[7], child: Container()),
        ],
      ),
    );
  }
}
