import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class HeaderTableHrView extends StatelessWidget {
  const HeaderTableHrView({super.key, required this.weight, this.isPersonal = false});

  final List<int> weight;
  final bool isPersonal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(16, context),
          vertical: ScaleUtils.scaleSize(12, context)),
      child: Row(
        children: [
          if(isPersonal)
          Expanded(
              flex: weight[8],
              child: SizedBox.shrink()),
          Expanded(
              flex: weight[0],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppText.textPeriod.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.33,
                          color: ColorConfig.textTertiary,
                          overflow: TextOverflow.ellipsis),
                    )
                  ],
                ),
              )),
          Expanded(flex: weight[1], child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(2.5, context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppText.titleLogTime.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.33,
                      color: ColorConfig.textTertiary,
                      overflow: TextOverflow.ellipsis),
                )
              ],
            ),
          )),
          Expanded(flex: weight[2], child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(2.5, context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppText.titleWorkingTime.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.33,
                      color: ColorConfig.textTertiary,
                      overflow: TextOverflow.ellipsis),
                )
              ],
            ),
          )),
          Expanded(flex: weight[3], child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(2.5, context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppText.titleTask.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.33,
                      color: ColorConfig.textTertiary,
                      overflow: TextOverflow.ellipsis),
                )
              ],
            ),
          )),
          Expanded(flex: weight[4], child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(2.5, context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppText.titleWorkingPoint.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.33,
                      color: ColorConfig.textTertiary,
                      overflow: TextOverflow.ellipsis),
                )
              ],
            ),
          )),
          if(isPersonal)
          Expanded(flex: weight[6], child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(2.5, context)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppText.titleCheckIn.text,
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.33,
                      color: ColorConfig.textTertiary,
                      overflow: TextOverflow.ellipsis),
                )
              ],
            ),
          )),
          if(isPersonal)
            Expanded(flex: weight[7], child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(2.5, context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppText.titleCheckOut.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.33,
                        color: ColorConfig.textTertiary,
                        overflow: TextOverflow.ellipsis),
                  )
                ],
              ),
            )),
          Expanded(flex: weight[5],child: Container())
        ],
      ),
    );
  }
}
