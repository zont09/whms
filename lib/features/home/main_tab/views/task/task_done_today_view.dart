import 'package:whms/untils/app_text.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class TaskDoneToDayView extends StatelessWidget {
  const TaskDoneToDayView({
    super.key,
    this.heightImg = 377,
    this.sizeHeader = 32,
    this.sizeTitle = 26,
    this.sizeDes = 20,
    this.isExpandFull = true,
    this.paddingHor = 150
  });

  final double heightImg;
  final double sizeHeader;
  final double sizeTitle;
  final double sizeDes;
  final bool isExpandFull;
  final double paddingHor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: isExpandFull ? double.infinity : null,
      width:  isExpandFull ? double.infinity : null,
      padding:
          EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(paddingHor, context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/img_checked_out.png',
            height: ScaleUtils.scaleSize(heightImg, context),
          ),
          Text(
            AppText.titleThanksForEffort.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(sizeHeader, context),
                fontWeight: FontWeight.w700,
                color: ColorConfig.primary3,
                letterSpacing: -0.33),
            textAlign: TextAlign.center,
          ),
          Text(
            AppText.textThanksForEffort.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(sizeTitle, context),
                fontWeight: FontWeight.w400,
                color: ColorConfig.primary3,
                letterSpacing: -0.33),
            textAlign: TextAlign.center,
          ),
          Text(
            AppText.textSubThanksForEffort.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(sizeDes, context),
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
