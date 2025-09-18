import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class NoTaskCheckIn extends StatelessWidget {
  const NoTaskCheckIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/img_no_document.png',
              height: ScaleUtils.scaleSize(186, context)),
          SizedBox(height: ScaleUtils.scaleSize(5, context)),
          Text(AppText.titleNoTaskCheckIn.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(20, context),
                  fontWeight: FontWeight.w600,
                  color: ColorConfig.textTertiary)),
          SizedBox(height: ScaleUtils.scaleSize(5, context)),
          Text(AppText.textNoTaskCheckIn.text,
              style: TextStyle(
                  fontSize: ScaleUtils.scaleSize(16, context),
                  fontWeight: FontWeight.w400,
                  color: ColorConfig.textTertiary))
        ],
      ),
    );
  }
}
