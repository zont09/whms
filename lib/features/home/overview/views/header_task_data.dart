import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class HeaderTaskData extends StatelessWidget {
  const HeaderTaskData({super.key, required this.weight});

  final List<int> weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(16, context),
          vertical: ScaleUtils.scaleSize(8, context)),
      child: Row(
        children: [
          Expanded(
              flex: weight[0],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    AppText.titleList.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.33,
                        color: ColorConfig.textTertiary),
                  )
                ],
              )),
          Expanded(
              flex: weight[1],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppText.titleProgressTask.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.33,
                        color: ColorConfig.textTertiary),
                  )
                ],
              )),
          Expanded(
              flex: weight[2],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppText.titleNumOfTask.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.33,
                        color: ColorConfig.textTertiary),
                  )
                ],
              )),
          Expanded(
              flex: weight[3],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppText.titleWorkingPoint.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.33,
                        color: ColorConfig.textTertiary),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
