import 'package:flutter/material.dart';
import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/app_text.dart';
import 'package:whms/untils/scale_utils.dart';

class PageNotFoundScreen extends StatelessWidget {
  const PageNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: ScaleUtils.scaleSize(250, context)),
        child: Center(
          child: Text(
            AppText.textPageNotFound.text,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(40, context),
                fontWeight: FontWeight.w600,
                color: ColorConfig.primary1),
          ),
        ),
      ),
    );
  }
}
