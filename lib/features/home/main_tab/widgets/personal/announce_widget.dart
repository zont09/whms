import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class AnnounceWidget extends StatelessWidget {
  const AnnounceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScaleUtils.scaleSize(8, context)),
          color: Colors.white,
          boxShadow: const [ColorConfig.boxShadow2]),
      padding: EdgeInsets.all(ScaleUtils.scaleSize(12, context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Thông báo công ty",
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w500,
                  color: ColorConfig.textColor)),
          Text("Họp app Creative English",
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(12, context),
                  fontWeight: FontWeight.w400,
                  color: ColorConfig.textColor)),
          Text("18:00 Thứ 5 . 28/11/2024",
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(12, context),
                  fontWeight: FontWeight.w500,
                  color: ColorConfig.textColor)),
          Row(
            children: [
              Text("Tệp đính kèm :",
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w500,
                      color: ColorConfig.textColor)),
              SizedBox(width: ScaleUtils.scaleSize(3, context)),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        ScaleUtils.scaleSize(12, context)),
                    color: const Color(0xFFFFD0D2)),
                padding: EdgeInsets.symmetric(
                    horizontal: ScaleUtils.scaleSize(8, context),
                    vertical: ScaleUtils.scaleSize(2, context)),
                child: Text(
                  "File họp review okrs tháng 11",
                  style: TextStyle(
                      fontSize: ScaleUtils.scaleSize(12, context),
                      fontWeight: FontWeight.w500,
                      color: ColorConfig.border5,
                      decoration: TextDecoration.underline,
                      decorationColor: ColorConfig.border5),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
