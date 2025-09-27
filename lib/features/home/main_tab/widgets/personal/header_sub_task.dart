import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class HeaderSubTask extends StatelessWidget {
  const HeaderSubTask({super.key});

  @override
  Widget build(BuildContext context) {
    final List<int> weight = [16, 6, 6, 6, 1];
    return Row(
      children: [
        Expanded(
            flex: weight[0],
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: ScaleUtils.scaleSize(2.5, context)),
              child: Row(
                children: [
                  Text(
                    AppText.titleTask.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textTertiary),
                  ),
                ],
              ),
            )),
        Expanded(
            flex: weight[1],
            child: Padding(
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
                        color: ColorConfig.textTertiary),
                  ),
                ],
              ),
            )),
        Expanded(
            flex: weight[2],
            child: Padding(
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
                        color: ColorConfig.textTertiary),
                  ),
                ],
              ),
            )),
        Expanded(
            flex: weight[3],
            child: Padding(
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
                        color: ColorConfig.textTertiary),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
