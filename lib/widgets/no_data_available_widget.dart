import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class NoDataAvailableWidget extends StatelessWidget {
  const NoDataAvailableWidget(
      {super.key,
      this.imgSize = 150,
      this.fontSizeTitle = 26,
      this.fontSizeContent = 20});

  final double imgSize;
  final double fontSizeTitle;
  final double fontSizeContent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: ScaleUtils.scaleSize(30, context)),
          Image.asset('assets/images/img_no_issues.png',
              height: ScaleUtils.scaleSize(imgSize, context)),
          SizedBox(height: ScaleUtils.scaleSize(10, context)),
          Text(
            AppText.textNoFindData.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(fontSizeTitle, context),
                fontWeight: FontWeight.w700,
                color: ColorConfig.primary3,
                letterSpacing: -0.33,
                shadows: const [ColorConfig.textShadow]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScaleUtils.scaleSize(2, context)),
          Text(
            AppText.textSubNoFindData.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(fontSizeContent, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.textColor,
                letterSpacing: -0.33),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
