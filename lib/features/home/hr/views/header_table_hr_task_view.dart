import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class HeaderTableHrTaskView extends StatelessWidget {
  const HeaderTableHrTaskView({super.key, required this.weight});

  final List<int> weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(16, context),
          vertical: ScaleUtils.scaleSize(12, context)),
      child: Row(
        children: [
          Expanded(
              flex: weight[0],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
          Expanded(flex: weight[1], child: Padding(
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
                  AppText.titleFromStatus.text,
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
                  AppText.titleToStatus.text,
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
