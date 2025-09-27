import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class TimeCard extends StatelessWidget {
  const TimeCard({super.key, required this.time, this.fontSize = 10, this.paddingHor = 8, this.paddingVer = 4});

  final String time;
  final double fontSize;
  final double paddingHor;
  final double paddingVer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(ScaleUtils.scaleSize(12, context)),
          color: ColorConfig.timeSecondary),
      padding: EdgeInsets.symmetric(
          horizontal: ScaleUtils.scaleSize(paddingHor, context),
          vertical: ScaleUtils.scaleSize(paddingVer, context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppText.textTime.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(fontSize, context),
                  fontWeight: FontWeight.w500,
                  color: ColorConfig.timePrimary)),
          SizedBox(width: ScaleUtils.scaleSize(4, context)),
          Container(
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ScaleUtils.scaleSize(15, context)), color: ColorConfig.timePrimary),
            padding: EdgeInsets.symmetric(
                horizontal: ScaleUtils.scaleSize(paddingHor / 2, context),
                vertical: ScaleUtils.scaleSize(paddingVer / 2, context)),
            child: Text(
              "$time",
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(fontSize-2, context),
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
          ),
          // if(isDropdown)
          //   SizedBox(width: ScaleUtils.scaleSize(5, context),),
          // if(isDropdown)
          //   Icon(Icons.arrow_drop_down, size: ScaleUtils.scaleSize(10, context), color: Colors.black,),
        ],
      ),
    );
  }
}
