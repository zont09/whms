import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';
import 'package:flutter/material.dart';

class HeaderPreparationMeetingTable extends StatelessWidget {
  const HeaderPreparationMeetingTable({super.key, required this.weight});

  final List<int> weight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(16, context)),
      child: Row(
        children: [
          Expanded(
              flex: weight[0],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Text(AppText.textOwnerPreparationMeeting.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textTertiary)),
              )),
          Expanded(
              flex: weight[1],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Center(
                  child: Text(AppText.textTime.text,
                      style: TextStyle(
                          fontSize: ScaleUtils.scaleSize(12, context),
                          fontWeight: FontWeight.w400,
                          color: ColorConfig.textTertiary)),
                ),
              )),
          Expanded(
              flex: weight[2],
              child: Padding(
                padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context))
                    .copyWith(left: ScaleUtils.scaleSize(12, context)),
                child: Text(AppText.textContent.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textTertiary)),
              )),
          Expanded(
              flex: weight[3],
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(2.5, context)),
                child: Text(AppText.textFileAttachment.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textTertiary)),
              )),
          Expanded(
              flex: weight[4],
              child: Padding(
                padding: EdgeInsets.symmetric(
                        horizontal: ScaleUtils.scaleSize(2.5, context))
                    .copyWith(left: ScaleUtils.scaleSize(12, context)),
                child: Text(AppText.textList.text,
                    style: TextStyle(
                        fontSize: ScaleUtils.scaleSize(12, context),
                        fontWeight: FontWeight.w400,
                        color: ColorConfig.textTertiary)),
              )),
          const ZSpace(w: 9)
        ],
      ),
    );
  }
}
