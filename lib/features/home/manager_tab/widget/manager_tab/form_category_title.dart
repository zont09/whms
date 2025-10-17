import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:flutter/material.dart';

class FormCategoryTitle extends StatelessWidget {
  final String title;
  const FormCategoryTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          shadows: [
            BoxShadow(
                blurRadius: ScaleUtils.scaleSize(2, context),
                color: const Color(0x1A000000),
                offset: Offset(0, ScaleUtils.scaleSize(2, context)))
          ],
          color: ColorConfig.textColor,
          fontSize: ScaleUtils.scaleSize(14, context),
          fontWeight: FontWeight.lerp(FontWeight.w500, FontWeight.w600, 0.5)),
    );
  }
}
